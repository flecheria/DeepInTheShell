# SecurityStatusCheck.ps1

Write-Host "`n=== ANTIVIRUS STATUS ===" -ForegroundColor Cyan
$defender = Get-MpComputerStatus
[PSCustomObject]@{
    DefenderRunning = $defender.AMRunningMode
    DefenderEnabled = $defender.AMServiceEnabled
    ProductStatus = $defender.ProductStatus
}

# Use WMI to avoid enumeration error
$bitdefender = Get-WmiObject -Class Win32_Service -Filter "State='Running'" | 
    Where-Object {$_.Name -like "*bd*"}
Write-Host "`nBitDefender Services Running: $($bitdefender.Count)" -ForegroundColor $(if($bitdefender.Count -gt 0){"Green"}else{"Red"})

Write-Host "`n=== FIREWALL STATUS ===" -ForegroundColor Cyan
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table

Write-Host "=== TELEMETRY SERVICES ===" -ForegroundColor Cyan
Get-Service -Name "DiagTrack", "dmwappushservice", "lfsvc" | 
    Select-Object DisplayName, Status, StartType | Format-Table

Write-Host "=== RISKY SERVICES ===" -ForegroundColor Cyan
$riskyServices = @("Spooler", "TermService", "W3SVC", "SSHD", "ssh-agent")
Get-Service -Name $riskyServices -ErrorAction SilentlyContinue | 
    Select-Object DisplayName, Status, StartType | Format-Table

Write-Host "=== RDP EXPOSURE ===" -ForegroundColor Cyan
$rdp = Get-NetTCPConnection -LocalPort 3389 -State Listen -ErrorAction SilentlyContinue
if ($rdp) {
    Write-Host "RDP is LISTENING on port 3389" -ForegroundColor Red
} else {
    Write-Host "RDP not exposed" -ForegroundColor Green
}