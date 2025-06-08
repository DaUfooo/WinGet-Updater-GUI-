# Windows Update GUI (Erstellt von DaUfooo 2025)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Bestimme den Ordner des Skripts
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFilePath = Join-Path -Path $scriptDir -ChildPath "update_log.txt"

# Erstelle das Fenster
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Windows Update GUI (DaUfooo)"
$Form.Size = New-Object System.Drawing.Size(400,400)

# Erstelle einen Button für das Update
$Button = New-Object System.Windows.Forms.Button
$Button.Size = New-Object System.Drawing.Size(300, 40)
$Button.Location = New-Object System.Drawing.Point(25, 50)
$Button.Text = "Alle Pakete Updaten"
$Button.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$Button.BackColor = [System.Drawing.Color]::MediumSeaGreen
$Button.ForeColor = [System.Drawing.Color]::Black

# Fortschrittsanzeige (ProgressBar)
$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Size = New-Object System.Drawing.Size(350, 30)
$ProgressBar.Location = New-Object System.Drawing.Point(25, 120)
$ProgressBar.Minimum = 0
$ProgressBar.Maximum = 100
$ProgressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous

# Erstelle einen Button für das Abbrechen
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Size = New-Object System.Drawing.Size(300, 40)
$CancelButton.Location = New-Object System.Drawing.Point(25, 170)
$CancelButton.Text = "Abbrechen"
$CancelButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$CancelButton.BackColor = [System.Drawing.Color]::Salmon
$CancelButton.ForeColor = [System.Drawing.Color]::Black

# Status-Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Size = New-Object System.Drawing.Size(350, 30)
$statusLabel.Location = New-Object System.Drawing.Point(25, 220)
$statusLabel.Text = "Klicke auf 'Alle Pakete Updaten' um die Updates zu starten."
$statusLabel.Font = New-Object System.Drawing.Font("Arial", 10)
$statusLabel.ForeColor = [System.Drawing.Color]::Black
$statusLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

# Ladeanzeige
$loadingLabel = New-Object System.Windows.Forms.Label
$loadingLabel.Size = New-Object System.Drawing.Size(350, 30)
$loadingLabel.Location = New-Object System.Drawing.Point(25, 50)
$loadingLabel.Text = "Lade Updates... Bitte warten."
$loadingLabel.Font = New-Object System.Drawing.Font("Arial", 12)
$loadingLabel.ForeColor = [System.Drawing.Color]::Black
$loadingLabel.Visible = $false

# Log-Textfeld
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$logBox.Size = New-Object System.Drawing.Size(350, 100)
$logBox.Location = New-Object System.Drawing.Point(25, 260)

# Administrator Hinweis
$adminLabel = New-Object System.Windows.Forms.Label
$adminLabel.Size = New-Object System.Drawing.Size(350, 30)
$adminLabel.Location = New-Object System.Drawing.Point(25, 360)
$adminLabel.Text = "Bitte als Administrator ausführen."
$adminLabel.Font = New-Object System.Drawing.Font("Arial", 10)
$adminLabel.ForeColor = [System.Drawing.Color]::Red
$adminLabel.Visible = $false

