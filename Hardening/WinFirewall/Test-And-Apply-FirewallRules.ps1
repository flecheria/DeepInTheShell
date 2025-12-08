# Test-And-Apply-FirewallRules.ps1

<#
.SYNOPSIS
    Tests and optionally applies HardeningKitty firewall rules
.PARAMETER Mode
    Test: Only check if rules exist
    Apply: Create missing rules
    Report: Generate detailed report
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Test", "Apply", "Report")]
    [string]$Mode = "Test",
    
    [Parameter(Mandatory=$false)]
    [string]$CsvPath = ".\firewall_rules.csv"
)

# Ensure running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Error "This script requires administrative privileges. Please run as Administrator."
    exit 1
}

function Test-FirewallRuleExists {
    param(
        [string]$DisplayName
    )
    
    try {
        $rule = Get-NetFirewallRule -DisplayName $DisplayName -PolicyStore ActiveStore -ErrorAction SilentlyContinue
        return ($null -ne $rule)
    } catch {
        return $false
    }
}

function Get-FirewallRuleStatus {
    param(
        [string]$DisplayName
    )
    
    try {
        $rule = Get-NetFirewallRule -DisplayName $DisplayName -PolicyStore ActiveStore -ErrorAction SilentlyContinue
        if ($rule) {
            return @{
                Exists = $true
                Enabled = $rule.Enabled
                Action = $rule.Action
                Direction = $rule.Direction
            }
        }
    } catch {
        # Rule doesn't exist
    }
    
    return @{
        Exists = $false
        Enabled = $null
        Action = $null
        Direction = $null
    }
}

function New-HardeningKittyFirewallRule {
    param(
        [string]$DisplayName,
        [string]$MethodArgument
    )
    
    # Parse the MethodArgument: Profile|Direction|Action|Protocol|LocalPort|Program
    $parts = $MethodArgument -split '\|'
    
    $fwProfile = $parts[0]
    $fwDirection = $parts[1]
    $fwAction = $parts[2]
    $fwProtocol = $parts[3]
    $fwLocalPort = $parts[4]
    $fwProgram = $parts[5]
    
    try {
        # Build parameters for New-NetFirewallRule
        $ruleParams = @{
            DisplayName = $DisplayName
            Profile = $fwProfile
            Direction = $fwDirection
            Action = $fwAction
            Enabled = 'True'
        }
        
        # Add protocol if specified
        if ($fwProtocol -and $fwProtocol -ne "") {
            $ruleParams['Protocol'] = $fwProtocol
        }
        
        # Add local port if specified (for port-based rules)
        if ($fwLocalPort -and $fwLocalPort -ne "") {
            $ports = $fwLocalPort -split ','
            $ruleParams['LocalPort'] = $ports
        }
        
        # Add program if specified (for application-based rules)
        if ($fwProgram -and $fwProgram -ne "") {
            # Expand environment variables
            $expandedPath = [Environment]::ExpandEnvironmentVariables($fwProgram)
            $ruleParams['Program'] = $expandedPath
        }
        
        # Create the rule
        $result = New-NetFirewallRule @ruleParams -ErrorAction Stop
        
        return @{
            Success = $true
            Message = "Rule created successfully"
            Rule = $result
        }
    } catch {
        return @{
            Success = $false
            Message = $_.Exception.Message
            Rule = $null
        }
    }
}

# Main execution
Write-Host "`n=== HardeningKitty Firewall Rules - $Mode Mode ===`n" -ForegroundColor Cyan

# Check if CSV exists
if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found: $CsvPath"
    exit 1
}

# Import the CSV
$rules = Import-Csv -Path $CsvPath

# Filter only FirewallRule entries
$firewallRules = $rules | Where-Object { $_.Method -eq "FirewallRule" }

Write-Host "Found $($firewallRules.Count) firewall rules to process`n" -ForegroundColor Yellow

$results = @()
$stats = @{
    Total = 0
    Existing = 0
    Missing = 0
    Created = 0
    Failed = 0
}

foreach ($rule in $firewallRules) {
    $stats.Total++
    
    $ruleStatus = Get-FirewallRuleStatus -DisplayName $rule.Name
    
    $result = [PSCustomObject]@{
        ID = $rule.ID
        Name = $rule.Name
        Exists = $ruleStatus.Exists
        Enabled = $ruleStatus.Enabled
        Action = $ruleStatus.Action
        Direction = $ruleStatus.Direction
        MethodArgument = $rule.MethodArgument
        Status = ""
        Message = ""
    }
    
    if ($ruleStatus.Exists) {
        $stats.Existing++
        $result.Status = "EXISTS"
        $result.Message = "Rule already exists (Enabled: $($ruleStatus.Enabled))"
        Write-Host "[+] " -ForegroundColor Green -NoNewline
        Write-Host "$($rule.Name) - Already exists"
    } else {
        $stats.Missing++
        
        if ($Mode -eq "Apply") {
            Write-Host "[!] " -ForegroundColor Yellow -NoNewline
            Write-Host "$($rule.Name) - Creating rule..."
            
            $createResult = New-HardeningKittyFirewallRule -DisplayName $rule.Name -MethodArgument $rule.MethodArgument
            
            if ($createResult.Success) {
                $stats.Created++
                $result.Status = "CREATED"
                $result.Message = $createResult.Message
                Write-Host "    [✓] Rule created successfully" -ForegroundColor Green
            } else {
                $stats.Failed++
                $result.Status = "FAILED"
                $result.Message = $createResult.Message
                Write-Host "    [✗] Failed: $($createResult.Message)" -ForegroundColor Red
            }
        } else {
            $result.Status = "MISSING"
            $result.Message = "Rule does not exist"
            Write-Host "[-] " -ForegroundColor Red -NoNewline
            Write-Host "$($rule.Name) - Not found"
        }
    }
    
    $results += $result
}

# Display summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Total rules processed: $($stats.Total)"
Write-Host "Existing rules: $($stats.Existing)" -ForegroundColor Green
Write-Host "Missing rules: $($stats.Missing)" -ForegroundColor Yellow

if ($Mode -eq "Apply") {
    Write-Host "Created rules: $($stats.Created)" -ForegroundColor Green
    if ($stats.Failed -gt 0) {
        Write-Host "Failed to create: $($stats.Failed)" -ForegroundColor Red
    }
}

# Generate report if requested
if ($Mode -eq "Report") {
    $reportPath = "FirewallRules_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $results | Export-Csv -Path $reportPath -NoTypeInformation
    Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor Cyan
}

Write-Host ""

# Test current configuration:
# powershell.\Test-And-Apply-FirewallRules.ps1 -Mode Test

# Generate detailed report:
# powershell.\Test-And-Apply-FirewallRules.ps1 -Mode Report

# Apply missing rules:
# powershell.\Test-And-Apply-FirewallRules.ps1 -Mode Apply