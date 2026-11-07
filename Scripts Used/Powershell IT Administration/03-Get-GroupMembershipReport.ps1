
# ============================================================
# Script: 03-Get-GroupMembershipReport.ps1
# Purpose: Export members of an Active Directory group
# Domain: aklab.local
# ============================================================

Import-Module ActiveDirectory -ErrorAction Stop

# Specify the Active Directory group
$GroupName = "GG_Employees"

# Define the output file
$ReportPath = "$env:USERPROFILE\Desktop\Group-Membership-Report.csv"

# Calculate the total number of members
$MemberCount = @($Members).Count

try {
    # Find the group
    $Group = Get-ADGroup -Identity $GroupName -ErrorAction Stop

    # Retrieve direct and nested group members
    $Members = Get-ADGroupMember -Identity $Group -Recursive -ErrorAction Stop

    # Select useful information
    $Report = $Members | Select-Object `
        Name,
        SamAccountName,
        ObjectClass,
        DistinguishedName

    # Display results
    if ($Report) {
        $Report | Format-Table Name, SamAccountName, ObjectClass -AutoSize
    }
    else {
        Write-Host "No members were found in the group." -ForegroundColor Yellow
    }

    # Export results to CSV
    $Report | Export-Csv -Path $ReportPath -NoTypeInformation

    Write-Host "`nGroup report generated successfully!" -ForegroundColor Green
    Write-Host "Group: $($Group.Name)"
    Write-Host "Members found: $MemberCount"
    Write-Host "Report location: $ReportPath"
}
catch {
    Write-Host "`nUnable to generate the group report." -ForegroundColor Red
    Write-Host $_.Exception.Message
}
