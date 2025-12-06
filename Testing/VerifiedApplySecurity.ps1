# Verify applied security settings
Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled, AntivirusEnabled, AntispywareEnabled

# Check firewall status
Get-NetFirewallProfile | Select-Object Name, Enabled

# List all running services
Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object DisplayName, Status