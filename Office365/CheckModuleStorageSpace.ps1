# Check module sizes
$modules = @(
    "Microsoft.Graph",
    "ExchangeOnlineManagement",
    "MicrosoftTeams",
    "Microsoft.PowerApps.Administration.PowerShell",
    "Microsoft.Online.SharePoint.PowerShell",
    "ScubaGear"
)

$totalSize = 0
foreach ($moduleName in $modules) {
    $module = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue
    if ($module) {
        $path = Split-Path $module.InstalledLocation -Parent
        $size = (Get-ChildItem -Path $path -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "$moduleName : $([math]::Round($size, 2)) MB"
        $totalSize += $size
    }
}
Write-Host "Total: $([math]::Round($totalSize, 2)) MB"