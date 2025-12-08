# Stop Sysmon service
Write-Host "`nStopping Sysmon service..." -ForegroundColor Cyan

try {
    Stop-Service -Name Sysmon* -Force -ErrorAction Stop
    Write-Host "✓ Sysmon service stopped" -ForegroundColor Green
} catch {
    Write-Host "⚠ Error stopping service: $_" -ForegroundColor Yellow
    Write-Host "  Service may already be stopped or will be stopped during uninstall" -ForegroundColor Gray
}

# Verify service is stopped
$service = Get-Service Sysmon* -ErrorAction SilentlyContinue
if ($service.Status -eq "Stopped") {
    Write-Host "✓ Service status: Stopped" -ForegroundColor Green
} else {
    Write-Host "Service status: $($service.Status)" -ForegroundColor Yellow
}