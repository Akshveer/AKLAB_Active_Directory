
# ============================================================
# Script: 04-Export-OUInventory.ps1
# Purpose: Export all Active Directory Organizational Units
# Domain: aklab.local
# ============================================================

Import-Module ActiveDirectory -ErrorAction Stop

# Set the output file path
$ReportPath = "$env:USERPROFILE\Desktop\OU-Inventory.csv"

# Retrieve all Organizational Units
$OUs = Get-ADOrganizationalUnit `
    -Filter * `
    -Properties CanonicalName, Description

# Select the required information
$Report = $OUs | Select-Object `
    Name,
    DistinguishedName,
    CanonicalName,
    Description

# Display the OU inventory in PowerShell
$Report | Format-Table Name, CanonicalName -AutoSize

# Export the inventory to CSV
$Report | Export-Csv `
    -Path $ReportPath `
    -NoTypeInformation

# Display completion message
Write-Host "`nOU inventory generated successfully!" -ForegroundColor Green
Write-Host "Total OUs found: $($Report.Count)"
Write-Host "Report saved to: $ReportPath"
