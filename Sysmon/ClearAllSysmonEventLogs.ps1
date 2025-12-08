# Clear Sysmon event log
Write-Host "`nClearing Sysmon event log..." -ForegroundColor Cyan

try {
    # Method 1: Using wevtutil (more reliable)
    wevtutil cl Microsoft-Windows-Sysmon/Operational
    Write-Host "✓ Event log cleared using wevtutil" -ForegroundColor Green
} catch {
    Write-Host "⚠ wevtutil failed, trying alternative method..." -ForegroundColor Yellow
    
    try {
        # Method 2: Using Clear-EventLog (older method)
        wevtutil cl "Microsoft-Windows-Sysmon/Operational"
        Write-Host "✓ Event log cleared" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to clear event log: $_" -ForegroundColor Red
    }
}

# Verify log is empty
Start-Sleep -Seconds 2
$log = Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational"
if ($log.RecordCount -eq 0) {
    Write-Host "✓ Event log is now empty (0 events)" -ForegroundColor Green
} else {
    Write-Host "⚠ Event log still contains $($log.RecordCount) events" -ForegroundColor Yellow
}