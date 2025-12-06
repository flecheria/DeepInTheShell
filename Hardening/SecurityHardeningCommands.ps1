# Script Version 2: For Systems WITHOUT Third-Party Antivirus (Windows Defender Only)

# ============================================
# Windows Security Hardening Script
# For systems WITHOUT third-party antivirus
# ============================================

Write-Host "=== Windows Security Hardening (Windows Defender) ===" -ForegroundColor Cyan

# Enable Windows Defender if disabled
Write-Host "`n[0/11] Checking Windows Defender status..." -ForegroundColor Yellow
$defenderStatus = Get-MpComputerStatus
if (-not $defenderStatus.AntivirusEnabled) {
    Write-Host "Attempting to enable Windows Defender..." -ForegroundColor Yellow
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
}

# 1. Enable Windows Defender Cloud Protection
Write-Host "`n[1/11] Enabling Windows Defender Cloud Protection..." -ForegroundColor Yellow
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent SendAllSamples
Write-Host "✓ Cloud Protection enabled" -ForegroundColor Green

# 2. Enable PUA (Potentially Unwanted Applications) protection
Write-Host "`n[2/11] Enabling PUA Protection..." -ForegroundColor Yellow
Set-MpPreference -PUAProtection Enabled
Write-Host "✓ PUA Protection enabled" -ForegroundColor Green

# 3. Enable Attack Surface Reduction Rules
Write-Host "`n[3/11] Enabling Attack Surface Reduction Rules..." -ForegroundColor Yellow
$asrRules = @{
    "BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550" = "Enabled" # Block executable content from email client and webmail
    "D4F940AB-401B-4EFC-AADC-AD5F3C50688A" = "Enabled" # Block Office apps from creating child processes
    "3B576869-A4EC-4529-8536-B80A7769E899" = "Enabled" # Block Office apps from creating executable content
    "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84" = "Enabled" # Block Office apps from injecting into other processes
    "D3E037E1-3EB8-44C8-A917-57927947596D" = "Enabled" # Block JavaScript/VBScript from launching downloaded content
    "5BEB7EFE-FD9A-4556-801D-275E5FFC04CC" = "Enabled" # Block execution of potentially obfuscated scripts
    "92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B" = "Enabled" # Block Win32 API calls from Office macros
    "01443614-CD74-433A-B99E-2ECDC07BFC25" = "Enabled" # Block executable files from running unless they meet criteria
    "C1DB55AB-C21A-4637-BB3F-A12568109D35" = "Enabled" # Use advanced protection against ransomware
    "9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2" = "Enabled" # Block credential stealing from lsass.exe
    "D1E49AAC-8F56-4280-B9BA-993A6D77406C" = "Enabled" # Block process creations from PSExec and WMI
    "B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4" = "Enabled" # Block untrusted/unsigned processes from USB
    "26190899-1602-49E8-8B27-EB1D0A1CE869" = "Enabled" # Block Office communication apps from creating child processes
    "7674BA52-37EB-4A4F-A9A1-F0F9A1619A2C" = "Enabled" # Block Adobe Reader from creating child processes
    "E6DB77E5-3DF2-4CF1-B95A-636979351E5B" = "Enabled" # Block persistence through WMI
}

foreach ($rule in $asrRules.GetEnumerator()) {
    Add-MpPreference -AttackSurfaceReductionRules_Ids $rule.Key -AttackSurfaceReductionRules_Actions $rule.Value -ErrorAction SilentlyContinue
}
Write-Host "✓ Attack Surface Reduction Rules enabled" -ForegroundColor Green

# 4. Enable Controlled Folder Access (Ransomware protection)
Write-Host "`n[4/11] Enabling Controlled Folder Access..." -ForegroundColor Yellow
Set-MpPreference -EnableControlledFolderAccess Enabled
Write-Host "✓ Controlled Folder Access enabled" -ForegroundColor Green

# 5-11: Same PowerShell logging and other hardening as Version 1
Write-Host "`n[5/11] Enabling PowerShell Script Block Logging..." -ForegroundColor Yellow
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name "EnableScriptBlockLogging" -Value 1 -Type DWord
Write-Host "✓ PowerShell Script Block Logging enabled" -ForegroundColor Green

Write-Host "`n[6/11] Enabling PowerShell Module Logging..." -ForegroundColor Yellow
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

Write-Host "`n[7/11] Enabling PowerShell Transcription..." -ForegroundColor Yellow
$transcriptPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription"
if (-not (Test-Path $transcriptPath)) {
    New-Item -Path $transcriptPath -Force | Out-Null
}
Set-ItemProperty -Path $transcriptPath -Name "EnableTranscripting" -Value 1 -Type DWord
Set-ItemProperty -Path $transcriptPath -Name "EnableInvocationHeader" -Value 1 -Type DWord
Set-ItemProperty -Path $transcriptPath -Name "OutputDirectory" -Value "C:\PowerShellLogs" -Type String
if (-not (Test-Path "C:\PowerShellLogs")) {
    New-Item -Path "C:\PowerShellLogs" -ItemType Directory -Force | Out-Null
}
Write-Host "✓ PowerShell Transcription enabled" -ForegroundColor Green

Write-Host "`n[8/11] Disabling SMBv1..." -ForegroundColor Yellow
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Write-Host "✓ SMBv1 disabled" -ForegroundColor Green

Write-Host "`n[9/11] Ensuring Windows Firewall is enabled..." -ForegroundColor Yellow
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Write-Host "✓ Windows Firewall enabled" -ForegroundColor Green

Write-Host "`n[10/11] Disabling LLMNR..." -ForegroundColor Yellow
$llmnrPath = "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient"
if (-not (Test-Path $llmnrPath)) {
    New-Item -Path $llmnrPath -Force | Out-Null
}
Set-ItemProperty -Path $llmnrPath -Name "EnableMulticast" -Value 0 -Type DWord
Write-Host "✓ LLMNR disabled" -ForegroundColor Green

Write-Host "`n[11/11] Enabling LSA Protection..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 1 -Type DWord
Write-Host "✓ LSA Protection enabled" -ForegroundColor Green

Write-Host "`n=== Hardening Complete ===" -ForegroundColor Cyan
Write-Host "Note: Reboot required for some changes to take effect." -ForegroundColor Yellow