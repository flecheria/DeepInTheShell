# Deep In The Shell

## Introduction

Powershell commands toolkit to hardening and managing different aspects of a Windows OS machine.

## Running Scripts

Most of this script need to be run using terminal in Admin mode.
First of all asses the current security status of your Windows machine:

```shell
.\Hardening\

# run this where external AV is installed and active
.\Hardening\SecurityHardeningCommands_antivirus.ps1

# run this where external AV is NOT installed and active, basically you are using WinDefender
.\Hardening\SecurityHardeningCommands.ps1
```

```shell
# commands that help to run script avoiding AV
# Run as Admin - add your scripts folder to exclusions
Add-MpPreference -ExclusionPath "C:\Path\To\Your\DeepInTheShell"

Unblock-File -Path [.\relative\path\to\script.ps1]

PowerShell.exe -ExecutionPolicy Bypass -File [.\relative\path\to\script.ps1]
```

```shell
.\ManagePrintSpooler.ps1 -Action Disable
```

## WinDefender

Get WinDefender information:

```shell
Get-Service WinDefend
Get-MpComputerStatus

# If Defender is disabled, enable it:
Set-Service WinDefend -StartupType Automatic
Start-Service WinDefend
```

```shell
# Verify BitDefender is actually protecting
Get-Service | Where-Object {$_.Name -like "*bdredline*" -or $_.Name -like "*vsserv*"} | Select-Object Name, Status

# Check if RDP is exposed
Get-NetTCPConnection -LocalPort 3389 -State Listen -ErrorAction SilentlyContinue
```

## TODO

Need to be fully tested:

- Harden-DomainController.ps1
- Harden-DomainWorkstation.ps1

## Reference

[](https://undercodetesting.com/windows-hardening-and-optimization-powershell-pack/)  
[Harden-Windows-Security](https://github.com/HotCakeX/Harden-Windows-Security)
[](https://github.com/scipag/HardeningKitty)
[](https://github.com/shanerwilson/Windows-Hardening-Scripts-Collection)
[Windows Policy Analyzer](https://learn.microsoft.com/en-us/archive/blogs/secguide/new-tool-policy-analyzer)
[Microsoft Security Compliance Toolkit 1.0](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
