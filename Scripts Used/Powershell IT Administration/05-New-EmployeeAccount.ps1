
# ============================================================
# Script: 05-New-EmployeeAccount.ps1
# Purpose: Interactive Active Directory Employee Creation
# Domain: aklab.local
# ============================================================

Import-Module ActiveDirectory -ErrorAction Stop

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "     NEW EMPLOYEE ACCOUNT CREATION      " -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Ask for employee details
$FirstName = Read-Host "Enter employee first name"
$LastName  = Read-Host "Enter employee last name"
$Username  = Read-Host "What username do you want?"
$Department = Read-Host "Enter employee department"

# Ask for the OU where the account should be created
Write-Host "`nAvailable Organizational Units:" -ForegroundColor Yellow

Get-ADOrganizationalUnit -Filter * |
    Select-Object Name, DistinguishedName |
    Format-Table -AutoSize

$OUPath = Read-Host "Enter the target OU Distinguished Name"

# Check required fields
if (
    [string]::IsNullOrWhiteSpace($FirstName) -or
    [string]::IsNullOrWhiteSpace($LastName) -or
    [string]::IsNullOrWhiteSpace($Username) -or
    [string]::IsNullOrWhiteSpace($Department) -or
    [string]::IsNullOrWhiteSpace($OUPath)
) {
    Write-Host "All fields are required." -ForegroundColor Red
    return
}

# Check whether username already exists
$ExistingUser = Get-ADUser `
    -Filter "SamAccountName -eq '$Username'"

if ($ExistingUser) {
    Write-Host "This username already exists. Choose another." -ForegroundColor Red
    return
}

# Verify target OU
try {
    $TargetOU = Get-ADOrganizationalUnit `
        -Identity $OUPath `
        -ErrorAction Stop
}
catch {
    Write-Host "The OU was not found. Check its Distinguished Name." -ForegroundColor Red
    return
}

# Request the initial password securely
$Password = Read-Host "Enter initial password" -AsSecureString

# Display account details for confirmation
Write-Host "`n========== REVIEW DETAILS ==========" -ForegroundColor Cyan
Write-Host "Full name:  $FirstName $LastName"
Write-Host "Username:   $Username"
Write-Host "Department: $Department"
Write-Host "Target OU:  $($TargetOU.DistinguishedName)"
Write-Host "===================================="

$Confirm = Read-Host "Type YES to create this employee account"

if ($Confirm -cne "YES") {
    Write-Host "Account creation cancelled." -ForegroundColor Yellow
    return
}

# Create the account
try {
    New-ADUser `
        -Name "$FirstName $LastName" `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName $Username `
        -UserPrincipalName "$Username@aklab.local" `
        -Department $Department `
        -Path $TargetOU.DistinguishedName `
        -AccountPassword $Password `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -ErrorAction Stop

    Write-Host "`nEmployee account created successfully!" -ForegroundColor Green
    Write-Host "Username: $Username"
    Write-Host "Domain: aklab.local"
}
catch {
    Write-Host "`nAccount creation failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
