# Uninstall-M365Modules.ps1

<#
.SYNOPSIS
    Removes all Microsoft 365 administrative PowerShell modules
#>

Write-Host "=== Uninstalling M365 PowerShell Modules ===" -ForegroundColor Cyan
Write-Host ""

$modulesToRemove = @(
    "ScubaGear",
    "Microsoft.Graph",
    "Microsoft.Graph.*",  # All Graph sub-modules
    "ExchangeOnlineManagement",
    "MicrosoftTeams",
    "Microsoft.PowerApps.Administration.PowerShell",
    "Microsoft.PowerApps.PowerShell",
    "Microsoft.Online.SharePoint.PowerShell",
    "AzureAD",
    "AzureADPreview"
)

foreach ($moduleName in $modulesToRemove) {
    Write-Host "Checking for $moduleName..." -NoNewline
    
    $modules = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue -AllVersions
    
    if ($modules) {
        Write-Host " Found $($modules.Count) version(s)" -ForegroundColor Yellow
        
        foreach ($module in $modules) {
            try {
                Write-Host "  Removing $($module.Name) v$($module.Version)..." -NoNewline
                Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -Force -ErrorAction Stop
                Write-Host " [Done]" -ForegroundColor Green
            } catch {
                Write-Host " [Failed]" -ForegroundColor Red
                Write-Warning "  $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host " Not installed" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Verifying removal..." -ForegroundColor Yellow

# Verify removal
$remainingModules = Get-InstalledModule | Where-Object { 
    $_.Name -like "Microsoft.Graph*" -or 
    $_.Name -like "*Exchange*" -or 
    $_.Name -like "*Teams*" -or 
    $_.Name -like "*PowerApps*" -or 
    $_.Name -like "*SharePoint*" -or
    $_.Name -eq "ScubaGear"
}

if ($remainingModules) {
    Write-Host ""
    Write-Warning "Some modules could not be removed:"
    $remainingModules | Select-Object Name, Version | Format-Table
    Write-Host ""
    Write-Host "To force removal, try running as Administrator:" -ForegroundColor Yellow
    Write-Host "  Remove-Item -Path 'C:\Program Files\PowerShell\Modules\<ModuleName>' -Recurse -Force" -ForegroundColor Gray
} else {
    Write-Host "✓ All modules successfully removed!" -ForegroundColor Green
}