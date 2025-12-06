# More cautious approach - check existence first
# THis script sometime raise error cause by antivirus scanning
# The most simple solution is to copy and paste the script in the terminal and press enter
$services = @('DiagTrack', 'dmwappushservice', 'lfsvc')

foreach ($svc in $services) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    
    if ($service -and $service.Status -eq 'Running') {
        Stop-Service -Name $svc
    }
    
    if ($service) {
        Set-Service -Name $svc -StartupType Disabled
    }
}

# quick check
Get-Service -Name "DiagTrack", "dmwappushservice", "lfsvc" | Format-Table Name, Status, StartType -AutoSize
# verbose check
Get-Service -Name "DiagTrack", "dmwappushservice", "lfsvc" | Select-Object Name, Status, StartType, DisplayName
