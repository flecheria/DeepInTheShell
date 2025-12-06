#Requires -Version 5.1

<#
.SYNOPSIS
    PowerShell module for managing Windows Explorer file extension visibility settings.

.DESCRIPTION
    This module provides functions to enable/disable file extension visibility in Windows Explorer
    for current user, local machine, or all user profiles on the system.

.NOTES
    Author: Optimized Script
    Version: 2.0
    Minimum OS: Windows 10, Windows Server 2016
#>

#region Private Helper Functions

function Test-IsElevated {
    <#
    .SYNOPSIS
        Checks if the current PowerShell session is running with administrator privileges.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsSystem {
    <#
    .SYNOPSIS
        Checks if the current session is running as SYSTEM account.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return ($identity.Name -like "NT AUTHORITY*" -or $identity.IsSystem)
}

function Get-UserHives {
    <#
    .SYNOPSIS
        Retrieves user profile information including registry hive paths.
    
    .PARAMETER Type
        Type of users to retrieve: AzureAD, DomainAndLocal, or All.
    
    .PARAMETER ExcludedUsers
        Array of usernames to exclude from results.
    
    .PARAMETER IncludeDefault
        Include the Default user profile in results.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('AzureAD', 'DomainAndLocal', 'All')]
        [string]$Type = "All",
        
        [Parameter()]
        [string[]]$ExcludedUsers,
        
        [Parameter()]
        [switch]$IncludeDefault
    )
    
    # Define SID patterns based on user type
    $patterns = switch ($Type) {
        "AzureAD"        { "S-1-12-1-(\d+-?){4}$" }
        "DomainAndLocal" { "S-1-5-21-(\d+-?){4}$" }
        "All"            { "S-1-12-1-(\d+-?){4}$", "S-1-5-21-(\d+-?){4}$" }
    }
    
    # Retrieve user profiles
    $userProfiles = foreach ($pattern in $patterns) {
        Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.PSChildName -match $pattern } |
            Select-Object @{Name = "SID"; Expression = { $_.PSChildName } },
                         @{Name = "Username"; Expression = { $_.ProfileImagePath | Split-Path -Leaf } },
                         @{Name = "UserHive"; Expression = { "$($_.ProfileImagePath)\NTuser.dat" } },
                         @{Name = "Path"; Expression = { $_.ProfileImagePath } }
    }
    
    # Add Default profile if requested
    if ($IncludeDefault) {
        $defaultProfile = [PSCustomObject]@{
            Username = "Default"
            SID      = "DefaultProfile"
            UserHive = "$env:SystemDrive\Users\Default\NTUSER.DAT"
            Path     = "$env:SystemDrive\Users\Default"
        }
        
        if ($ExcludedUsers -notcontains $defaultProfile.Username) {
            $defaultProfile
        }
    }
    
    # Return filtered profiles
    $userProfiles | Where-Object { $ExcludedUsers -notcontains $_.Username }
}

function Set-RegistryValue {
    <#
    .SYNOPSIS
        Sets a registry value with proper error handling and logging.
    
    .PARAMETER Path
        Registry path where the value will be set.
    
    .PARAMETER Name
        Name of the registry value.
    
    .PARAMETER Value
        Value to set.
    
    .PARAMETER PropertyType
        Type of registry value (DWord, String, etc.).
    
    .PARAMETER Quiet
        Suppress output messages.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        $Value,
        
        [Parameter()]
        [ValidateSet("DWord", "QWord", "String", "ExpandedString", "Binary", "MultiString")]
        [string]$PropertyType = "DWord",
        
        [Parameter()]
        [switch]$Quiet
    )
    
    try {
        # Ensure registry path exists
        if (!(Test-Path -Path $Path)) {
            New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
            if (!$Quiet) {
                Write-Verbose "Created registry path: $Path"
            }
        }
        
        # Check current value
        $currentValue = $null
        $valueExists = $null -ne ($currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue)
        
        if ($valueExists) {
            $currentValue = $currentValue.$Name
            if ($currentValue -eq $Value) {
                if (!$Quiet) {
                    Write-Verbose "$Path\$Name is already set to '$Value'"
                }
                return $true
            }
            
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force -ErrorAction Stop | Out-Null
            if (!$Quiet) {
                Write-Host "$Path\$Name changed from $currentValue to $Value"
            }
        }
        else {
            New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -Force -ErrorAction Stop | Out-Null
            if (!$Quiet) {
                Write-Host "Set $Path\$Name to $Value"
            }
        }
        
        return $true
    }
    catch {
        Write-Error "Failed to set registry value $Name at $Path`: $($_.Exception.Message)"
        return $false
    }
}

