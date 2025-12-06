#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Security hardening for standalone/workgroup Windows PC
.DESCRIPTION
    Configures local security policies (no Active Directory required)
#>

[CmdletBinding()]
param()

Write-Host "[Standalone PC Security Hardening]" -ForegroundColor Cyan

# Configure UAC
Write-Host "`nConfiguring UAC..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 2
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "PromptOnSecureDesktop" -Type DWord -Value 1
Write-Host "[✓] UAC configured" -ForegroundColor Green

# Local password policy (via secedit)
Write-Host "`nConfiguring local password policy..." -ForegroundColor Yellow
$secPolicy = @"
[Unicode]
Unicode=yes
[System Access]
MinimumPasswordAge = 1
MaximumPasswordAge = 90
MinimumPasswordLength = 14
PasswordComplexity = 1
PasswordHistorySize = 24
LockoutBadCount = 5
ResetLockoutCount = 30
LockoutDuration = 30
ClearTextPassword = 0
[Version]
signature="`$CHICAGO`$"
Revision=1
"@

$tempFile = "$env:TEMP\secpol.cfg"
$secPolicy | Out-File $tempFile -Encoding unicode

secedit /configure /db secedit.sdb /cfg $tempFile /areas SECURITYPOLICY | Out-Null
Remove-Item $tempFile -Force

Write-Host "[✓] Password policy configured" -ForegroundColor Green

# Verify
Write-Host "`nVerifying settings..." -ForegroundColor Yellow
$uac = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
Write-Host "  UAC Admin Prompt: $($uac.ConsentPromptBehaviorAdmin)"
Write-Host "  Secure Desktop: $($uac.PromptOnSecureDesktop)"
Write-Host "`n[✓] Hardening complete" -ForegroundColor Green