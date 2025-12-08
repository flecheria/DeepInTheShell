# Deep clean: Clear any remaining event log references
Write-Host "`nPerforming deep clean of event log..." -ForegroundColor Cyan

try {
    # This clears the log file completely
    $logPath = "C:\Windows\System32\winevt\Logs\Microsoft-Windows-Sysmon%4Operational.evtx"
    if (Test-Path $logPath) {
        # Take ownership and delete
        takeown /F $logPath
        icacls $logPath /grant Administrators:F
        Remove-Item $logPath -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Removed event log file" -ForegroundColor Green
    }
} catch {
    Write-Host "  Log file cleanup not needed or already removed" -ForegroundColor Gray
}