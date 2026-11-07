
# ============================================================
# Script: 02-Find-DisabledAccounts.ps1
# Purpose: Identify disabled Active Directory accounts
# Domain: aklab.local
# ============================================================

Import-Module ActiveDirectory -ErrorAction Stop

$ReportPath = "$env:USERPROFILE\Desktop\Disabled-Accounts.csv"

# Find disabled user accounts
$DisabledUsers = Get-ADUser -Filter 'Enabled -eq $false' -Properties Department, WhenChanged

# Select the required report fields
$Report = $DisabledUsers | Select-Object `
    Name,
    SamAccountName,
    Department,
    Enabled,
    WhenChanged,
    DistinguishedName

# Display results
$Report | Format-Table Name, SamAccountName, Department, WhenChanged -AutoSize

# Export results to CSV
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "`nDisabled account audit completed." -ForegroundColor Green
Write-Host "Accounts found: $($Report.Count)"
Write-Host "Report location: $ReportPath"
