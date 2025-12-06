<#
.SYNOPSIS
    Installation script for ExplorerSettings PowerShell module.

.DESCRIPTION
    Installs the ExplorerSettings module to the appropriate PowerShell modules directory.

.PARAMETER Scope
    Installation scope: CurrentUser or AllUsers (requires admin)

.PARAMETER Force
    Overwrite existing module installation

.EXAMPLE
    .\Install-ExplorerSettings.ps1
    Installs for current user

.EXAMPLE
    .\Install-ExplorerSettings.ps1 -Scope AllUsers
    Installs for all users (requires admin)
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser",
    
    [Parameter()]
    [switch]$Force
)

Write-Host "=== ExplorerSettings Module Installation ===" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges if installing for all users
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

Write-Host "Installation Details:" -ForegroundColor Yellow
Write-Host "  Scope: $Scope"
Write-Host "  Target Path: $installPath"
Write-Host ""

# Check if module already exists
if (Test-Path $installPath) {
    if ($Force) {
        Write-Host "[Info] Removing existing module installation..." -ForegroundColor Yellow
        try {
            Remove-Item -Path $installPath -Recurse -Force -ErrorAction Stop
            Write-Host "[✓] Existing module removed" -ForegroundColor Green
        }
        catch {
            Write-Host "[Error] Failed to remove existing module: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "[Error] Module already exists at: $installPath" -ForegroundColor Red
        Write-Host "Use -Force parameter to overwrite, or uninstall first." -ForegroundColor Yellow
        exit 1
    }
}

# Create module directory
Write-Host "[Info] Creating module directory..." -ForegroundColor Yellow
try {
    New-Item -Path $installPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
    Write-Host "[✓] Module directory created" -ForegroundColor Green
}
catch {
    Write-Host "[Error] Failed to create module directory: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Copy module files
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$filesToCopy = @(
    "ExplorerSettings.psm1",
    "ExplorerSettings.psd1",
    "README.md"
)

Write-Host "[Info] Copying module files..." -ForegroundColor Yellow
foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $scriptPath $file
    $destPath = Join-Path $installPath $file
    
    if (Test-Path $sourcePath) {
        try {
            Copy-Item -Path $sourcePath -Destination $destPath -Force -ErrorAction Stop
            Write-Host "  [✓] Copied: $file" -ForegroundColor Green
        }
        catch {
            Write-Host "  [✗] Failed to copy $file`: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "  [!] File not found: $file (skipping)" -ForegroundColor Yellow
    }
}

# Verify installation
Write-Host "`n[Info] Verifying installation..." -ForegroundColor Yellow
try {
    $installedModule = Get-Module -ListAvailable -Name $moduleName | Where-Object { $_.ModuleBase -eq $installPath }
    if ($installedModule) {
        Write-Host "[✓] Module installed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Module Details:" -ForegroundColor Cyan
        Write-Host "  Name: $($installedModule.Name)"
        Write-Host "  Version: $($installedModule.Version)"
        Write-Host "  Path: $($installedModule.ModuleBase)"
        Write-Host ""
        Write-Host "To use the module, run:" -ForegroundColor Yellow
        Write-Host "  Import-Module $moduleName" -ForegroundColor White
        Write-Host ""
        Write-Host "Example commands:" -ForegroundColor Yellow
        Write-Host "  Enable-FileExtensions" -ForegroundColor White
        Write-Host "  Disable-FileExtensions -RestartExplorer" -ForegroundColor White
        Write-Host "  Get-FileExtensionVisibility" -ForegroundColor White
        Write-Host ""
        Write-Host "For more information, see:" -ForegroundColor Yellow
        Write-Host "  Get-Help Enable-FileExtensions -Full" -ForegroundColor White
        Write-Host "  Or read: $(Join-Path $installPath 'README.md')" -ForegroundColor White
    }
    else {
        Write-Host "[!] Module installed but not detected by Get-Module" -ForegroundColor Yellow
        Write-Host "You may need to restart PowerShell." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[!] Installation completed but verification failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Cyan
exit 0
