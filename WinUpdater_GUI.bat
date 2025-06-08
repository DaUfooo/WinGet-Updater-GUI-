@echo off
@echo Windows Update CMD - By DaUfooo

:: Überprüfe, ob das Skript mit Administratorrechten ausgeführt wird
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Dieses Skript erfordert Administratorrechte. Es wird jetzt mit Administratorrechten neu gestartet...
    :: Starte das Skript mit Administratorrechten neu
    "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb runAs"
    exit /b
)

:: Setze die PowerShell ExecutionPolicy auf RemoteSigned
echo Setze die PowerShell ExecutionPolicy auf RemoteSigned...
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"

:: Überprüfe, ob der Befehl erfolgreich war
if %ERRORLEVEL% neq 0 (
    echo Fehler: Der Befehl "Set-ExecutionPolicy RemoteSigned" konnte nicht erfolgreich ausgefuehrt werden.
    pause
    exit /b
)

:: Informiere den Benutzer, dass die Policy gesetzt wurde
echo Die ExecutionPolicy wurde erfolgreich auf RemoteSigned gesetzt.

:: Starte das PowerShell Skript
echo Starte das Windows Update GUI Skript...
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy RemoteSigned -File "%~dp0Windows_Update_GUI.ps1"

:: Warte, bis das PowerShell-Skript beendet ist, und halte das Fenster offen
pause

//By DaUfooo 2025
