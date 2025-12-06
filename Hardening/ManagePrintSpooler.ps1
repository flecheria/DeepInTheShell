# ManagePrintSpooler.ps1
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Status", "Stop", "Disable", "Enable", "Start")]
    [string]$Action
)

$serviceName = "Spooler"

switch ($Action) {
    "Status" {
        Get-Service -Name $serviceName | Select-Object Name, Status, StartType, DisplayName
    }
    "Stop" {
        Stop-Service -Name $serviceName -Force
        Write-Host "Print Spooler stopped" -ForegroundColor Green
        Get-Service -Name $serviceName | Select-Object Status, StartType
    }
    "Disable" {
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Set-Service -Name $serviceName -StartupType Disabled
        Write-Host "Print Spooler disabled" -ForegroundColor Green
        Get-Service -Name $serviceName | Select-Object Status, StartType
    }
    "Enable" {
        Set-Service -Name $serviceName -StartupType Automatic
        Write-Host "Print Spooler enabled (not started)" -ForegroundColor Yellow
        Get-Service -Name $serviceName | Select-Object Status, StartType
    }
    "Start" {
        Set-Service -Name $serviceName -StartupType Automatic
        Start-Service -Name $serviceName
        Write-Host "Print Spooler started" -ForegroundColor Green
        Get-Service -Name $serviceName | Select-Object Status, StartType
    }
}