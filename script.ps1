<#
Autor: Nathan Dion Schmid
Projekt: Automatischer Datei-Organisierer
Version: 1.3
Datum: 2025-05-26
Beschreibung:
Dieses Skript überprüft beim Login, ob ein Benutzerordner auf dem Desktop existiert.
Falls nicht, wird er inklusive Unterordner erstellt. Anschließend werden passende
Dateien auf dem Desktop nach Typ erkannt, umbenannt (Datum + Nummer) und in die
richtigen Unterordner verschoben.
#>

# === Benutzer- und Desktoppfad ermitteln ===
$benutzername = $env:USERNAME
$desktopPfad = "$env:USERPROFILE\Desktop"
$hauptOrdner = Join-Path $desktopPfad $benutzername

# === Unterordnerstruktur definieren ===
$unterordner = @{
    "Assembler"    = @(".asm", ".s")
    "Datenbanken"  = @(".sql")
    "Skripte"      = @(".py", ".js", ".ts", ".rb", ".sh", ".ps1", ".bat", ".pl")
    "Texte"        = @(".txt", ".md", ".rtf")
    "Websiten"     = @(".html", ".css")
}

# === Hauptordner und Unterordner erstellen, falls nicht vorhanden ===
if (-not (Test-Path $hauptOrdner)) {
    New-Item -ItemType Directory -Path $hauptOrdner | Out-Null
    Write-Host "Hauptordner '$benutzername' wurde erstellt." -ForegroundColor Cyan
}

foreach ($ordner in $unterordner.Keys) {
    $pfad = Join-Path $hauptOrdner $ordner
    if (-not (Test-Path $pfad)) {
        New-Item -ItemType Directory -Path $pfad | Out-Null
        Write-Host "Unterordner '$ordner' wurde erstellt." -ForegroundColor DarkCyan
    }
}

# === Alle Dateien auf dem Desktop holen ===
$dateien = Get-ChildItem -Path $desktopPfad -File

if ($dateien.Count -eq 0) {
    Write-Host "Keine Dateien auf dem Desktop gefunden." -ForegroundColor Yellow
    exit
}

# === Aktuelles Datum holen und Zähler starten ===
$heute = Get-Date -Format "yyyy-MM-dd"
$zaehler = 1

foreach ($datei in $dateien) {
    $ext = $datei.Extension.ToLower()
    $zielUnterordner = $null

    # === Passenden Zielordner anhand der Endung finden ===
    foreach ($ordner in $unterordner.Keys) {
        if ($unterordner[$ordner] -contains $ext) {
            $zielUnterordner = $ordner
            break
        }
    }

    # === Wenn kein Zielordner gefunden wurde, Datei überspringen ===
    if (-not $zielUnterordner) {
        Write-Host "Unbekannter Dateityp ($ext) – $($datei.Name) wird übersprungen." -ForegroundColor DarkYellow
        continue
    }

    # === Neuen Dateinamen erstellen ===
    $neuerName = "{0}_{1:D3}{2}" -f $heute, $zaehler, $ext
    $zielPfad = Join-Path -Path (Join-Path $hauptOrdner $zielUnterordner) -ChildPath $neuerName

    try {
        Move-Item -Path $datei.FullName -Destination $zielPfad
        Write-Host "Verschoben: $($datei.Name) -> $zielUnterordner\$neuerName"
        $zaehler++
    } catch {
        Write-Host "Fehler beim Verschieben von $($datei.Name): $_" -ForegroundColor Red
    }
}

Write-Host "Fertig! $($zaehler - 1) Datei(en) wurden sortiert und verschoben." -ForegroundColor Green
