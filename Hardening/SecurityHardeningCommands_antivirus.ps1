# Script Version 1: For Systems WITH Third-Party Antivirus

# ============================================
# Windows Security Hardening Script
# For systems WITH third-party antivirus
# ============================================

Write-Host "=== Windows Security Hardening (Bitdefender/3rd Party AV) ===" -ForegroundColor Cyan

# 1. Enable PowerShell Script Block Logging
Write-Host "`n[1/8] Enabling PowerShell Script Block Logging..." -ForegroundColor Yellow
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name "EnableScriptBlockLogging" -Value 1 -Type DWord
Write-Host "✓ PowerShell Script Block Logging enabled" -ForegroundColor Green

# 2. Enable PowerShell Module Logging
Write-Host "`n[2/8] Enabling PowerShell Module Logging..." -ForegroundColor Yellow
$moduleLogPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
if (-not (Test-Path $moduleLogPath)) {
    New-Item -Path $moduleLogPath -Force | Out-Null
}
Set-ItemProperty -Path $moduleLogPath -Name "EnableModuleLogging" -Value 1 -Type DWord

$moduleNamesPath = "$moduleLogPath\ModuleNames"
if (-not (Test-Path $moduleNamesPath)) {
    New-Item -Path $moduleNamesPath -Force | Out-Null
}
Set-ItemProperty -Path $moduleNamesPath -Name "*" -Value "*" -Type String
Write-Host "✓ PowerShell Module Logging enabled" -ForegroundColor Green

# 3. Enable PowerShell Transcription
Write-Host "`n[3/8] Enabling PowerShell Transcription..." -ForegroundColor Yellow
$transcriptPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription"
if (-not (Test-Path $transcriptPath)) {
    New-Item -Path $transcriptPath -Force | Out-Null
}
Set-ItemProperty -Path $transcriptPath -Name "EnableTranscripting" -Value 1 -Type DWord
Set-ItemProperty -Path $transcriptPath -Name "EnableInvocationHeader" -Value 1 -Type DWord
Set-ItemProperty -Path $transcriptPath -Name "OutputDirectory" -Value "C:\PowerShellLogs" -Type String

# Create log directory
if (-not (Test-Path "C:\PowerShellLogs")) {
    New-Item -Path "C:\PowerShellLogs" -ItemType Directory -Force | Out-Null
}
Write-Host "✓ PowerShell Transcription enabled (logs: C:\PowerShellLogs)" -ForegroundColor Green

# 4. Disable SMBv1 (major security vulnerability)
Write-Host "`n[4/8] Disabling SMBv1..." -ForegroundColor Yellow
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Write-Host "✓ SMBv1 disabled" -ForegroundColor Green

# 5. Enable Windows Firewall for all profiles
Write-Host "`n[5/8] Ensuring Windows Firewall is enabled..." -ForegroundColor Yellow
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Write-Host "✓ Windows Firewall enabled for all profiles" -ForegroundColor Green

# 6. Disable LLMNR (Link-Local Multicast Name Resolution) - credential theft vector
Write-Host "`n[6/8] Disabling LLMNR..." -ForegroundColor Yellow
$llmnrPath = "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient"
if (-not (Test-Path $llmnrPath)) {
    New-Item -Path $llmnrPath -Force | Out-Null
}
Set-ItemProperty -Path $llmnrPath -Name "EnableMulticast" -Value 0 -Type DWord
Write-Host "✓ LLMNR disabled" -ForegroundColor Green

# 7. Enable LSA Protection (prevent credential dumping)
Write-Host "`n[7/8] Enabling LSA Protection..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 1 -Type DWord
Write-Host "✓ LSA Protection enabled (requires reboot)" -ForegroundColor Green

# 8. Disable AutoRun/AutoPlay (malware prevention)
Write-Host "`n[8/8] Disabling AutoRun/AutoPlay..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255 -Type DWord
Write-Host "✓ AutoRun/AutoPlay disabled" -ForegroundColor Green

Write-Host "`n=== Hardening Complete ===" -ForegroundColor Cyan
Write-Host "Note: Some changes require a system reboot to take effect." -ForegroundColor Yellow