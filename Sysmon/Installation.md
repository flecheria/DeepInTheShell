# Detailed Sysmon Installation Instructions

I'll provide comprehensive step-by-step instructions for installing and configuring Sysmon on Windows.

## Prerequisites

### System Requirements

- **OS**: Windows 7 / Server 2008 R2 or later
- **Privileges**: Administrator rights required
- **Disk Space**: ~10 MB for Sysmon, plus space for logs (recommended: 500 MB - 2 GB)
- **.NET Framework**: 4.5 or later (usually already installed)

### Pre-Installation Checklist

```powershell
# Check Windows version
Get-ComputerInfo | Select-Object WindowsVersion, OsArchitecture

# Check available disk space
Get-PSDrive C | Select-Object Used, Free

# Verify you're running as Administrator
[Security.Principal.WindowsIdentity]::GetCurrent() |
    Select-Object Name, @{Name='IsAdmin';Expression={
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    }}
```

Expected output should show `IsAdmin : True`

## Step 1: Download Sysmon

### Option A: Direct Download from Microsoft

1. Open PowerShell as Administrator
2. Download Sysmon:

```powershell
# Create a directory for Sysmon
New-Item -Path "C:\Tools\Sysmon" -ItemType Directory -Force
Set-Location "C:\Tools\Sysmon"

# Download Sysmon from Microsoft Sysinternals
$sysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
Invoke-WebRequest -Uri $sysmonUrl -OutFile "Sysmon.zip"

# Extract the archive
Expand-Archive -Path "Sysmon.zip" -DestinationPath "." -Force

# Verify files are present
Get-ChildItem
```

You should see:

- `Sysmon.exe` (32-bit version)
- `Sysmon64.exe` (64-bit version)
- `Eula.txt`

### Option B: Download via Browser

1. Navigate to: https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
2. Click "Download Sysmon"
3. Extract the ZIP file to `C:\Tools\Sysmon`

## Step 2: Choose Your System Architecture

```powershell
# Determine system architecture
$arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture

if ($arch -eq "64-bit") {
    Write-Host "Using Sysmon64.exe" -ForegroundColor Green
    $sysmonExe = "Sysmon64.exe"
} else {
    Write-Host "Using Sysmon.exe" -ForegroundColor Green
    $sysmonExe = "Sysmon.exe"
}

# Set this as a variable for later use
$sysmonPath = "C:\Tools\Sysmon\$sysmonExe"
```

## Step 3: Download a Configuration File

### Recommended: SwiftOnSecurity Configuration

This is a well-maintained, community-vetted configuration:

```powershell
# Still in C:\Tools\Sysmon directory
Set-Location "C:\Tools\Sysmon"

# Download SwiftOnSecurity configuration
$configUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
Invoke-WebRequest -Uri $configUrl -OutFile "sysmonconfig-export.xml"

# Verify the file was downloaded
if (Test-Path "sysmonconfig-export.xml") {
    Write-Host "Configuration file downloaded successfully" -ForegroundColor Green
    Get-Item "sysmonconfig-export.xml" | Select-Object Name, Length, LastWriteTime
} else {
    Write-Host "ERROR: Configuration file not found!" -ForegroundColor Red
}
```

### Alternative: Other Popular Configurations

```powershell
# Option 1: Olaf Hartong's Sysmon Modular config (very comprehensive)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml" -OutFile "sysmonconfig-modular.xml"

# Option 2: Ion-Storm config (balanced approach)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ion-storm/sysmon-config/master/sysmonconfig-export.xml" -OutFile "sysmonconfig-ion-storm.xml"

# Option 3: Minimal config for testing (creates a basic config file)
@"
<Sysmon schemaversion="4.90">
  <EventFiltering>
    <ProcessCreate onmatch="include"/>
    <NetworkConnect onmatch="include"/>
    <FileCreateTime onmatch="include"/>
  </EventFiltering>
</Sysmon>
"@ | Out-File "sysmonconfig-minimal.xml" -Encoding UTF8
```

### Understanding the Configuration File

```powershell
# View the configuration structure
Get-Content "sysmonconfig-export.xml" | Select-Object -First 30

# Count the rules in the configuration
[xml]$config = Get-Content "sysmonconfig-export.xml"
$config.Sysmon.EventFiltering | Get-Member -MemberType Property
```

## Step 4: Install Sysmon

### Installation with Configuration (Recommended)

```powershell
# Navigate to Sysmon directory
Set-Location "C:\Tools\Sysmon"

# Install Sysmon with the SwiftOnSecurity config
# -accepteula: Automatically accept the license
# -i: Install
# -h: Hash algorithms (md5,sha256,imphash)
# -l: Log loading of modules
# -n: Log network connections

# Basic installation
& .\$sysmonExe -accepteula -i sysmonconfig-export.xml

# Advanced installation with all options
& .\$sysmonExe -accepteula -i sysmonconfig-export.xml -h md5,sha256,imphash -l -n
```

