# ExplorerSettings Module - File Index

## Quick Start

**New to this module?** Start here:
1. Read [SUMMARY.md](computer:///mnt/user-data/outputs/SUMMARY.md) for overview
2. Run `Install-ExplorerSettings.ps1` to install
3. Check [QUICK-REFERENCE.md](computer:///mnt/user-data/outputs/QUICK-REFERENCE.md) for commands

## File Directory

### 📦 Core Module Files (Required)
These files make up the actual PowerShell module:

| File | Size | Purpose |
|------|------|---------|
| **[ExplorerSettings.psm1](computer:///mnt/user-data/outputs/ExplorerSettings.psm1)** | 17 KB | Main module file with all functions |
| **[ExplorerSettings.psd1](computer:///mnt/user-data/outputs/ExplorerSettings.psd1)** | 1.6 KB | Module manifest (metadata) |

### 🛠️ Utility Scripts (Optional but Recommended)
Helper scripts for installation, testing, and standalone use:

| File | Size | Purpose |
|------|------|---------|
| **[Set-FileExtensionVisibility.ps1](computer:///mnt/user-data/outputs/Set-FileExtensionVisibility.ps1)** | 2.7 KB | Standalone script (backward compatible with original Script #1) |
| **[Install-ExplorerSettings.ps1](computer:///mnt/user-data/outputs/Install-ExplorerSettings.ps1)** | 5.5 KB | Automated installation script |
| **[Uninstall-ExplorerSettings.ps1](computer:///mnt/user-data/outputs/Uninstall-ExplorerSettings.ps1)** | 3.5 KB | Automated uninstallation script |
| **[Test-ExplorerSettings.ps1](computer:///mnt/user-data/outputs/Test-ExplorerSettings.ps1)** | 5.1 KB | Testing and validation script |

### 📚 Documentation Files
Comprehensive guides and references:

| File | Size | Purpose |
|------|------|---------|
| **[README.md](computer:///mnt/user-data/outputs/README.md)** | 5.1 KB | Complete usage documentation with examples |
| **[QUICK-REFERENCE.md](computer:///mnt/user-data/outputs/QUICK-REFERENCE.md)** | 5.1 KB | Quick command reference and common scenarios |
| **[SUMMARY.md](computer:///mnt/user-data/outputs/SUMMARY.md)** | 12 KB | Package overview and migration guide |
| **[COMPARISON.md](computer:///mnt/user-data/outputs/COMPARISON.md)** | 12 KB | Detailed comparison with original scripts |
| **INDEX.md** | This file | File directory and navigation guide |

## Usage Scenarios

### Scenario 1: I want to install and use the module
```
Files needed:
1. ExplorerSettings.psm1
2. ExplorerSettings.psd1
3. Install-ExplorerSettings.ps1 (optional, for easy install)

Steps:
1. Run: .\Install-ExplorerSettings.ps1
2. Import: Import-Module ExplorerSettings
3. Use: Enable-FileExtensions -RestartExplorer
```

### Scenario 2: I want a standalone script (no installation)
```
Files needed:
1. Set-FileExtensionVisibility.ps1
2. ExplorerSettings.psm1 (must be in same directory)

Steps:
1. Place both files in same directory
2. Run: .\Set-FileExtensionVisibility.ps1 -Action Enable -RestartExplorer
```

### Scenario 3: I want to understand what changed
```
Files to read:
1. SUMMARY.md - Overview and key improvements
2. COMPARISON.md - Detailed comparison with original scripts
3. README.md - Full documentation
```

### Scenario 4: I just need quick commands
```
File to read:
1. QUICK-REFERENCE.md - All common commands and examples
```

### Scenario 5: I want to test before deploying
```
Files needed:
1. ExplorerSettings.psm1
2. ExplorerSettings.psd1
3. Test-ExplorerSettings.ps1

Steps:
1. Place all files in same directory
2. Run: .\Test-ExplorerSettings.ps1
3. Review test results
```

## Documentation Reading Order

### For Quick Implementation (10 minutes)
1. **QUICK-REFERENCE.md** - Get started fast
2. **Install-ExplorerSettings.ps1** - Run installation
3. Start using the module

### For Complete Understanding (30 minutes)
1. **SUMMARY.md** - Understand the package
2. **README.md** - Learn all features
3. **COMPARISON.md** - See improvements over original
4. **QUICK-REFERENCE.md** - Reference for daily use

### For Technical Review (60 minutes)
1. **SUMMARY.md** - Package overview
2. **COMPARISON.md** - Technical comparison
3. **ExplorerSettings.psm1** - Review source code
4. **Test-ExplorerSettings.ps1** - Run tests
5. **README.md** - Complete documentation

## File Dependencies

```
ExplorerSettings Module
│
├── Core Module (Required for module usage)
│   ├── ExplorerSettings.psm1 ← Main module
│   └── ExplorerSettings.psd1 ← Manifest
│
├── Standalone Script (Alternative to module)
│   ├── Set-FileExtensionVisibility.ps1 ← Standalone script
│   └── ExplorerSettings.psm1 ← Required by standalone
│
├── Installation Tools (Optional)
│   ├── Install-ExplorerSettings.ps1 ← Installs module
│   ├── Uninstall-ExplorerSettings.ps1 ← Removes module
│   └── Test-ExplorerSettings.ps1 ← Tests functionality
│
└── Documentation (Reference)
    ├── README.md ← Complete guide
    ├── QUICK-REFERENCE.md ← Quick commands
    ├── SUMMARY.md ← Package overview
    ├── COMPARISON.md ← vs Original scripts
    └── INDEX.md ← This file
```

## Deployment Package Options

### Option A: Full Package (Recommended)
```
Include all files for complete functionality and documentation
Size: ~70 KB total
```

### Option B: Module Only
```
Files needed:
- ExplorerSettings.psm1
- ExplorerSettings.psd1
- README.md (optional but recommended)
Size: ~23 KB
```

### Option C: Standalone Only
```
Files needed:
- Set-FileExtensionVisibility.ps1
- ExplorerSettings.psm1
Size: ~20 KB
```

### Option D: Documentation Only
```
Files needed:
- All .md files
Size: ~45 KB
Use for: Review before deployment
```

## File Sizes Summary

| Category | Files | Total Size |
|----------|-------|------------|
| Core Module | 2 files | ~19 KB |
| Utility Scripts | 4 files | ~17 KB |
| Documentation | 5 files | ~49 KB |
| **Total Package** | **11 files** | **~85 KB** |

## Module Functions Quick Reference

### Public Functions (Use These)
```powershell
# Main function
Set-FileExtensionVisibility -Action Enable|Disable -Scope CurrentUser|LocalMachine|AllUsers [-RestartExplorer]

# Convenience wrappers
Enable-FileExtensions [-Scope CurrentUser|LocalMachine|AllUsers] [-RestartExplorer]
Disable-FileExtensions [-Scope CurrentUser|LocalMachine|AllUsers] [-RestartExplorer]

# Query function
Get-FileExtensionVisibility [-Scope CurrentUser|LocalMachine]

# Utility function
Restart-WindowsExplorer
```

### Get More Help
```powershell
# List all module commands
Get-Command -Module ExplorerSettings

# Get detailed help
Get-Help Enable-FileExtensions -Full
Get-Help Set-FileExtensionVisibility -Examples
Get-Help Get-FileExtensionVisibility -Detailed
```

## Original Scripts Mapping

| Original Script | New Equivalent | File |
|----------------|----------------|------|
| Script #1 (Complex) | `Set-FileExtensionVisibility.ps1` | Standalone script |
| Script #2 (Enable) | `Enable-FileExtensions` | Module function |
| Script #2 (Disable) | `Disable-FileExtensions` | Module function |
| Script #3 (One-liner) | `Enable-FileExtensions -RestartExplorer` | Module function |

## Common Tasks Reference

| Task | Command | File Reference |
|------|---------|----------------|
| Install module | `.\Install-ExplorerSettings.ps1` | Install-ExplorerSettings.ps1 |
| Enable extensions | `Enable-FileExtensions` | ExplorerSettings.psm1 |
| Disable extensions | `Disable-FileExtensions` | ExplorerSettings.psm1 |
| Check current state | `Get-FileExtensionVisibility` | ExplorerSettings.psm1 |
| Run tests | `.\Test-ExplorerSettings.ps1` | Test-ExplorerSettings.ps1 |
| Uninstall module | `.\Uninstall-ExplorerSettings.ps1` | Uninstall-ExplorerSettings.ps1 |
| Get help | `Get-Help Enable-FileExtensions` | Built-in |

## Support Resources

### Getting Started
- **Start here**: [SUMMARY.md](computer:///mnt/user-data/outputs/SUMMARY.md)
- **Quick commands**: [QUICK-REFERENCE.md](computer:///mnt/user-data/outputs/QUICK-REFERENCE.md)

### Understanding Changes
- **What's new**: [COMPARISON.md](computer:///mnt/user-data/outputs/COMPARISON.md)
- **Migration guide**: [SUMMARY.md](computer:///mnt/user-data/outputs/SUMMARY.md) (Migration section)

### Complete Documentation
- **Full guide**: [README.md](computer:///mnt/user-data/outputs/README.md)
- **Built-in help**: `Get-Help Enable-FileExtensions -Full`

### Testing and Validation
- **Test script**: [Test-ExplorerSettings.ps1](computer:///mnt/user-data/outputs/Test-ExplorerSettings.ps1)
- **Source code**: [ExplorerSettings.psm1](computer:///mnt/user-data/outputs/ExplorerSettings.psm1)

## Next Steps

1. **Review**: Read [SUMMARY.md](computer:///mnt/user-data/outputs/SUMMARY.md) for package overview
2. **Test**: Run [Test-ExplorerSettings.ps1](computer:///mnt/user-data/outputs/Test-ExplorerSettings.ps1) in lab
3. **Deploy**: Use [Install-ExplorerSettings.ps1](computer:///mnt/user-data/outputs/Install-ExplorerSettings.ps1) to install
4. **Reference**: Keep [QUICK-REFERENCE.md](computer:///mnt/user-data/outputs/QUICK-REFERENCE.md) handy
5. **Maintain**: Update single module file as needed

## Version Information

**Module Version**: 2.0.0
**PowerShell Version**: 5.1+ required
**OS Compatibility**: Windows 10+, Server 2016+
**Package Date**: December 2024

---

**Questions?** Check the documentation files above or run `Get-Help <FunctionName> -Full` for detailed help.
