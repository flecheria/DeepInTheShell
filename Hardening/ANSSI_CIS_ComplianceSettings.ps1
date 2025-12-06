# Set password policy
Set-ADDefaultDomainPasswordPolicy -Identity domain.local -ComplexityEnabled $true -LockoutDuration 00:30:00 -LockoutObservationWindow 00:30:00 -LockoutThreshold 5 -MaxPasswordAge 90.00:00:00 -MinPasswordAge 1.00:00:00 -MinPasswordLength 14 -PasswordHistoryCount 24 -ReversibleEncryptionEnabled $false

# Configure UAC (User Account Control)
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 2
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1