Expected output:

```
System Monitor v15.14 - System activity monitor
By Mark Russinovich and Thomas Garnier
Copyright (C) 2014-2024 Microsoft Corporation
Using libxml2. libxml2 is Copyright (C) 1998-2012 Daniel Veillard. All Rights Reserved.
Sysmon64 installed.
SysmonDrv installed.
Starting SysmonDrv.
SysmonDrv started.
Starting Sysmon64..
Sysmon64 started.
```

### Verify Installation

```powershell
# Check if Sysmon service is running
Get-Service Sysmon64

# Expected output:
# Status   Name               DisplayName
# ------   ----               -----------
# Running  Sysmon64           Sysmon64

# Check Sysmon driver
Get-Service SysmonDrv

# View Sysmon service details
Get-Service Sysmon64 | Format-List *

# Check registry for Sysmon configuration
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv\Parameters"
```

### Verify Event Log Channel

```powershell
# Check if Sysmon event log exists
Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational"

# View log properties
Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational" | Format-List *

# View the first few Sysmon events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5 | Format-Table TimeCreated, Id, Message -Wrap
```

## Step 5: Configure Event Log Settings

### Set Log Size and Retention

```powershell
# Set maximum log size to 1 GB (1073741824 bytes)
wevtutil sl Microsoft-Windows-Sysmon/Operational /ms:1073741824

# Enable log overwrite when full (circular logging)
wevtutil sl Microsoft-Windows-Sysmon/Operational /ab:true

# Verify settings
wevtutil gl Microsoft-Windows-Sysmon/Operational
```

### Alternative: Use PowerShell to Configure

```powershell
# Set log to 1 GB with auto-backup
$logName = "Microsoft-Windows-Sysmon/Operational"
$log = Get-WinEvent -ListLog $logName
$log.MaximumSizeInBytes = 1GB
$log.IsEnabled = $true
$log.SaveChanges()

# Verify
Get-WinEvent -ListLog $logName | Select-Object LogName, MaximumSizeInBytes, IsEnabled
```

## Step 6: Test Sysmon Installation

### Generate Test Events

```powershell
# Create a test script to generate various events
@"
# This script will generate Sysmon events for testing
Write-Host "Generating test events..." -ForegroundColor Cyan

# Event ID 1: Process Creation
Start-Process notepad.exe
Start-Sleep -Seconds 2
Stop-Process -Name notepad -Force

# Event ID 3: Network Connection
Test-NetConnection google.com -Port 443 | Out-Null

# Event ID 11: File Creation
"Test file" | Out-File "$env:TEMP\sysmon_test.txt"

# Event ID 23: File Delete
Remove-Item "$env:TEMP\sysmon_test.txt" -Force

Write-Host "Test events generated!" -ForegroundColor Green
"@ | Out-File "C:\Tools\Sysmon\test-sysmon.ps1"

# Run the test script
& "C:\Tools\Sysmon\test-sysmon.ps1"
```

### Verify Events Were Logged

```powershell
# Check for recent Sysmon events (last 5 minutes)
$StartTime = (Get-Date).AddMinutes(-5)
Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-Sysmon/Operational'
    StartTime=$StartTime
} | Select-Object TimeCreated, Id, Message -First 10

# Count events by Event ID
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 1000 |
    Group-Object Id |
    Select-Object Count, Name |
    Sort-Object Count -Descending

# View specific event types
# Event ID 1: Process Creation
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1} -MaxEvents 5 |
    Format-Table TimeCreated, Message -Wrap
```

## Step 7: Create Monitoring and Maintenance Scripts

### Daily Health Check Script

```powershell
# Save as: C:\Tools\Sysmon\Check-SysmonHealth.ps1
@"
# Sysmon Health Check Script
`$ErrorActionPreference = 'Stop'

Write-Host "`n=== Sysmon Health Check ===" -ForegroundColor Cyan
Write-Host "Timestamp: `$(Get-Date)" -ForegroundColor Gray

