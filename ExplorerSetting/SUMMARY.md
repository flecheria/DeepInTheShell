# ExplorerSettings Module - Complete Package

## Package Contents

This package contains a fully optimized and organized PowerShell module for managing Windows Explorer file extension visibility. It consolidates your three original scripts into a professional, reusable module.

### Core Module Files
1. **ExplorerSettings.psm1** - Main module file with all functions
2. **ExplorerSettings.psd1** - Module manifest

### Utility Scripts
3. **Set-FileExtensionVisibility.ps1** - Standalone script (compatible with original script #1)
4. **Install-ExplorerSettings.ps1** - Installation helper
5. **Uninstall-ExplorerSettings.ps1** - Uninstallation helper
6. **Test-ExplorerSettings.ps1** - Testing and validation script

### Documentation
7. **README.md** - Complete documentation with examples
8. **QUICK-REFERENCE.md** - Quick command reference
9. **SUMMARY.md** - This file

## Key Improvements Over Original Scripts

### 1. Unified Architecture
- **Before**: 3 separate scripts with duplicated code
- **After**: Single module with reusable functions
- **Benefit**: Easier maintenance, consistent behavior

### 2. Enhanced Functionality
- **Scope Control**: CurrentUser, LocalMachine, or AllUsers
- **Query Capability**: `Get-FileExtensionVisibility` to check current state
- **Better Error Handling**: Comprehensive try-catch blocks with meaningful messages
- **Smart Hive Management**: Automatic loading/unloading of user registry hives

### 3. Professional Code Quality
- **Consistent Naming**: Follow PowerShell verb-noun conventions
- **Comprehensive Help**: Comment-based help for all functions
- **Parameter Validation**: ValidateSet attributes for safety
- **Verbose Logging**: Optional verbose output for troubleshooting
- **Best Practices**: Follows Microsoft PowerShell style guidelines

### 4. Multiple Usage Patterns

#### Pattern A: Module Import (Recommended)
```powershell
Import-Module ExplorerSettings
Enable-FileExtensions -RestartExplorer
```

#### Pattern B: Standalone Script (RMM/Automation Tools)
```powershell
.\Set-FileExtensionVisibility.ps1 -Action Enable -RestartExplorer
```

#### Pattern C: Environment Variables (Original Script #1 Compatible)
```powershell
$env:action = "Enable"
$env:restartExplorer = "true"
.\Set-FileExtensionVisibility.ps1
```

## Migration Guide

### From Original Script #1 (Complex Script)
**Original:**
```powershell
# Required parameters and switches
param([ValidateSet("Enable", "Disable")][String]$Action)
# Long script...
```

**New Module Equivalent:**
```powershell
Import-Module ExplorerSettings
Set-FileExtensionVisibility -Action Enable -Scope CurrentUser -RestartExplorer
```

**Or using standalone script:**
```powershell
.\Set-FileExtensionVisibility.ps1 -Action Enable -RestartExplorer
```

### From Original Script #2 (Simple Functions)
**Original:**
```powershell
function ShowFileExtensions() {
    Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . HideFileExt "0"
    Pop-Location
    Stop-Process -processName: Explorer -force
}
ShowFileExtensions
```

**New Module Equivalent:**
```powershell
Import-Module ExplorerSettings
Enable-FileExtensions -RestartExplorer
```

### From Original Script #3 (One-Liner)
**Original:**
```powershell
Stop-Process -ProcessName explorer -Force
Set-Itemproperty -path 'HKCU:\...\Advanced' -Name 'HideFileExt' -value 0
Start-Process explorer
```

**New Module Equivalent:**
```powershell
Import-Module ExplorerSettings
Enable-FileExtensions -RestartExplorer
```

## Installation Instructions

### Method 1: Quick Install (Recommended)
```powershell
# 1. Run installation script
.\Install-ExplorerSettings.ps1

# 2. Import and use
Import-Module ExplorerSettings
Enable-FileExtensions -RestartExplorer
```

### Method 2: Manual Install
```powershell
# 1. Create module directory
$modulePath = "$HOME\Documents\WindowsPowerShell\Modules\ExplorerSettings"
New-Item -Path $modulePath -ItemType Directory -Force

# 2. Copy files
Copy-Item ExplorerSettings.psm1, ExplorerSettings.psd1, README.md -Destination $modulePath

# 3. Import module
Import-Module ExplorerSettings
```

### Method 3: Use Standalone Script (No Installation)
```powershell
# Just run the standalone script directly
.\Set-FileExtensionVisibility.ps1 -Action Enable -RestartExplorer
```

## Function Reference

### Public Functions (Exported)

| Function | Purpose | Requires Admin |
|----------|---------|----------------|
| `Set-FileExtensionVisibility` | Main function with full control | Depends on Scope |
| `Enable-FileExtensions` | Enable file extensions (wrapper) | Depends on Scope |
| `Disable-FileExtensions` | Disable file extensions (wrapper) | Depends on Scope |
| `Get-FileExtensionVisibility` | Query current setting | No |
| `Restart-WindowsExplorer` | Restart Explorer process | No |

### Private Functions (Internal Use)

| Function | Purpose |
|----------|---------|
| `Test-IsElevated` | Check admin privileges |
| `Test-IsSystem` | Check if running as SYSTEM |
| `Get-UserHives` | Retrieve user profile information |
| `Set-RegistryValue` | Set registry values with error handling |
| `Restart-WindowsExplorer` | Restart Explorer (also public) |

## Testing the Module

### Run Automated Tests
```powershell
.\Test-ExplorerSettings.ps1
```

### Manual Testing
```powershell
# 1. Import module
Import-Module ExplorerSettings

# 2. Check current state
Get-FileExtensionVisibility

# 3. Enable extensions
Enable-FileExtensions

# 4. Verify change
Get-FileExtensionVisibility

# 5. Disable extensions
Disable-FileExtensions

# 6. Verify change
Get-FileExtensionVisibility
```

## Deployment Scenarios

### Scenario 1: Workstation Image/OSD
```powershell
# Run during image creation to set default for all new users
Enable-FileExtensions -Scope LocalMachine
```

### Scenario 2: RMM Tool Deployment
```powershell
# Use standalone script with environment variables
$env:action = "Enable"
$env:scope = "AllUsers"
$env:restartExplorer = "true"
.\Set-FileExtensionVisibility.ps1
```

### Scenario 3: Group Policy Startup Script
```powershell
# Add to Computer Configuration > Startup Scripts
Import-Module C:\IT\ExplorerSettings\ExplorerSettings.psm1
Enable-FileExtensions -Scope CurrentUser
```

### Scenario 4: SCCM/Intune Package
```powershell
# Install phase
.\Install-ExplorerSettings.ps1 -Scope AllUsers

# Configure phase
Import-Module ExplorerSettings
Enable-FileExtensions -Scope AllUsers -RestartExplorer
```

### Scenario 5: Help Desk Quick Fix
```powershell
# Remote PowerShell session
Enter-PSSession -ComputerName PC-NAME
Import-Module ExplorerSettings
Enable-FileExtensions -RestartExplorer
```

## Compatibility Matrix

| Platform | Version | Status |
|----------|---------|--------|
| Windows 10 | All versions | ✓ Fully Supported |
| Windows 11 | All versions | ✓ Fully Supported |
| Windows Server 2016 | All versions | ✓ Fully Supported |
| Windows Server 2019 | All versions | ✓ Fully Supported |
| Windows Server 2022 | All versions | ✓ Fully Supported |
| PowerShell 5.1 | - | ✓ Fully Supported |
| PowerShell 7.x | Windows only | ✓ Fully Supported |

## Advantages of This Module

### 1. Code Reusability
- Write once, use everywhere
- Consistent behavior across all systems
- Easy to update and maintain

### 2. Professional Features
- Parameter validation
- Comprehensive error handling
- Detailed logging and feedback
- Help documentation built-in

### 3. Flexibility
- Multiple scopes (CurrentUser, LocalMachine, AllUsers)
- Optional Explorer restart
- User exclusion capability
- Query current state

### 4. Safety
- Privilege checking before operations
- Proper hive loading/unloading
- Graceful error handling
- No data loss risks

### 5. Maintainability
- Well-organized code structure
- Clear function separation
- Inline documentation
- Test suite included

## Support and Documentation

### Getting Help
```powershell
# View function help
Get-Help Enable-FileExtensions -Full
Get-Help Set-FileExtensionVisibility -Examples
Get-Help Get-FileExtensionVisibility -Detailed

# List all functions
Get-Command -Module ExplorerSettings

# View module information
Get-Module ExplorerSettings | Select-Object *
```

### Additional Resources
- **README.md**: Complete documentation with examples
- **QUICK-REFERENCE.md**: Common commands and scenarios
- **Test-ExplorerSettings.ps1**: Validation and testing

## Troubleshooting

### Issue: Module not found after installation
**Solution:**
```powershell
# Refresh module cache
Get-Module -ListAvailable -Refresh

# Or restart PowerShell
```

### Issue: Access denied errors
**Solution:**
```powershell
# Run PowerShell as Administrator for LocalMachine/AllUsers scopes
# Right-click PowerShell -> "Run as administrator"
```

### Issue: Changes not visible in Explorer
**Solution:**
```powershell
# Restart Windows Explorer
Restart-WindowsExplorer

# Or add -RestartExplorer switch to commands
Enable-FileExtensions -RestartExplorer
```

### Issue: Standalone script can't find module
**Solution:**
```powershell
# Ensure ExplorerSettings.psm1 is in same directory as Set-FileExtensionVisibility.ps1
# Or install module and it will work automatically
```

## License and Usage

This module is provided as-is for your use. Feel free to:
- Modify for your environment
- Deploy across your organization
- Include in automation frameworks
- Customize function behavior

## Version History

**Version 2.0.0** (Current)
- Consolidated three scripts into unified module
- Added scope-based control (CurrentUser, LocalMachine, AllUsers)
- Added Get-FileExtensionVisibility query function
- Added convenience wrapper functions
- Improved error handling and logging
- Added comprehensive documentation
- Added installation/uninstallation scripts
- Added test suite
- Optimized user hive management
- Added proper module manifest

**Original Scripts** (v1.0)
- Script 1: Complex implementation with user profile iteration
- Script 2: Simple function-based implementation
- Script 3: One-liner implementation

## Next Steps

1. **Test in Lab Environment**
   ```powershell
   .\Test-ExplorerSettings.ps1
   ```

2. **Install Module**
   ```powershell
   .\Install-ExplorerSettings.ps1
   ```

3. **Deploy to Production**
   - Use standalone script for RMM tools
   - Or install module on admin workstations
   - Or include in system images

4. **Document Your Deployment**
   - Note which scope you use
   - Document any excluded users
   - Track deployed systems

5. **Provide Feedback**
   - Report any issues
   - Suggest enhancements
   - Share deployment experiences

## Summary

This module provides a professional, maintainable, and flexible solution for managing file extension visibility in Windows Explorer. It consolidates your original scripts while adding significant new capabilities and following PowerShell best practices.

**Key Benefits:**
✓ Single, maintainable codebase
✓ Multiple usage patterns
✓ Enhanced functionality
✓ Professional code quality
✓ Comprehensive documentation
✓ Easy deployment
✓ Backward compatible with original scripts

**Recommended Use:**
For new deployments, use the module approach. For existing automation that calls your original scripts, the standalone script provides backward compatibility while leveraging the improved module code.
