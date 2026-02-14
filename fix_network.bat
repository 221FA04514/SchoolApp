@echo off
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo This script requires Administrator privileges.
    echo Right-click and select "Run as administrator".
    pause
    exit /b
)

echo Setting Network Profile to Private...
powershell -Command "Set-NetConnectionProfile -NetworkCategory Private"

echo Adding Firewall Rule for Port 5000...
netsh advfirewall firewall delete rule name="Allow Node Port 5000" >nul 2>&1
netsh advfirewall firewall add rule name="Allow Node Port 5000" dir=in action=allow protocol=TCP localport=5000

echo.
echo ==========================================
echo SUCCESS! Network is now Private and Port 5000 is open.
echo Please restart your app and try to login.
echo ==========================================
pause
