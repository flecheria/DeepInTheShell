#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Security hardening for domain-joined workstation
.DESCRIPTION
    Configures local policies and verifies domain password policy
    Requires RSAT Active Directory tools
.PARAMETER DomainName
    Your Active Directory domain name (e.g., domain.local)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DomainName
)

Write-Host "[Domain-Joined Workstation Security Hardening]" -ForegroundColor Cyan

# Check if RSAT is installed
Write-Host "`nChecking for AD module..." -ForegroundColor Yellow
if (!(Get-Module -ListAvailable ActiveDirectory)) {
    Write-Host "[!] Active Directory module not found" -ForegroundColor Yellow
    Write-Host "Installing RSAT tools..." -ForegroundColor Yellow
    
    try {
        Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -ErrorAction Stop
        Write-Host "[✓] RSAT installed" -ForegroundColor Green
    }
    catch {
        Write-Host "[✗] Failed to install RSAT: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Manual install: Settings > Apps > Optional Features > RSAT: Active Directory" -ForegroundColor Yellow
        exit 1
    }
}

Import-Module ActiveDirectory

# Configure local UAC
Write-Host "`nConfiguring local UAC..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 2
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "PromptOnSecureDesktop" -Type DWord -Value 1
Write-Host "[✓] UAC configured" -ForegroundColor Green

# Verify domain password policy (read-only from workstation)
Write-Host "`nChecking domain password policy..." -ForegroundColor Yellow
try {
    $policy = Get-ADDefaultDomainPasswordPolicy -Identity $DomainName -ErrorAction Stop
    
    Write-Host "`nCurrent Domain Password Policy:" -ForegroundColor Cyan
    Write-Host "  Complexity Required: $($policy.ComplexityEnabled)"
    Write-Host "  Min Length: $($policy.MinPasswordLength)"
    Write-Host "  Max Age: $($policy.MaxPasswordAge.Days) days"
    Write-Host "  Min Age: $($policy.MinPasswordAge.Days) days"
    Write-Host "  Lockout Threshold: $($policy.LockoutThreshold) attempts"
    Write-Host "  Lockout Duration: $($policy.LockoutDuration.TotalMinutes) minutes"
    Write-Host "  History Count: $($policy.PasswordHistoryCount)"
    
    # Warn if not compliant
    $warnings = @()
    if ($policy.MinPasswordLength -lt 14) { $warnings += "Min password length < 14" }
    if ($policy.MaxPasswordAge.Days -gt 90) { $warnings += "Max password age > 90 days" }
    if (!$policy.ComplexityEnabled) { $warnings += "Complexity not enabled" }
    if ($policy.LockoutThreshold -eq 0 -or $policy.LockoutThreshold -gt 5) { $warnings += "Lockout threshold not 5" }
    
    if ($warnings.Count -gt 0) {
        Write-Host "`n[!] Policy warnings:" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        Write-Host "`nTo fix: Run Harden-DomainController.ps1 on your DC" -ForegroundColor Yellow
    }
    else {
        Write-Host "`n[✓] Domain policy compliant" -ForegroundColor Green
    }
}
catch {
    Write-Host "[!] Could not query domain policy: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Ensure you have AD read permissions" -ForegroundColor Yellow
}

Write-Host "`n[✓] Workstation hardening complete" -ForegroundColor Green