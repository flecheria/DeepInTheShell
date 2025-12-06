# Set power plan to High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Enable TRIM for SSDs
fsutil behavior set DisableDeleteNotify 0

# Disable hibernation (reclaims disk space)
powercfg -h off