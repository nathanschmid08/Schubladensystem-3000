# Autor: Nathan Dion Schmid
# Projekt: LB122 - GUI Version
# Version: 2.0
# Datum: 06 2025
# Beschreibung: Windows Forms GUI für den Desktop-Datei-Sortierer

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Globale Variablen
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

# Hauptfenster erstellen
$form = New-Object System.Windows.Forms.Form
$form.Text = "Schubladensystem 3000"
$form.Size = New-Object System.Drawing.Size(650, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::White

# Header Label
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "Schubladensystem Datei-Sortierer"
$headerLabel.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$headerLabel.ForeColor = [System.Drawing.Color]::DarkBlue
$headerLabel.Location = New-Object System.Drawing.Point(20, 15)
$headerLabel.Size = New-Object System.Drawing.Size(400, 30)
$form.Controls.Add($headerLabel)

# Beschreibung
$beschreibungLabel = New-Object System.Windows.Forms.Label
$beschreibungLabel.Text = "Sortiert Dateien vom Desktop automatisch in Unterordner nach Dateityp"
$beschreibungLabel.Font = New-Object System.Drawing.Font("Arial", 9)
$beschreibungLabel.Location = New-Object System.Drawing.Point(20, 45)
$beschreibungLabel.Size = New-Object System.Drawing.Size(500, 20)
$form.Controls.Add($beschreibungLabel)

# Status GroupBox
$statusGroup = New-Object System.Windows.Forms.GroupBox
$statusGroup.Text = "Aktueller Status"
$statusGroup.Location = New-Object System.Drawing.Point(20, 80)
$statusGroup.Size = New-Object System.Drawing.Size(590, 120)
$form.Controls.Add($statusGroup)

# Desktop Pfad Label
$desktopLabel = New-Object System.Windows.Forms.Label
$desktopLabel.Text = "Desktop-Pfad: $desktopPfad"
$desktopLabel.Location = New-Object System.Drawing.Point(15, 25)
$desktopLabel.Size = New-Object System.Drawing.Size(560, 20)
$statusGroup.Controls.Add($desktopLabel)

# Zielordner Label
$zielLabel = New-Object System.Windows.Forms.Label
$zielLabel.Text = "Zielordner: $hauptOrdner"
$zielLabel.Location = New-Object System.Drawing.Point(15, 45)
$zielLabel.Size = New-Object System.Drawing.Size(560, 20)
$statusGroup.Controls.Add($zielLabel)

# Dateien-Anzahl Label
$dateienLabel = New-Object System.Windows.Forms.Label
$dateienLabel.Text = "Dateien auf Desktop: Wird ermittelt..."
$dateienLabel.Location = New-Object System.Drawing.Point(15, 65)
$dateienLabel.Size = New-Object System.Drawing.Size(560, 20)
$statusGroup.Controls.Add($dateienLabel)

# Ordner-Status Label
$ordnerStatusLabel = New-Object System.Windows.Forms.Label
$ordnerStatusLabel.Text = "Ordnerstruktur: Wird geprüft..."
$ordnerStatusLabel.Location = New-Object System.Drawing.Point(15, 85)
$ordnerStatusLabel.Size = New-Object System.Drawing.Size(560, 20)
$statusGroup.Controls.Add($ordnerStatusLabel)

# Aktionen GroupBox
$aktionenGroup = New-Object System.Windows.Forms.GroupBox
$aktionenGroup.Text = "Aktionen"
$aktionenGroup.Location = New-Object System.Drawing.Point(20, 210)
$aktionenGroup.Size = New-Object System.Drawing.Size(590, 80)
$form.Controls.Add($aktionenGroup)

# Status aktualisieren Button
$updateButton = New-Object System.Windows.Forms.Button
$updateButton.Text = "Status aktualisieren"
$updateButton.Location = New-Object System.Drawing.Point(20, 30)
$updateButton.Size = New-Object System.Drawing.Size(120, 30)
$updateButton.BackColor = [System.Drawing.Color]::LightBlue
$aktionenGroup.Controls.Add($updateButton)

# Ordner erstellen Button
$erstellenButton = New-Object System.Windows.Forms.Button
$erstellenButton.Text = "Ordner erstellen"
$erstellenButton.Location = New-Object System.Drawing.Point(160, 30)
$erstellenButton.Size = New-Object System.Drawing.Size(120, 30)
$erstellenButton.BackColor = [System.Drawing.Color]::LightGreen
$aktionenGroup.Controls.Add($erstellenButton)

# Dateien sortieren Button
$sortierenButton = New-Object System.Windows.Forms.Button
$sortierenButton.Text = "Dateien sortieren"
$sortierenButton.Location = New-Object System.Drawing.Point(300, 30)
$sortierenButton.Size = New-Object System.Drawing.Size(120, 30)
$sortierenButton.BackColor = [System.Drawing.Color]::Orange
$sortierenButton.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$aktionenGroup.Controls.Add($sortierenButton)

# Beenden Button
$beendenButton = New-Object System.Windows.Forms.Button
$beendenButton.Text = "Beenden"
$beendenButton.Location = New-Object System.Drawing.Point(440, 30)
$beendenButton.Size = New-Object System.Drawing.Size(120, 30)
$beendenButton.BackColor = [System.Drawing.Color]::LightCoral
$aktionenGroup.Controls.Add($beendenButton)

# Log TextBox
$logGroup = New-Object System.Windows.Forms.GroupBox
$logGroup.Text = "Protokoll"
$logGroup.Location = New-Object System.Drawing.Point(20, 300)
$logGroup.Size = New-Object System.Drawing.Size(590, 130)
$form.Controls.Add($logGroup)

$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Multiline = $true
$logTextBox.ScrollBars = "Vertical"
$logTextBox.Location = New-Object System.Drawing.Point(10, 20)
$logTextBox.Size = New-Object System.Drawing.Size(570, 100)
$logTextBox.ReadOnly = $true
$logTextBox.BackColor = [System.Drawing.Color]::LightGray
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$logGroup.Controls.Add($logTextBox)

# Funktionen
function Write-Log {
    param([string]$message, [string]$color = "Black")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    $logTextBox.AppendText("$logMessage`r`n")
    $logTextBox.ScrollToCaret()
    $form.Refresh()
}

function Update-Status {
    try {
        # Desktop-Dateien zählen
        $dateien = Get-ChildItem -Path $desktopPfad -File -ErrorAction SilentlyContinue
        $anzahlDateien = $dateien.Count
        $dateienLabel.Text = "Dateien auf Desktop: $anzahlDateien"
        
        # Ordnerstruktur prüfen
        $ordnerVorhanden = Test-Path $hauptOrdner
        if ($ordnerVorhanden) {
            $unterordnerStatus = @()
            foreach ($ordner in $unterordner.Keys) {
                $pfad = Join-Path $hauptOrdner $ordner
                if (Test-Path $pfad) {
                    $unterordnerStatus += "$ordner [OK]"
                } else {
                    $unterordnerStatus += "$ordner [FEHLT]"
                }
            }
            $ordnerStatusLabel.Text = "Ordnerstruktur: Test-Ordner vorhanden | " + ($unterordnerStatus -join " | ")
        } else {
            $ordnerStatusLabel.Text = "Ordnerstruktur: Test-Ordner nicht vorhanden"
        }
        
        Write-Log "Status aktualisiert"
    } catch {
        Write-Log "Fehler beim Aktualisieren des Status: $($_.Exception.Message)" "Red"
    }
}

function New-Folders {
    try {
        # Hauptordner prüfen
        if (-not (Test-Path $hauptOrdner)) {
            New-Item -ItemType Directory -Path $hauptOrdner | Out-Null
            Write-Log "Test-Ordner wurde erstellt"
        }
        
        # Unterordner prüfen und ggf. erstellen
        foreach ($ordner in $unterordner.Keys) {
            $pfad = Join-Path $hauptOrdner $ordner
            if (-not (Test-Path $pfad)) {
                New-Item -ItemType Directory -Path $pfad | Out-Null
                Write-Log "Unterordner '$ordner' wurde erstellt"
            }
        }
        
        Write-Log "Ordnerstruktur wurde überprüft und vervollständigt"
        Update-Status
    } catch {
        Write-Log "Fehler beim Erstellen der Ordner: $($_.Exception.Message)" "Red"
    }
}

function Move-Files {
    try {
        Write-Log "Starte Dateisortierung..."
        
        # Dateien auf dem Desktop holen
        $dateien = Get-ChildItem -Path $desktopPfad -File
        if ($dateien.Count -eq 0) {
            Write-Log "Keine Dateien auf dem Desktop gefunden"
            return
        }
        
        # Datum + Zähler
        $heute = Get-Date -Format "yyyy-MM-dd"
        $zaehler = 1
        $verschobeneDateien = 0
        
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
                Write-Log "Unbekannter Dateityp ($ext) - $($datei.Name) wird übersprungen"
                continue
            }
            
            # Datei verschieben
            $neuerName = "{0}_{1:D3}{2}" -f $heute, $zaehler, $ext
            $zielPfad = Join-Path -Path (Join-Path $hauptOrdner $zielUnterordner) -ChildPath $neuerName
            
            try {
                Move-Item -Path $datei.FullName -Destination $zielPfad -Force
                Write-Log "Verschoben: $($datei.Name) -> $zielUnterordner\$neuerName"
                $zaehler++
                $verschobeneDateien++
            } catch {
                Write-Log "Fehler beim Verschieben von $($datei.Name): $($_.Exception.Message)" "Red"
            }
        }
        
        Write-Log "Fertig! $verschobeneDateien Datei(en) wurden sortiert und verschoben"
        Update-Status
    } catch {
        Write-Log "Fehler beim Sortieren der Dateien: $($_.Exception.Message)" "Red"
    }
}

# Event Handler
$updateButton.Add_Click({ Update-Status })
$erstellenButton.Add_Click({ New-Folders })
$sortierenButton.Add_Click({ Move-Files })
$beendenButton.Add_Click({ $form.Close() })

# Initialer Status beim Start
Write-Log "Desktop Datei-Sortierer v2.0 gestartet"
Write-Log "Autor: Nathan Dion Schmid | Projekt: LB122"
Update-Status

# Form anzeigen
$form.ShowDialog() | Out-Null