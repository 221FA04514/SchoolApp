if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    Pause
    Exit
}

Write-Host "Adding Firewall Rule for Port 5000..." -ForegroundColor Cyan

try {
    New-NetFirewallRule -DisplayName "Allow Node Port 5000" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow -ErrorAction Stop
    Write-Host "Success! Firewall rule added." -ForegroundColor Green
} catch {
    Write-Host "Error adding firewall rule: $_" -ForegroundColor Red
}

Pause
