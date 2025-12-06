#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Verify current security settings on any Windows system
.DESCRIPTION
    Checks UAC, password policy, and domain policy (if applicable)
#>

[CmdletBinding()]
param()

Write-Host "=== Windows Security Settings Verification ===" -ForegroundColor Cyan

# Detect environment
$computerSystem = Get-WmiObject Win32_ComputerSystem
$isDC = $computerSystem.DomainRole -ge 4
$isDomainJoined = $computerSystem.PartOfDomain

Write-Host "`nEnvironment: " -NoNewline
if ($isDC) { 
    Write-Host "Domain Controller" -ForegroundColor Green 
}
elseif ($isDomainJoined) { 
    Write-Host "Domain-Joined Workstation" -ForegroundColor Yellow 
}
else { 
    Write-Host "Standalone/Workgroup PC" -ForegroundColor Cyan 
}

# Check UAC
Write-Host "`n--- UAC Settings ---" -ForegroundColor Yellow
$uac = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
Write-Host "ConsentPromptBehaviorAdmin: $($uac.ConsentPromptBehaviorAdmin) $(if($uac.ConsentPromptBehaviorAdmin -eq 2){'✓'}else{'✗'})"
Write-Host "PromptOnSecureDesktop: $($uac.PromptOnSecureDesktop) $(if($uac.PromptOnSecureDesktop -eq 1){'✓'}else{'✗'})"

# Local password policy
Write-Host "`n--- Local Password Policy ---" -ForegroundColor Yellow
$output = net accounts 2>&1
if ($LASTEXITCODE -eq 0) {
    $output | Select-String "Minimum password length|Maximum password age|Lockout threshold|Lockout duration"
}
else {
    Write-Host "Could not retrieve local policy"
}

# Domain password policy (if applicable)
if ($isDomainJoined) {
    Write-Host "`n--- Domain Password Policy ---" -ForegroundColor Yellow
    if (Get-Module -ListAvailable ActiveDirectory) {
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
            $domain = $computerSystem.Domain
            $policy = Get-ADDefaultDomainPasswordPolicy -Identity $domain -ErrorAction Stop
            
            Write-Host "Domain: $domain"
            Write-Host "Min Length: $($policy.MinPasswordLength) $(if($policy.MinPasswordLength -ge 14){'✓'}else{'✗ (should be 14+)'})"
            Write-Host "Complexity: $($policy.ComplexityEnabled) $(if($policy.ComplexityEnabled){'✓'}else{'✗'})"
            Write-Host "Max Age: $($policy.MaxPasswordAge.Days) days $(if($policy.MaxPasswordAge.Days -le 90){'✓'}else{'✗ (should be ≤90)'})"
            Write-Host "Lockout Threshold: $($policy.LockoutThreshold) $(if($policy.LockoutThreshold -eq 5){'✓'}else{'✗ (should be 5)'})"
            Write-Host "History: $($policy.PasswordHistoryCount) $(if($policy.PasswordHistoryCount -ge 24){'✓'}else{'✗ (should be 24+)'})"
        }
        catch {
            Write-Host "Could not query domain policy: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Active Directory module not available (install RSAT)" -ForegroundColor Yellow
    }
}

Write-Host "`n=== Verification Complete ===" -ForegroundColor Cyan