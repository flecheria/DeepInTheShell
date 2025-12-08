param(
    [int]$MaxEvents = 10000,
    [string]$OutputPath = "C:\Logs\Sysmon"
)

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force
}

# Generate filename with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = Join-Path $OutputPath "sysmon_export_$timestamp.csv"

# Export events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents $MaxEvents |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Exported $MaxEvents events to $outputFile"

# Optional: Clean up old exports (older than 30 days)
Get-ChildItem -Path $OutputPath -Filter "sysmon_export_*.csv" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Remove-Item -Force

Write-Host "Cleanup completed"