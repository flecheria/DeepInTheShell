<#
.SYNOPSIS
    Standalone script to manage file extension visibility in Windows Explorer.

.DESCRIPTION
    This script enables or disables file extension visibility in Windows Explorer.
    Compatible with environment variable inputs for automation systems.
    Can run as SYSTEM or regular user account.

.PARAMETER Action
    Enable or Disable file extension visibility.

.PARAMETER Scope
    Scope of change: CurrentUser, LocalMachine, or AllUsers (default: CurrentUser)

.PARAMETER RestartExplorer
    Restart Windows Explorer to apply changes immediately.

.EXAMPLE
    .\Set-FileExtensionVisibility.ps1 -Action Enable
    
.EXAMPLE
    .\Set-FileExtensionVisibility.ps1 -Action Disable -Scope AllUsers -RestartExplorer

.NOTES
    Author: Optimized Script
    Version: 2.0
    Minimum OS: Windows 10, Windows Server 2016
    
    Environment Variables (optional):
    - $env:action: "Enable" or "Disable"
    - $env:scope: "CurrentUser", "LocalMachine", or "AllUsers"
    - $env:restartExplorer: "true" or "false"
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("Enable", "Disable")]
    [string]$Action,
    
    [Parameter()]
    [ValidateSet("CurrentUser", "LocalMachine", "AllUsers")]
    [string]$Scope = "CurrentUser",
    
    [Parameter()]
    [switch]$RestartExplorer
)

# Check for environment variable overrides
if ($env:action -and $env:action -notlike "null") {
    $Action = $env:action
}

if ($env:scope -and $env:scope -notlike "null") {
    $Scope = $env:scope
}

if ($env:restartExplorer -and $env:restartExplorer -notlike "null") {
    $RestartExplorer = [System.Convert]::ToBoolean($env:restartExplorer)
}

# Validate required parameters
if (-not $Action) {
    Write-Host "[Error] You must specify an action: -Action Enable or -Action Disable" -ForegroundColor Red
    exit 1
}

if ($Action -notin @("Enable", "Disable")) {
    Write-Host "[Error] Invalid action '$Action'. Use 'Enable' or 'Disable'" -ForegroundColor Red
    exit 1
}

# Import the module from the same directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Join-Path $scriptPath "ExplorerSettings.psm1"

if (Test-Path $modulePath) {
    Import-Module $modulePath -Force
}
else {
    Write-Host "[Error] Module file not found: $modulePath" -ForegroundColor Red
    Write-Host "[Info] Ensure ExplorerSettings.psm1 is in the same directory as this script" -ForegroundColor Yellow
    exit 1
}

# Execute the command
try {
    Set-FileExtensionVisibility -Action $Action -Scope $Scope -RestartExplorer:$RestartExplorer -ErrorAction Stop
    exit 0
}
catch {
    Write-Host "[Error] Failed to set file extension visibility: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