# Event für den Update-Button
$Button.Add_Click({
    # Ladeanzeige anzeigen
    $loadingLabel.Visible = $true

    # Status aktualisieren
    $statusLabel.Text = "Starte das Update... Bitte Warten!"
    $logBox.AppendText("Starte Update: $(Get-Date)`r`n")
    # Zeige an, dass Logs geschrieben werden
    $logBox.AppendText("Log wird geschrieben...`r`n")
    $logBox.SelectionStart = $logBox.Text.Length
    $logBox.ScrollToCaret()

    # Schreibe Log in Datei
    Add-Content -Path $logFilePath -Value "Starte Update: $(Get-Date)`r`n"
    Add-Content -Path $logFilePath -Value "Log wird geschrieben...`r`n"

    # Windows Update im Hintergrund ausführen
    try {
        # Starte den Update-Prozess und hole die Pakete
        $process = Start-Process "winget" -ArgumentList "upgrade", "--all", "--include-unknown" -NoNewWindow -PassThru -Wait

        # Überprüfe die Liste der aktualisierten Pakete (wenn das System die Updates ausgibt)
        $updates = winget upgrade --all --include-unknown

        # Falls Updates vorhanden sind
        if ($updates) {
            foreach ($update in $updates) {
                $updateName = $update.PackageName
                $oldVersion = $update.OldVersion
                $newVersion = $update.NewVersion
                $statusLabel.Text = "Update für $($updateName): $($oldVersion) → $($newVersion)"

                # Log-Eintrag für erfolgreiches Update
                $logBox.AppendText("Update für $($updateName): $($oldVersion) → $($newVersion)`r`n")
                Add-Content -Path $logFilePath -Value "Update für $($updateName): $($oldVersion) → $($newVersion)`r`n"
            }
        } else {
            $logBox.AppendText("Keine Updates gefunden.`r`n")
            Add-Content -Path $logFilePath -Value "Keine Updates gefunden.`r`n"
        }

        # Eventuell während der Ausführung Informationen über den Fortschritt abgreifen
        # In diesem Fall eine einfache Simulation für den Fortschritt
        $ProgressBar.Value = 10
        Start-Sleep -Seconds 1
        $ProgressBar.Value = 30
        Start-Sleep -Seconds 1
        $ProgressBar.Value = 60
        Start-Sleep -Seconds 1
        $ProgressBar.Value = 100

        # Wenn der Prozess erfolgreich war
        if ($process.ExitCode -eq 0) {
            $statusLabel.Text = "Update/Upgrade abgeschlossen!"
            $logBox.AppendText("Update erfolgreich abgeschlossen: $(Get-Date)`r`n")
            Add-Content -Path $logFilePath -Value "Update erfolgreich abgeschlossen: $(Get-Date)`r`n"
            [System.Windows.Forms.MessageBox]::Show("Update/Upgrade abgeschlossen!", "Fertig!", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            $statusLabel.Text = "Fehler beim Update/Upgrade. Fehlercode: $($process.ExitCode)"
            $logBox.AppendText("Fehler beim Update: $($process.ExitCode) - $(Get-Date)`r`n")
            Add-Content -Path $logFilePath -Value "Fehler beim Update: $($process.ExitCode) - $(Get-Date)`r`n"
            [System.Windows.Forms.MessageBox]::Show("Fehler beim Update/Upgrade", "Fehler!", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } catch {
        $statusLabel.Text = "Ein Fehler ist aufgetreten: $_"
        $logBox.AppendText("Fehler: $_ - $(Get-Date)`r`n")
        Add-Content -Path $logFilePath -Value "Fehler: $_ - $(Get-Date)`r`n"
        [System.Windows.Forms.MessageBox]::Show("Ein Fehler ist aufgetreten: $_", "Fehler!", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }

    # Log Hinweis am Ende hinzufügen
    Add-Content -Path $logFilePath -Value "`r`nWindows Update GUI by DaUfooo 2025`r`n"

    # Ladeanzeige ausblenden
    $loadingLabel.Visible = $false
})

# Event für den Abbrechen-Button
$CancelButton.Add_Click({
    $statusLabel.Text = "Update abgebrochen."
    $logBox.AppendText("Update abgebrochen: $(Get-Date)`r`n")
    Add-Content -Path $logFilePath -Value "Update abgebrochen: $(Get-Date)`r`n"
    $Form.Close()
})

# Füge die Steuerelemente zum Fenster hinzu
$Form.Controls.Add($Button)
$Form.Controls.Add($CancelButton)
$Form.Controls.Add($ProgressBar)
$Form.Controls.Add($statusLabel)
$Form.Controls.Add($loadingLabel)
$Form.Controls.Add($logBox)
$Form.Controls.Add($adminLabel)

# Fensterfarbe anpassen
$Form.BackColor = [System.Drawing.Color]::Beige

# Zeige das Fenster
$Form.ShowDialog()
