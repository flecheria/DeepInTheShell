# Understanding Sysmon for Windows Event Management

I'll help you understand how Sysmon works for Windows event monitoring and how to analyze the data effectively.

## What is Sysmon?

**Sysmon (System Monitor)** is a Windows system service and device driver that logs detailed system activity to the Windows Event Log. It's part of Microsoft's Sysinternals suite and provides deep visibility into system operations.

## How Sysmon Works

### Core Functionality

1. **Installation**: Sysmon runs as a system service that starts at boot
2. **Monitoring**: Captures events through a kernel driver and system hooks
3. **Logging**: Writes events to `Applications and Services Logs/Microsoft/Windows/Sysmon/Operational`
4. **Configuration**: Uses XML-based rules to filter what events to capture

### Key Event Types Sysmon Captures

- **Process Creation** (Event ID 1) - All process starts with command lines
- **Network Connections** (Event ID 3) - TCP/UDP connections
- **File Creation** (Event ID 11) - File creation events
- **Registry Modifications** (Event ID 12-14) - Registry changes
- **Image Loads** (Event ID 7) - DLL/driver loads
- **DNS Queries** (Event ID 22) - DNS lookups
- **Process Termination** (Event ID 5) - Process exits

## Setting Up Sysmon

### Installation

```powershell
# Download Sysmon from Microsoft Sysinternals
# Install with a configuration file (recommended)
sysmon64.exe -accepteula -i sysmonconfig.xml

# Install with default settings (not recommended - too verbose)
sysmon64.exe -accepteula -i
```

### Recommended Configuration

Use the **SwiftOnSecurity** configuration (mentioned in your HardeningKitty documentation):

```powershell
# Download the config
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "sysmonconfig.xml"

# Apply the configuration
sysmon64.exe -c sysmonconfig.xml
```

## Exporting Events for Analysis

### Method 1: Export to CSV using PowerShell

```powershell
# Export Sysmon events to CSV
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 10000 |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Export-Csv -Path "C:\Logs\sysmon_export.csv" -NoTypeInformation

# More detailed export with parsed properties
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 10000 |
    ForEach-Object {
        [PSCustomObject]@{
            TimeCreated = $_.TimeCreated
            EventID = $_.Id
            Computer = $_.MachineName
            Level = $_.LevelDisplayName
            ProcessID = $_.Properties[3].Value
            Image = $_.Properties[4].Value
            CommandLine = $_.Properties[10].Value
            User = $_.Properties[12].Value
        }
    } | Export-Csv -Path "C:\Logs\sysmon_detailed.csv" -NoTypeInformation
```

### Method 2: Export Specific Event Types

```powershell
# Export only Process Creation events (Event ID 1)
Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-Sysmon/Operational'
    ID=1
} -MaxEvents 5000 |
    Select-Object TimeCreated,
        @{Name='ProcessName';Expression={$_.Properties[4].Value}},
        @{Name='CommandLine';Expression={$_.Properties[10].Value}},
        @{Name='User';Expression={$_.Properties[12].Value}} |
    Export-Csv -Path "C:\Logs\process_creation.csv" -NoTypeInformation

# Export Network Connections (Event ID 3)
Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-Sysmon/Operational'
    ID=3
} -MaxEvents 5000 |
    Select-Object TimeCreated,
        @{Name='ProcessName';Expression={$_.Properties[4].Value}},
        @{Name='SourceIP';Expression={$_.Properties[9].Value}},
        @{Name='DestIP';Expression={$_.Properties[14].Value}},
        @{Name='DestPort';Expression={$_.Properties[16].Value}} |
    Export-Csv -Path "C:\Logs\network_connections.csv" -NoTypeInformation
```

### Method 3: Scheduled Export Script

Create a script that runs periodically to export and archive logs:

```powershell
# SaveTo: Export-SysmonLogs.ps1
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
```

Schedule this with Task Scheduler:

