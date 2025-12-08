# Audit M365

## Scuba Gear

```shell
# Install ScubaGear
Install-Module -Name ScubaGear

# Run assessment against M365
Invoke-SCuBA -ProductNames "aad", "defender", "exo", "powerplatform", "sharepoint", "teams"

# Generates HTML report with pass/fail results based on CISA baselines
```

## Reference

[](https://github.com/cisagov/ScubaGear)
