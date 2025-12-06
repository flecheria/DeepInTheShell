@{
    # Module metadata
    RootModule = 'ExplorerSettings.psm1'
    ModuleVersion = '2.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'Your Name'
    CompanyName = 'Your Company'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'PowerShell module for managing Windows Explorer file extension visibility settings across different scopes (CurrentUser, LocalMachine, AllUsers).'
    
    # Minimum PowerShell version
    PowerShellVersion = '5.1'
    
    # Compatible platforms
    CompatiblePSEditions = @('Desktop', 'Core')
    
    # Functions to export
    FunctionsToExport = @(
        'Set-FileExtensionVisibility',
        'Enable-FileExtensions',
        'Disable-FileExtensions',
        'Get-FileExtensionVisibility',
        'Restart-WindowsExplorer'
    )
    
    # Cmdlets to export (none)
    CmdletsToExport = @()
    
    # Variables to export (none)
    VariablesToExport = @()
    
    # Aliases to export (none)
    AliasesToExport = @()
    
    # Private data
    PrivateData = @{
        PSData = @{
            Tags = @('Windows', 'Explorer', 'FileExtensions', 'Registry', 'Configuration')
            LicenseUri = ''
            ProjectUri = ''
            ReleaseNotes = @'
Version 2.0.0
- Consolidated multiple scripts into single module
- Added scope-based control (CurrentUser, LocalMachine, AllUsers)
- Improved error handling and logging
- Added Get-FileExtensionVisibility function
- Added convenience functions Enable/Disable-FileExtensions
- Better privilege checking
- Optimized user hive loading/unloading
'@
        }
    }
}