```powershell
# Create scheduled task to run daily
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Export-SysmonLogs.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
Register-ScheduledTask -TaskName "Export Sysmon Logs" -Action $action -Trigger $trigger -Principal $principal
```

## Analyzing with KNIME

### Preparing Data for KNIME

1. **Export to CSV** using the scripts above
2. **Structure your data** with consistent columns

### KNIME Workflow Example

Here's a basic KNIME workflow structure:

```
CSV Reader → Row Filter → GroupBy → Bar Chart
            ↓
       String Manipulation → Value Counter → Pie Chart
```

### Key KNIME Nodes to Use

1. **CSV Reader** - Import your Sysmon CSV files
2. **Row Filter** - Filter by Event ID or time range
3. **String Manipulation** - Parse and clean data
4. **GroupBy** - Aggregate events (e.g., count by process)
5. **Sorter** - Order results
6. **Bar Chart/Pie Chart** - Visualize findings
7. **Statistics** - Calculate metrics

### Sample KNIME Analysis Tasks

**1. Most Active Processes**

```
CSV Reader → Row Filter (EventID = 1) → GroupBy (ProcessName, count) → Sorter → Bar Chart
```

**2. Network Activity Timeline**

```
CSV Reader → Row Filter (EventID = 3) → Date&Time Shift → Line Plot
```

**3. Suspicious Activity Detection**

```
CSV Reader → Rule Engine (flag suspicious patterns) → Row Filter (suspicious only) → Table View
```

## Managing Event Storage

### Clear Sysmon Event Log

```powershell
# Clear the Sysmon operational log (requires admin)
Clear-EventLog -LogName "Microsoft-Windows-Sysmon/Operational"

# Or use wevtutil
wevtutil cl Microsoft-Windows-Sysmon/Operational
```

### Archive Before Clearing

```powershell
# Export, then clear
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
wevtutil epl Microsoft-Windows-Sysmon/Operational "C:\Logs\Archive\sysmon_$timestamp.evtx"
wevtutil cl Microsoft-Windows-Sysmon/Operational
```

### Configure Log Size Limits

```powershell
# Set maximum log size (in bytes) - example: 1GB
wevtutil sl Microsoft-Windows-Sysmon/Operational /ms:1073741824

# Set to overwrite old events when full
wevtutil sl Microsoft-Windows-Sysmon/Operational /ab:true
```

## Important Fields to Track

### High-Value Event Data

| Field             | Description             | Use Case                      |
| ----------------- | ----------------------- | ----------------------------- |
| TimeCreated       | When event occurred     | Timeline analysis             |
| EventID           | Event type              | Filtering specific activities |
| ProcessName       | Executable name         | Identify processes            |
| CommandLine       | Full command            | Detect malicious commands     |
| User              | Account running process | Attribution                   |
| ParentProcessName | Parent process          | Process tree analysis         |
| Hashes            | File hashes             | Malware identification        |
| DestinationIP     | Network destination     | Network behavior              |
| DestinationPort   | Target port             | Service identification        |

## Best Practices

1. **Use a good configuration file** - Don't log everything (SwiftOnSecurity config is excellent)
2. **Regular exports** - Schedule automated exports to prevent log overflow
3. **Centralize if possible** - Consider forwarding to SIEM or central log server
4. **Focus on key events** - Process creation (1), Network (3), File creation (11)
5. **Archive strategically** - Keep 30-90 days of detailed logs, archive older data
6. **Monitor log size** - Set appropriate limits to prevent disk space issues

## Integration with HardeningKitty

Since you're using HardeningKitty, you can enhance security monitoring:

```powershell
# Run HardeningKitty audit and correlate with Sysmon
Invoke-HardeningKitty -Mode Audit -Report -ReportFile "C:\Logs\hardening_audit.csv"

# Export recent Sysmon events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5000 |
    Export-Csv "C:\Logs\sysmon_events.csv" -NoTypeInformation

# Both CSV files can be imported into KNIME for correlation analysis
```
