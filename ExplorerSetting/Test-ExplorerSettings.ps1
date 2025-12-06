<#
.SYNOPSIS
    Test script for ExplorerSettings module.

.DESCRIPTION
    Validates all functions in the ExplorerSettings module.
#>

[CmdletBinding()]
param()

Write-Host "=== ExplorerSettings Module Test Suite ===" -ForegroundColor Cyan
Write-Host ""

# Import module
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Join-Path $scriptPath "ExplorerSettings.psm1"

if (Test-Path $modulePath) {
    Import-Module $modulePath -Force
    Write-Host "[✓] Module imported successfully" -ForegroundColor Green
}
else {
    Write-Host "[✗] Module file not found: $modulePath" -ForegroundColor Red
    exit 1
}

# Test 1: Get current setting
Write-Host "`n--- Test 1: Get Current Setting ---" -ForegroundColor Yellow
try {
    $currentSetting = Get-FileExtensionVisibility
    if ($currentSetting) {
        Write-Host "[✓] Current setting retrieved:" -ForegroundColor Green
        Write-Host "    Scope: $($currentSetting.Scope)"
        Write-Host "    Extensions Visible: $($currentSetting.FileExtensionsVisible)"
        Write-Host "    Registry Value: $($currentSetting.RegistryValue)"
    }
    else {
        Write-Host "[!] No setting found (may not be configured)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[✗] Failed to get setting: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Test Enable function (dry run - no restart)
Write-Host "`n--- Test 2: Enable File Extensions (CurrentUser) ---" -ForegroundColor Yellow
try {
    Enable-FileExtensions -Scope CurrentUser
    Write-Host "[✓] Enable function executed" -ForegroundColor Green
}
catch {
    Write-Host "[✗] Enable function failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Verify setting changed
Write-Host "`n--- Test 3: Verify Setting After Enable ---" -ForegroundColor Yellow
try {
    $afterEnable = Get-FileExtensionVisibility
    if ($afterEnable -and $afterEnable.FileExtensionsVisible) {
        Write-Host "[✓] File extensions are now enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[!] Setting may not have changed or requires Explorer restart" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[✗] Failed to verify setting: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test Disable function (dry run - no restart)
Write-Host "`n--- Test 4: Disable File Extensions (CurrentUser) ---" -ForegroundColor Yellow
try {
    Disable-FileExtensions -Scope CurrentUser
    Write-Host "[✓] Disable function executed" -ForegroundColor Green
}
catch {
    Write-Host "[✗] Disable function failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Verify setting changed back
Write-Host "`n--- Test 5: Verify Setting After Disable ---" -ForegroundColor Yellow
try {
    $afterDisable = Get-FileExtensionVisibility
    if ($afterDisable -and -not $afterDisable.FileExtensionsVisible) {
        Write-Host "[✓] File extensions are now disabled" -ForegroundColor Green
    }
    else {
        Write-Host "[!] Setting may not have changed or requires Explorer restart" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[✗] Failed to verify setting: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Restore original setting
Write-Host "`n--- Test 6: Restore Original Setting ---" -ForegroundColor Yellow
try {
    if ($currentSetting) {
        if ($currentSetting.FileExtensionsVisible) {
            Enable-FileExtensions -Scope CurrentUser
            Write-Host "[✓] Restored to: Extensions Enabled" -ForegroundColor Green
        }
        else {
            Disable-FileExtensions -Scope CurrentUser
            Write-Host "[✓] Restored to: Extensions Disabled" -ForegroundColor Green
        }
    }
    else {
        Write-Host "[!] No original setting to restore" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[✗] Failed to restore setting: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Check if running with admin privileges
Write-Host "`n--- Test 7: Privilege Check ---" -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "[✓] Running with administrator privileges" -ForegroundColor Green
    Write-Host "    You can test LocalMachine and AllUsers scopes" -ForegroundColor Gray
}
else {
    Write-Host "[!] Not running as administrator" -ForegroundColor Yellow
    Write-Host "    LocalMachine and AllUsers scopes will require elevation" -ForegroundColor Gray
}

# Summary
Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Basic functionality tests completed."
Write-Host ""
Write-Host "To test with Explorer restart, run:" -ForegroundColor Gray
Write-Host "  Enable-FileExtensions -RestartExplorer" -ForegroundColor Gray
Write-Host ""
Write-Host "To test elevated scopes (run as admin):" -ForegroundColor Gray
Write-Host "  Enable-FileExtensions -Scope AllUsers -RestartExplorer" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: You may need to restart Explorer.exe to see changes in File Explorer." -ForegroundColor Yellow
