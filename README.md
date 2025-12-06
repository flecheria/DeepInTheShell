# Deep In The Shell

# Intro

Use SecurityHardeningCommands_antivirus.ps1 if have an antivirus installed.
Use SecurityHardeningCommands_antivirus.ps1 if do NOT have an antivirus installed.

## WinDefender

```shell
Get-Service WinDefend
Get-MpComputerStatus

# If Defender is disabled, enable it:
Set-Service WinDefend -StartupType Automatic
Start-Service WinDefend
```

## Reference

[](https://undercodetesting.com/windows-hardening-and-optimization-powershell-pack/)  
[Harden-Windows-Security](https://github.com/HotCakeX/Harden-Windows-Security)
[](https://github.com/scipag/HardeningKitty)
[](https://github.com/shanerwilson/Windows-Hardening-Scripts-Collection)
[Windows Policy Analyzer](https://learn.microsoft.com/en-us/archive/blogs/secguide/new-tool-policy-analyzer)
[Microsoft Security Compliance Toolkit 1.0](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
