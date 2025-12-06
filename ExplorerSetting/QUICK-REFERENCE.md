# ExplorerSettings Module - Quick Reference

## Installation
```powershell
# Install for current user
.\Install-ExplorerSettings.ps1

# Install for all users (requires admin)
.\Install-ExplorerSettings.ps1 -Scope AllUsers

# Import the module
Import-Module ExplorerSettings
```

## Basic Commands

### Show File Extensions
```powershell
# Current user only
Enable-FileExtensions

# Current user with Explorer restart
Enable-FileExtensions -RestartExplorer

# All users (requires admin)
Enable-FileExtensions -Scope AllUsers -RestartExplorer

# Local machine default
Enable-FileExtensions -Scope LocalMachine
```

### Hide File Extensions
```powershell
# Current user only
Disable-FileExtensions

# Current user with Explorer restart
Disable-FileExtensions -RestartExplorer

# All users (requires admin)
Disable-FileExtensions -Scope AllUsers -RestartExplorer
```

### Check Current Setting
```powershell
# Check current user setting
Get-FileExtensionVisibility

# Check local machine setting
Get-FileExtensionVisibility -Scope LocalMachine
```

### Restart Explorer
```powershell
# Restart Windows Explorer
Restart-WindowsExplorer
```

## Advanced Usage

### Using Set-FileExtensionVisibility Directly
```powershell
# Full control with all parameters
Set-FileExtensionVisibility -Action Enable -Scope CurrentUser -RestartExplorer

# With excluded users (AllUsers scope)
Set-FileExtensionVisibility -Action Enable -Scope AllUsers -ExcludedUsers @("TestUser", "TempAccount")
```

### Conditional Logic
```powershell
# Toggle based on current state
$current = Get-FileExtensionVisibility
if ($current.FileExtensionsVisible) {
    Disable-FileExtensions
} else {
    Enable-FileExtensions
}
```

### Automation Script
```powershell
# Using environment variables (compatible with RMM tools)
$env:action = "Enable"
$env:scope = "AllUsers"
$env:restartExplorer = "true"
.\Set-FileExtensionVisibility.ps1
```

## Scopes Explained

| Scope | Description | Requires Admin |
|-------|-------------|----------------|
| **CurrentUser** | Only affects the logged-in user | No |
| **LocalMachine** | Sets default for new user profiles | Yes |
| **AllUsers** | Modifies all existing user profiles | Yes |

## Registry Locations

- **Current User**: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`
- **Local Machine**: `HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`
- **Other Users**: `HKEY_USERS\{SID}\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`

**Registry Value**: `HideFileExt`
- `0` = Show file extensions
- `1` = Hide file extensions

## Common Scenarios

### Scenario 1: New Computer Setup
```powershell
# Enable for all users on a new computer
Enable-FileExtensions -Scope AllUsers -RestartExplorer
```

### Scenario 2: Help Desk Troubleshooting
```powershell
# Check what's currently set
Get-FileExtensionVisibility

# Enable for user experiencing issues
Enable-FileExtensions -RestartExplorer
```

### Scenario 3: Group Policy Alternative
```powershell
# Set default for new users only (doesn't affect existing)
Enable-FileExtensions -Scope LocalMachine
```

### Scenario 4: Automated Deployment
```powershell
# Deploy via script without user interaction
Import-Module ExplorerSettings
Set-FileExtensionVisibility -Action Enable -Scope AllUsers -RestartExplorer
```

## Troubleshooting

### Changes Not Visible
```powershell
# Restart Explorer to apply changes
Restart-WindowsExplorer
```

### Access Denied Errors
```powershell
# Run PowerShell as Administrator
# Right-click PowerShell → "Run as Administrator"
```

### Module Not Found
```powershell
# Check available modules
Get-Module -ListAvailable ExplorerSettings

# Verify installation path
$env:PSModulePath -split ';'

# Reinstall if needed
.\Install-ExplorerSettings.ps1 -Force
```

## Getting Help

```powershell
# List all module functions
Get-Command -Module ExplorerSettings

# Get detailed help for a function
Get-Help Enable-FileExtensions -Full
Get-Help Set-FileExtensionVisibility -Examples
Get-Help Get-FileExtensionVisibility -Detailed

# View README
notepad "$(Split-Path (Get-Module ExplorerSettings).Path)\README.md"
```

## Uninstallation

```powershell
# Uninstall from current user
.\Uninstall-ExplorerSettings.ps1

# Uninstall from all users (requires admin)
.\Uninstall-ExplorerSettings.ps1 -Scope AllUsers
```

## One-Liners

```powershell
# Quick enable with restart
Import-Module ExplorerSettings; Enable-FileExtensions -RestartExplorer

# Quick disable
Import-Module ExplorerSettings; Disable-FileExtensions

# Check and display status
Import-Module ExplorerSettings; Get-FileExtensionVisibility | Format-List
```

## Best Practices

1. **Always test in non-production first**
2. **Use `-RestartExplorer` for immediate effect**
3. **Document changes for audit purposes**
4. **Use `AllUsers` scope for workstation images**
5. **Use `CurrentUser` scope for individual fixes**
6. **Check current setting before changing**: `Get-FileExtensionVisibility`

## Notes

- Module requires PowerShell 5.1 or later
- Administrative privileges needed for LocalMachine/AllUsers scopes
- Changes are persistent across reboots
- Compatible with Windows 10, Windows 11, Server 2016+