function Restart-WindowsExplorer {
    <#
    .SYNOPSIS
        Restarts Windows Explorer process.
    
    .PARAMETER Force
        Force restart even if Explorer is busy.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Force
    )
    
    Write-Host "`nRestarting Windows Explorer..."
    
    try {
        if (Test-IsSystem) {
            # Stop all Explorer instances when running as SYSTEM
            Get-Process -Name "explorer" -ErrorAction Stop | Stop-Process -Force
        }
        else {
            # Only stop Explorer for current session
            $currentSessionId = (Get-Process -PID $PID).SessionId
            Get-Process -Name "explorer" -ErrorAction Stop |
                Where-Object { $_.SessionId -eq $currentSessionId } |
                Stop-Process -Force
        }
        
        Start-Sleep -Seconds 1
        
        # Restart Explorer if not running as SYSTEM
        if (!(Test-IsSystem) -and !(Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
            Start-Process -FilePath "$env:SystemRoot\explorer.exe"
        }
        
        Write-Host "Windows Explorer restarted successfully." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to restart Windows Explorer: $($_.Exception.Message)"
        return $false
    }
}

#endregion

#region Public Functions

function Set-FileExtensionVisibility {
    <#
    .SYNOPSIS
        Sets file extension visibility in Windows Explorer.
    
    .DESCRIPTION
        Enables or disables file extension visibility for the current user, local machine,
        or all user profiles on the system.
    
    .PARAMETER Action
        Enable or Disable file extension visibility.
    
    .PARAMETER Scope
        Scope of the change: CurrentUser, LocalMachine, or AllUsers.
    
    .PARAMETER RestartExplorer
        Restart Windows Explorer to apply changes immediately.
    
    .PARAMETER ExcludedUsers
        User profiles to exclude when using AllUsers scope.
    
    .EXAMPLE
        Set-FileExtensionVisibility -Action Enable -Scope CurrentUser
        Enables file extensions for the current user.
    
    .EXAMPLE
        Set-FileExtensionVisibility -Action Disable -Scope AllUsers -RestartExplorer
        Disables file extensions for all users and restarts Explorer.
    
    .NOTES
        Requires administrator privileges for LocalMachine and AllUsers scopes.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("Enable", "Disable")]
        [string]$Action,
        
        [Parameter()]
        [ValidateSet("CurrentUser", "LocalMachine", "AllUsers")]
        [string]$Scope = "CurrentUser",
        
        [Parameter()]
        [switch]$RestartExplorer,
        
        [Parameter()]
        [string[]]$ExcludedUsers
    )
    
    begin {
        $regValue = if ($Action -eq "Enable") { 0 } else { 1 }
        $actionVerb = $Action.ToLower() + "d"
        $exitCode = 0
        
        # Check privileges for elevated scopes
        if ($Scope -in @("LocalMachine", "AllUsers") -and !(Test-IsSystem) -and !(Test-IsElevated)) {
            Write-Error "Administrator privileges required for scope '$Scope'"
            return
        }
    }
    
    process {
        switch ($Scope) {
            "CurrentUser" {
                Write-Host "[Info] ${Action}ing file extensions for current user ($env:USERNAME)"
                
                $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                $success = Set-RegistryValue -Path $regPath -Name "HideFileExt" -Value $regValue
                
                if ($success) {
                    Write-Host "[Success] File extensions $actionVerb for $env:USERNAME" -ForegroundColor Green
                }
                else {
                    $exitCode = 1
                }
            }
            
            "LocalMachine" {
                Write-Host "[Info] ${Action}ing file extensions for local machine"
                
                $regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                $success = Set-RegistryValue -Path $regPath -Name "HideFileExt" -Value $regValue
                
                if ($success) {
                    Write-Host "[Success] File extensions $actionVerb for local machine" -ForegroundColor Green
                }
                else {
                    $exitCode = 1
                }
            }
            
            "AllUsers" {
                # Set for local machine first
                Write-Host "[Info] ${Action}ing file extensions for local machine"
                $regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                Set-RegistryValue -Path $regPath -Name "HideFileExt" -Value $regValue -Quiet | Out-Null
                
                # Get all user profiles
                $userProfiles = Get-UserHives -Type "All" -ExcludedUsers $ExcludedUsers
                $loadedProfiles = [System.Collections.Generic.List[object]]::new()
                
                foreach ($profile in $userProfiles) {
                    # Load user hive if not already loaded
                    if (!(Test-Path "Registry::HKEY_USERS\$($profile.SID)")) {
                        Start-Process -FilePath "cmd.exe" -ArgumentList "/C reg.exe LOAD HKU\$($profile.SID) `"$($profile.UserHive)`"" -Wait -WindowStyle Hidden
                        $loadedProfiles.Add($profile)
                    }
                    
                    Write-Host "[Info] ${Action}ing file extensions for user $($profile.Username)"
                    
                    $regPath = "Registry::HKEY_USERS\$($profile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                    $success = Set-RegistryValue -Path $regPath -Name "HideFileExt" -Value $regValue -Quiet
                    
                    if ($success) {
                        Write-Host "[Success] File extensions $actionVerb for $($profile.Username)" -ForegroundColor Green
                    }
                    else {
                        $exitCode = 1
                    }
                }
                
                # Unload temporarily loaded hives
                if ($loadedProfiles.Count -gt 0) {
                    [System.GC]::Collect()
                    Start-Sleep -Milliseconds 500
                    
                    foreach ($profile in $loadedProfiles) {
                        Start-Process -FilePath "cmd.exe" -ArgumentList "/C reg.exe UNLOAD HKU\$($profile.SID)" -Wait -WindowStyle Hidden | Out-Null
                    }
                }
            }
        }
        
        # Restart Explorer if requested
        if ($RestartExplorer) {
            if (!(Restart-WindowsExplorer)) {
                $exitCode = 1
            }
        }
        else {
            Write-Warning "You may need to restart Windows Explorer for changes to take effect immediately."
        }
    }
    
    end {
        if ($exitCode -ne 0) {
            Write-Warning "Operation completed with errors."
        }
    }
}

function Enable-FileExtensions {
    <#
    .SYNOPSIS
        Enables file extension visibility in Windows Explorer.
    
    .DESCRIPTION
        Convenience function to enable file extensions. Wrapper around Set-FileExtensionVisibility.
    
    .PARAMETER Scope
        Scope of the change: CurrentUser, LocalMachine, or AllUsers.
    
    .PARAMETER RestartExplorer
        Restart Windows Explorer to apply changes immediately.
    
    .EXAMPLE
        Enable-FileExtensions
        Enables file extensions for the current user.
    
    .EXAMPLE
        Enable-FileExtensions -Scope AllUsers -RestartExplorer
        Enables file extensions for all users and restarts Explorer.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("CurrentUser", "LocalMachine", "AllUsers")]
        [string]$Scope = "CurrentUser",
        
        [Parameter()]
        [switch]$RestartExplorer
    )
    
    Set-FileExtensionVisibility -Action Enable -Scope $Scope -RestartExplorer:$RestartExplorer
}

function Disable-FileExtensions {
    <#
    .SYNOPSIS
        Disables file extension visibility in Windows Explorer.
    
    .DESCRIPTION
        Convenience function to disable file extensions. Wrapper around Set-FileExtensionVisibility.
    
    .PARAMETER Scope
        Scope of the change: CurrentUser, LocalMachine, or AllUsers.
    
    .PARAMETER RestartExplorer
        Restart Windows Explorer to apply changes immediately.
    
    .EXAMPLE
        Disable-FileExtensions
        Disables file extensions for the current user.
    
    .EXAMPLE
        Disable-FileExtensions -Scope AllUsers -RestartExplorer
        Disables file extensions for all users and restarts Explorer.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("CurrentUser", "LocalMachine", "AllUsers")]
        [string]$Scope = "CurrentUser",
        
        [Parameter()]
        [switch]$RestartExplorer
    )
    
    Set-FileExtensionVisibility -Action Disable -Scope $Scope -RestartExplorer:$RestartExplorer
}

function Get-FileExtensionVisibility {
    <#
    .SYNOPSIS
        Gets the current file extension visibility setting.
    
    .DESCRIPTION
        Retrieves the current HideFileExt registry value for the specified scope.
    
    .PARAMETER Scope
        Scope to check: CurrentUser or LocalMachine.
    
    .EXAMPLE
        Get-FileExtensionVisibility
        Returns whether file extensions are currently visible for the current user.
    
    .EXAMPLE
        Get-FileExtensionVisibility -Scope LocalMachine
        Returns the local machine setting for file extension visibility.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("CurrentUser", "LocalMachine")]
        [string]$Scope = "CurrentUser"
    )
    
    $regPath = switch ($Scope) {
        "CurrentUser"   { "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" }
        "LocalMachine"  { "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" }
    }
    
    try {
        $value = Get-ItemProperty -Path $regPath -Name "HideFileExt" -ErrorAction Stop
        $hideValue = $value.HideFileExt
        
        [PSCustomObject]@{
            Scope              = $Scope
            FileExtensionsVisible = ($hideValue -eq 0)
            RegistryValue      = $hideValue
            RegistryPath       = $regPath
        }
    }
    catch {
        Write-Warning "Could not retrieve setting for scope '$Scope'. Setting may not be configured."
        return $null
    }
}

#endregion

# Export public functions
Export-ModuleMember -Function @(
    'Set-FileExtensionVisibility',
    'Enable-FileExtensions',
    'Disable-FileExtensions',
    'Get-FileExtensionVisibility',
    'Restart-WindowsExplorer'
)
