# Enable Windows Defender Application Guard (enterprise feature)
Enable-WindowsOptionalFeature -Online -FeatureName "Windows-Defender-ApplicationGuard" -NoRestart

# Configure Windows Defender Firewall with advanced logging
Set-NetFirewallProfile -Profile Domain,Public,Private -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log -LogMaxSizeKilobytes 16384 -LogAllowed True -LogBlocked True

# Enable LSA Protection (requires UEFI lock)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Type DWord -Value 1