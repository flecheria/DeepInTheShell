<#
.SYNOPSIS
    Uninstallation script for ExplorerSettings PowerShell module.

.DESCRIPTION
    Removes the ExplorerSettings module from the PowerShell modules directory.

.PARAMETER Scope
    Uninstallation scope: CurrentUser or AllUsers (requires admin)

.EXAMPLE
    .\Uninstall-ExplorerSettings.ps1
    Uninstalls from current user location

.EXAMPLE
    .\Uninstall-ExplorerSettings.ps1 -Scope AllUsers
    Uninstalls from all users location (requires admin)
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser"
)

Write-Host "=== ExplorerSettings Module Uninstallation ===" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges if uninstalling for all users
if ($Scope -eq "AllUsers") {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "[Error] Administrator privileges required for AllUsers scope" -ForegroundColor Red
        Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
        exit 1
    }
}

# Determine installation path
$moduleName = "ExplorerSettings"
$installPath = switch ($Scope) {
    "CurrentUser" {
        Join-Path $HOME "Documents\WindowsPowerShell\Modules\$moduleName"
    }
    "AllUsers" {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            Join-Path $env:ProgramFiles "PowerShell\Modules\$moduleName"
        }
        else {
            Join-Path $env:ProgramFiles "WindowsPowerShell\Modules\$moduleName"
        }
    }
}

Write-Host "Uninstallation Details:" -ForegroundColor Yellow
Write-Host "  Scope: $Scope"
Write-Host "  Target Path: $installPath"
Write-Host ""

# Check if module exists
if (-not (Test-Path $installPath)) {
    Write-Host "[!] Module not found at: $installPath" -ForegroundColor Yellow
    Write-Host "Module may not be installed or was installed in a different location." -ForegroundColor Gray
    exit 0
}

# Remove module if loaded
Write-Host "[Info] Checking for loaded module..." -ForegroundColor Yellow
$loadedModule = Get-Module -Name $moduleName
if ($loadedModule) {
    try {
        Remove-Module -Name $moduleName -Force -ErrorAction Stop
        Write-Host "[✓] Module unloaded from current session" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Could not unload module: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Continuing with uninstallation..." -ForegroundColor Gray
    }
}

# Remove module directory
Write-Host "[Info] Removing module directory..." -ForegroundColor Yellow
try {
    Remove-Item -Path $installPath -Recurse -Force -ErrorAction Stop
    Write-Host "[✓] Module directory removed" -ForegroundColor Green
}
catch {
    Write-Host "[Error] Failed to remove module directory: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify removal
Write-Host "`n[Info] Verifying uninstallation..." -ForegroundColor Yellow
$remainingModule = Get-Module -ListAvailable -Name $moduleName | Where-Object { $_.ModuleBase -eq $installPath }
if ($remainingModule) {
    Write-Host "[!] Module still detected (may require PowerShell restart)" -ForegroundColor Yellow
}
else {
    Write-Host "[✓] Module successfully uninstalled!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Uninstallation Complete ===" -ForegroundColor Cyan
exit 0
