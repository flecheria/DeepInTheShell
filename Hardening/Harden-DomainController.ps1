#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Security hardening for Active Directory Domain Controller
.DESCRIPTION
    Configures domain password policy and local security settings
    Must be run on a Domain Controller with appropriate permissions
.PARAMETER DomainName
    Your Active Directory domain name (e.g., domain.local)
.PARAMETER ApplyChanges
    Actually apply changes (default is preview only)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DomainName,
    
    [Parameter()]
    [switch]$ApplyChanges
)

Write-Host "[Domain Controller Security Hardening]" -ForegroundColor Cyan

# Verify we're on a DC
Write-Host "`nVerifying environment..." -ForegroundColor Yellow
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    $isDC = (Get-WmiObject -Class Win32_ComputerSystem).DomainRole -ge 4
    
    if (!$isDC) {
        Write-Host "[✗] This script must run on a Domain Controller" -ForegroundColor Red
        exit 1
    }
    Write-Host "[✓] Running on Domain Controller" -ForegroundColor Green
}
catch {
    Write-Host "[✗] Active Directory module not available: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Preview current policy
Write-Host "`nCurrent Domain Password Policy:" -ForegroundColor Yellow
try {
    $currentPolicy = Get-ADDefaultDomainPasswordPolicy -Identity $DomainName
    $currentPolicy | Select-Object ComplexityEnabled, LockoutDuration, LockoutThreshold, 
                                   MaxPasswordAge, MinPasswordAge, MinPasswordLength, 
                                   PasswordHistoryCount | Format-List
}
catch {
    Write-Host "[!] Could not retrieve current policy: $($_.Exception.Message)" -ForegroundColor Yellow
}

if (!$ApplyChanges) {
    Write-Host "`n[Preview Mode]" -ForegroundColor Yellow
    Write-Host "Changes that WOULD be applied:" -ForegroundColor Yellow
    Write-Host "  - ComplexityEnabled: True"
    Write-Host "  - LockoutDuration: 30 minutes"
    Write-Host "  - LockoutObservationWindow: 30 minutes"
    Write-Host "  - LockoutThreshold: 5 attempts"
    Write-Host "  - MaxPasswordAge: 90 days"
    Write-Host "  - MinPasswordAge: 1 day"
    Write-Host "  - MinPasswordLength: 14 characters"
    Write-Host "  - PasswordHistoryCount: 24"
    Write-Host "  - ReversibleEncryptionEnabled: False"
    Write-Host "  - UAC: Prompt on secure desktop"
    Write-Host "`nRe-run with -ApplyChanges to apply" -ForegroundColor Cyan
    exit 0
}

# Apply domain password policy
Write-Host "`nApplying domain password policy..." -ForegroundColor Yellow
try {
    Set-ADDefaultDomainPasswordPolicy -Identity $DomainName `
        -ComplexityEnabled $true `
        -LockoutDuration 00:30:00 `
        -LockoutObservationWindow 00:30:00 `
        -LockoutThreshold 5 `
        -MaxPasswordAge 90.00:00:00 `
        -MinPasswordAge 1.00:00:00 `
        -MinPasswordLength 14 `
        -PasswordHistoryCount 24 `
        -ReversibleEncryptionEnabled $false `
        -ErrorAction Stop
    
    Write-Host "[✓] Domain password policy applied" -ForegroundColor Green
}
catch {
    Write-Host "[✗] Failed to apply password policy: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Configure local UAC
Write-Host "`nConfiguring local UAC..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 2
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "PromptOnSecureDesktop" -Type DWord -Value 1
Write-Host "[✓] UAC configured" -ForegroundColor Green

# Verify changes
Write-Host "`nVerifying applied settings..." -ForegroundColor Yellow
$newPolicy = Get-ADDefaultDomainPasswordPolicy -Identity $DomainName
Write-Host "`nNew Domain Password Policy:" -ForegroundColor Cyan
$newPolicy | Select-Object ComplexityEnabled, LockoutDuration, LockoutThreshold, 
                           MaxPasswordAge, MinPasswordAge, MinPasswordLength, 
                           PasswordHistoryCount, ReversibleEncryptionEnabled | Format-List

$uac = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
Write-Host "Local UAC Settings:" -ForegroundColor Cyan
Write-Host "  ConsentPromptBehaviorAdmin: $($uac.ConsentPromptBehaviorAdmin)"
Write-Host "  PromptOnSecureDesktop: $($uac.PromptOnSecureDesktop)"

Write-Host "`n[✓] Domain Controller hardening complete" -ForegroundColor Green
Write-Host "`nNote: Changes will replicate to other DCs automatically" -ForegroundColor Yellow
Write-Host "Run Harden-DomainWorkstation.ps1 on workstations to verify" -ForegroundColor Yellow