# Check Service Status
Write-Host "`n[1] Checking Sysmon Service..." -ForegroundColor Yellow
`$service = Get-Service Sysmon64 -ErrorAction SilentlyContinue
if (`$service -and `$service.Status -eq 'Running') {
    Write-Host "✓ Sysmon service is running" -ForegroundColor Green
} else {
    Write-Host "✗ Sysmon service is NOT running!" -ForegroundColor Red
    exit 1
}

# Check Driver
Write-Host "`n[2] Checking Sysmon Driver..." -ForegroundColor Yellow
`$driver = Get-Service SysmonDrv -ErrorAction SilentlyContinue
if (`$driver -and `$driver.Status -eq 'Running') {
    Write-Host "✓ Sysmon driver is running" -ForegroundColor Green
} else {
    Write-Host "✗ Sysmon driver is NOT running!" -ForegroundColor Red
}

# Check Event Log
Write-Host "`n[3] Checking Event Log..." -ForegroundColor Yellow
`$log = Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational" -ErrorAction SilentlyContinue
if (`$log) {
    `$logSizeMB = [math]::Round(`$log.FileSize / 1MB, 2)
    `$maxSizeMB = [math]::Round(`$log.MaximumSizeInBytes / 1MB, 2)
    `$percentFull = [math]::Round((`$log.FileSize / `$log.MaximumSizeInBytes) * 100, 2)

    Write-Host "✓ Event log accessible" -ForegroundColor Green
    Write-Host "  Current size: `$logSizeMB MB / `$maxSizeMB MB (`$percentFull% full)" -ForegroundColor Gray

    if (`$percentFull -gt 80) {
        Write-Host "  ⚠ Warning: Log is more than 80% full" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Cannot access event log!" -ForegroundColor Red
}

# Check Recent Events
Write-Host "`n[4] Checking Recent Events..." -ForegroundColor Yellow
`$recentEvents = Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 1 -ErrorAction SilentlyContinue
if (`$recentEvents) {
    `$lastEvent = `$recentEvents[0].TimeCreated
    `$minutesAgo = [math]::Round(((Get-Date) - `$lastEvent).TotalMinutes, 2)
    Write-Host "✓ Last event: `$lastEvent (`$minutesAgo minutes ago)" -ForegroundColor Green

    if (`$minutesAgo -gt 10) {
        Write-Host "  ⚠ Warning: No events in last 10 minutes" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ No events found!" -ForegroundColor Red
}

# Event Statistics
Write-Host "`n[5] Event Statistics (last 24 hours)..." -ForegroundColor Yellow
`$last24h = (Get-Date).AddHours(-24)
`$events = Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-Sysmon/Operational'
    StartTime=`$last24h
} -ErrorAction SilentlyContinue

if (`$events) {
    `$eventStats = `$events | Group-Object Id | Select-Object @{Name='EventID';Expression={`$_.Name}}, Count | Sort-Object Count -Descending
    `$eventStats | Format-Table -AutoSize
    Write-Host "Total events in last 24h: `$(`$events.Count)" -ForegroundColor Gray
} else {
    Write-Host "No events in last 24 hours" -ForegroundColor Yellow
}

Write-Host "`n=== Health Check Complete ===`n" -ForegroundColor Cyan
"@ | Out-File "C:\Tools\Sysmon\Check-SysmonHealth.ps1" -Encoding UTF8

# Run the health check
& "C:\Tools\Sysmon\Check-SysmonHealth.ps1"
```

### Schedule the Health Check

```powershell
# Create a scheduled task to run health check daily
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Tools\Sysmon\Check-SysmonHealth.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "08:00AM"
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "Sysmon Health Check" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "Daily health check for Sysmon monitoring"
```

## Step 8: Update Configuration (When Needed)

### Update Sysmon Configuration

```powershell
# Download latest configuration
Set-Location "C:\Tools\Sysmon"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "sysmonconfig-export.xml"

# Apply the updated configuration
# -c: Update configuration
& .\$sysmonExe -c sysmonconfig-export.xml

# Verify the update
Write-Host "Configuration updated successfully" -ForegroundColor Green
```

### Create Configuration Update Script

```powershell
# Save as: C:\Tools\Sysmon\Update-SysmonConfig.ps1
@"
# Sysmon Configuration Update Script
param(
    [string]`$ConfigUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
)

Write-Host "Updating Sysmon configuration..." -ForegroundColor Cyan

# Backup current configuration
`$backupPath = "C:\Tools\Sysmon\Backups"
if (-not (Test-Path `$backupPath)) {
    New-Item -Path `$backupPath -ItemType Directory -Force | Out-Null
}

`$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
`$backupFile = "`$backupPath\sysmonconfig_backup_`$timestamp.xml"

# Export current config
& C:\Tools\Sysmon\Sysmon64.exe -c > `$backupFile
Write-Host "Current configuration backed up to: `$backupFile" -ForegroundColor Gray

# Download new configuration
try {
    Invoke-WebRequest -Uri `$ConfigUrl -OutFile "C:\Tools\Sysmon\sysmonconfig-export.xml" -ErrorAction Stop
    Write-Host "✓ Downloaded new configuration" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download configuration: `$_" -ForegroundColor Red
    exit 1
}

# Apply new configuration
try {
    & C:\Tools\Sysmon\Sysmon64.exe -c "C:\Tools\Sysmon\sysmonconfig-export.xml"
    Write-Host "✓ Configuration updated successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to apply configuration: `$_" -ForegroundColor Red
    Write-Host "Restoring backup..." -ForegroundColor Yellow
    & C:\Tools\Sysmon\Sysmon64.exe -c `$backupFile
    exit 1
}

Write-Host "Sysmon configuration update complete!" -ForegroundColor Cyan
"@ | Out-File "C:\Tools\Sysmon\Update-SysmonConfig.ps1" -Encoding UTF8
```

## Step 9: Uninstall Sysmon (If Needed)

```powershell
# Uninstall Sysmon
# WARNING: This will remove all Sysmon monitoring
Set-Location "C:\Tools\Sysmon"

# -u: Uninstall
& .\$sysmonExe -u force

# Verify uninstallation
Get-Service Sysmon64 -ErrorAction SilentlyContinue
# Should return an error: "Cannot find any service with service name 'Sysmon64'"
```

## Common Sysmon Event IDs Reference

| Event ID | Description                | Use Case                                |
| -------- | -------------------------- | --------------------------------------- |
| 1        | Process Creation           | Track all process starts, command lines |
| 2        | File Creation Time Changed | Detect timestamp manipulation           |
| 3        | Network Connection         | Monitor network activity                |
| 5        | Process Terminated         | Track process lifecycle                 |
| 6        | Driver Loaded              | Detect malicious drivers                |
| 7        | Image/DLL Loaded           | Track library loads                     |
| 8        | CreateRemoteThread         | Detect code injection                   |
| 9        | RawAccessRead              | Monitor raw disk access                 |
| 10       | ProcessAccess              | Detect process manipulation             |
| 11       | FileCreate                 | Track file creation                     |
| 12/13/14 | Registry Events            | Monitor registry changes                |
| 15       | FileCreateStreamHash       | Detect ADS usage                        |
| 17/18    | Pipe Events                | Monitor named pipes                     |
| 19/20/21 | WMI Events                 | Track WMI activity                      |
| 22       | DNS Query                  | Monitor DNS requests                    |
| 23       | File Delete                | Track file deletions                    |
| 24       | Clipboard Change           | Monitor clipboard activity              |
| 25       | Process Tampering          | Detect process hollowing                |
| 26       | File Delete Detected       | Track file deletion attempts            |
| 27/28    | File Block Events          | Track blocked operations                |
| 29       | File Executable Detected   | Track PE file creation                  |

## Troubleshooting

### Sysmon Service Won't Start

```powershell
# Check service status
Get-Service Sysmon64 | Format-List *

# Check event log for errors
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Service Control Manager'} -MaxEvents 20 |
    Where-Object {$_.Message -like "*Sysmon*"}

# Try reinstalling
Set-Location "C:\Tools\Sysmon"
& .\Sysmon64.exe -u force
& .\Sysmon64.exe -accepteula -i sysmonconfig-export.xml
```

### No Events Being Logged

```powershell
# Verify event channel is enabled
$log = Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational"
if (-not $log.IsEnabled) {
    $log.IsEnabled = $true
    $log.SaveChanges()
    Write-Host "Event log channel enabled" -ForegroundColor Green
}

# Check if configuration is too restrictive
& .\Sysmon64.exe -c

# Try with minimal configuration for testing
& .\Sysmon64.exe -c sysmonconfig-minimal.xml
```

### High CPU/Disk Usage

```powershell
# Check configuration for overly broad rules
# Use a more restrictive configuration
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "sysmonconfig-export.xml"
& .\Sysmon64.exe -c sysmonconfig-export.xml

# Exclude noisy processes if needed (edit XML configuration)
```

## Next Steps

1. **Monitor regularly** - Run the health check script daily
2. **Update configuration** - Keep your config file up-to-date
3. **Export data** - Set up regular exports for analysis
4. **Integrate with SIEM** - Forward events to central logging
5. **Create alerts** - Set up alerting for suspicious activities

## Quick Reference Commands

```powershell
# Install
.\Sysmon64.exe -accepteula -i config.xml

# Update config
.\Sysmon64.exe -c config.xml

# Check current config
.\Sysmon64.exe -c

# View schema version
.\Sysmon64.exe -s

# Uninstall
.\Sysmon64.exe -u force

# Check service
Get-Service Sysmon64

# View recent events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 10
```

Your Sysmon installation is now complete! The service will automatically start with Windows and begin logging events according to your configuration.
