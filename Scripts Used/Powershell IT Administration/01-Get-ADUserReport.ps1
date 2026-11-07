
# ============================================================
# Script: 01-Get-ADUserReport.ps1
# Purpose: Generate an Active Directory user inventory report
# Domain: aklab.local
# ============================================================

# Load the Active Directory PowerShell module
Import-Module ActiveDirectory -ErrorAction Stop

# Define the output file path
$ReportPath = "$env:USERPROFILE\Desktop\AD-User-Report.csv"

# Retrieve all AD users and their department information
$Users = Get-ADUser -Filter * -Properties Department, EmailAddress

# Select the information needed for the report
$Report = $Users | Select-Object `
    Name,
    SamAccountName,
    Department,
    EmailAddress,
    Enabled

# Export the report to CSV
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

# Display confirmation
Write-Host "User report generated successfully!" -ForegroundColor Green
Write-Host "Report location: $ReportPath"
Write-Host "Total user accounts: $($Report.Count)"
