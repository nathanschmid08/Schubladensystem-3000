# Autor: Nathan Dion Schmid
# Projekt: LB122
# Version: 1.0
# Datum: 05 2025
# Beschreibung:
# Dieses Skript ueberprueft, ob der Ordner "Test-Ordner" auf dem Desktop existiert.
# Fehlende Unterordner (Assembler, Datenbanken, Skripte, Texte, Websites) werden erstellt.
# Textdateien auf dem Desktop werden anhand ihrer Endung sortiert, umbenannt (Datum + Nummer)
# und in den passenden Ordner verschoben.

# Pfade definieren
$desktopPfad = "$env:USERPROFILE\Desktop"
$hauptOrdner = Join-Path $desktopPfad "Test-Ordner"

# Unterordnerstruktur mit Endungen definieren
$unterordner = @{
    "Assembler"    = @(".asm", ".s")
    "Datenbanken"  = @(".sql")
    "Skripte"      = @(".py", ".js", ".ts", ".rb", ".sh", ".ps1", ".bat", ".pl")
    "Texte"        = @(".txt", ".md", ".rtf")
    "Websites"     = @(".html", ".css")
}

# Hauptordner pruefen
if (-not (Test-Path $hauptOrdner)) {
    New-Item -ItemType Directory -Path $hauptOrdner | Out-Null
    Write-Host "Test-Ordner wurde erstellt." -ForegroundColor Cyan
}

# Unterordner pruefen und ggf. erstellen
foreach ($ordner in $unterordner.Keys) {
    $pfad = Join-Path $hauptOrdner $ordner
    if (-not (Test-Path $pfad)) {
        New-Item -ItemType Directory -Path $pfad | Out-Null
        Write-Host "Unterordner $ordner wurde erstellt." -ForegroundColor DarkCyan
    }
}

# Dateien auf dem Desktop holen
$dateien = Get-ChildItem -Path $desktopPfad -File

if ($dateien.Count -eq 0) {
    Write-Host "Keine Dateien auf dem Desktop gefunden." -ForegroundColor Yellow
    exit
}

# Datum + Zaehler
$heute = Get-Date -Format "yyyy-MM-dd"
$zaehler = 1

foreach ($datei in $dateien) {
    # Skript selbst nicht verschieben
    if ($datei.FullName -eq $PSCommandPath) {
        continue
    }

    $ext = $datei.Extension.ToLower()
    $zielUnterordner = $null

    # Typ erkennen
    foreach ($ordner in $unterordner.Keys) {
        if ($unterordner[$ordner] -contains $ext) {
            $zielUnterordner = $ordner
            break
        }
    }

    # Kein passender Typ gefunden
    if (-not $zielUnterordner) {
        Write-Host "Unbekannter Dateityp ($ext) - $($datei.Name) wird uebersprungen." -ForegroundColor DarkYellow
        continue
    }

    # Datei verschieben
    $neuerName = "{0}_{1:D3}{2}" -f $heute, $zaehler, $ext
    $zielPfad = Join-Path -Path (Join-Path $hauptOrdner $zielUnterordner) -ChildPath $neuerName

    try {
        Move-Item -Path $datei.FullName -Destination $zielPfad -Force
        Write-Host "Verschoben: $($datei.Name) -> $zielUnterordner\$neuerName" -ForegroundColor White
        $zaehler++
    } catch {
        Write-Host "Fehler beim Verschieben von $($datei.Name): $_" -ForegroundColor Red
    }
}

Write-Host "Fertig! $($zaehler - 1) Datei(en) wurden sortiert und verschoben." -ForegroundColor Green