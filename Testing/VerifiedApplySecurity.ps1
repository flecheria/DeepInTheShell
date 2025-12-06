# get complete computer status
Get-MpComputerStatus

# Security status
Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled, AntivirusEnabled, AntispywareEnabled

# Firewall
Get-NetFirewallProfile | Select-Object Name, Enabled

# Running services - use WMI for enumeration
Get-WmiObject -Class Win32_Service -Filter "State='Running'" | 
    Select-Object DisplayName, State

# Specific services - Get-Service works fine here
Get-Service -Name "DiagTrack", "dmwappushservice", "lfsvc" -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType, DisplayName