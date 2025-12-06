# ExplorerSettings Module - Usage Examples

## Installation

1. Copy both `ExplorerSettings.psm1` and `ExplorerSettings.psd1` to one of these locations:
   - User modules: `$HOME\Documents\WindowsPowerShell\Modules\ExplorerSettings\`
   - System modules: `C:\Program Files\WindowsPowerShell\Modules\ExplorerSettings\`

2. Import the module:
   ```powershell
   Import-Module ExplorerSettings
   ```

## Basic Usage Examples

### Example 1: Enable file extensions for current user
```powershell
Enable-FileExtensions
```

### Example 2: Enable file extensions for current user and restart Explorer
```powershell
Enable-FileExtensions -RestartExplorer
```

### Example 3: Disable file extensions for current user
```powershell
Disable-FileExtensions
```

### Example 4: Enable file extensions for all users (requires admin)
```powershell
Enable-FileExtensions -Scope AllUsers -RestartExplorer
```

### Example 5: Set file extensions for local machine only
```powershell
Set-FileExtensionVisibility -Action Enable -Scope LocalMachine
```

### Example 6: Check current setting
```powershell
Get-FileExtensionVisibility

# Output:
# Scope                 : CurrentUser
# FileExtensionsVisible : True
# RegistryValue         : 0
# RegistryPath          : HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
```

### Example 7: Check local machine setting
```powershell
Get-FileExtensionVisibility -Scope LocalMachine
```

### Example 8: Manually restart Explorer
```powershell
Restart-WindowsExplorer
```

## Advanced Usage

### Example 9: Enable for all users except specific accounts
```powershell
Set-FileExtensionVisibility -Action Enable -Scope AllUsers -ExcludedUsers @("TempUser", "TestAccount")
```

### Example 10: Pipeline usage
```powershell
# Check current state, then toggle
$current = Get-FileExtensionVisibility
if ($current.FileExtensionsVisible) {
    Disable-FileExtensions
} else {
    Enable-FileExtensions
}
```

## Function Reference

### Set-FileExtensionVisibility
Primary function with full control over all parameters.

**Parameters:**
- `-Action` (Required): "Enable" or "Disable"
- `-Scope` (Optional): "CurrentUser" (default), "LocalMachine", or "AllUsers"
- `-RestartExplorer` (Switch): Restart Explorer immediately
- `-ExcludedUsers` (String[]): Users to exclude (AllUsers scope only)

### Enable-FileExtensions
Convenience wrapper to enable file extensions.

**Parameters:**
- `-Scope` (Optional): "CurrentUser" (default), "LocalMachine", or "AllUsers"
- `-RestartExplorer` (Switch): Restart Explorer immediately

### Disable-FileExtensions
Convenience wrapper to disable file extensions.

**Parameters:**
- `-Scope` (Optional): "CurrentUser" (default), "LocalMachine", or "AllUsers"
- `-RestartExplorer` (Switch): Restart Explorer immediately

### Get-FileExtensionVisibility
Query current file extension visibility setting.

**Parameters:**
- `-Scope` (Optional): "CurrentUser" (default) or "LocalMachine"

**Returns:** PSCustomObject with properties:
- `Scope`: The scope queried
- `FileExtensionsVisible`: Boolean indicating if extensions are visible
- `RegistryValue`: Raw registry value (0 = visible, 1 = hidden)
- `RegistryPath`: Full registry path

### Restart-WindowsExplorer
Restart Windows Explorer process.

**Parameters:**
- `-Force` (Switch): Force restart even if busy

## Scheduled Task Example

Create a scheduled task to enable file extensions for all new users:

```powershell
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' `
    -Argument '-NoProfile -Command "Import-Module ExplorerSettings; Enable-FileExtensions"'

$trigger = New-ScheduledTaskTrigger -AtLogOn

Register-ScheduledTask -TaskName "EnableFileExtensions" `
    -Action $action `
    -Trigger $trigger `
    -Description "Enable file extensions at user logon"
```

## Group Policy Alternative

For domain environments, you can also use Group Policy:
1. Open Group Policy Editor: `gpedit.msc`
2. Navigate to: User Configuration → Preferences → Windows Settings → Registry
3. Create new registry item:
   - Key Path: `Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`
   - Value Name: `HideFileExt`
   - Value Type: `REG_DWORD`
   - Value Data: `0` (enable) or `1` (disable)

## Troubleshooting

### Issue: Changes don't take effect
**Solution:** Use `-RestartExplorer` switch or manually restart Explorer

### Issue: "Access Denied" error
**Solution:** Run PowerShell as Administrator for LocalMachine/AllUsers scopes

### Issue: Settings revert after reboot
**Solution:** Ensure registry changes were applied to correct scope and user profile

### Issue: Module not found
**Solution:** Verify module is in correct path and run `Get-Module -ListAvailable ExplorerSettings`

## Notes

- Changes to LocalMachine affect the default for new users
- Changes to AllUsers modify all existing user profiles
- Explorer restart is only needed for immediate effect
- Registry value: `0` = Show Extensions, `1` = Hide Extensions
- The module handles user hive loading/unloading automatically

## Compatibility

- Windows 10 and later
- Windows Server 2016 and later
- PowerShell 5.1 and later
- PowerShell Core 7.x (Windows only)
