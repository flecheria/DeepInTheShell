# Disable SMBv1 (extremely vulnerable protocol)
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart

# Disable LLMNR (Link-Local Multicast Name Resolution)
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Type DWord -Value 0

# Disable NetBIOS over TCP/IP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" -Name "NetbiosOptions" -Type DWord -Value 2