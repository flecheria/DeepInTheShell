# Disable unnecessary services
Stop-Service -Name "DiagTrack" -Force
Set-Service -Name "DiagTrack" -StartupType Disabled

Stop-Service -Name "dmwappushservice" -Force
Set-Service -Name "dmwappushservice" -StartupType Disabled

Stop-Service -Name "lfsvc" -Force
Set-Service -Name "lfsvc" -StartupType Disabled