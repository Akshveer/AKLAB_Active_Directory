Import-Module ActiveDirectory



$reportPath = Join-Path (\[Environment]::GetFolderPath('Desktop')) 'AKLAB\_Server\_Report.html'



\# HTML-encode values included outside tables.

function Encode-Html($Value) {

&#x20;   \[System.Net.WebUtility]::HtmlEncode(\[string]$Value)

}



function New-ReportSection {

&#x20;   param(

&#x20;       \[string]$Title,

&#x20;       \[object\[]]$Data

&#x20;   )



&#x20;   "<h2>$(Encode-Html $Title)</h2>"



&#x20;   if ($Data.Count -gt 0) {

&#x20;       $Data | ConvertTo-Html -Fragment

&#x20;   }

&#x20;   else {

&#x20;       "<p>No matching records found.</p>"

&#x20;   }

}



$sections = @()



$sections += New-ReportSection 'Domain Configuration' @(

&#x20;   Get-ADDomain |

&#x20;       Select-Object DNSRoot, NetBIOSName, DomainMode,

&#x20;           DomainSID, PDCEmulator

)



$sections += New-ReportSection 'Domain Controllers' @(

&#x20;   Get-ADDomainController -Filter \* |

&#x20;       Select-Object Name, IPv4Address, Site, OperatingSystem

)



$sections += New-ReportSection 'Organizational Units' @(

&#x20;   Get-ADOrganizationalUnit -Filter \* -Properties whenCreated, whenChanged |

&#x20;       Sort-Object DistinguishedName |

&#x20;       Select-Object Name, DistinguishedName, whenCreated, whenChanged

)



$sections += New-ReportSection 'User Accounts' @(

&#x20;   Get-ADUser -Filter \* -Properties Department, EmployeeID,

&#x20;       whenCreated, whenChanged, PasswordLastSet |

&#x20;       Sort-Object Name |

&#x20;       Select-Object Name, SamAccountName, Enabled, Department,

&#x20;           EmployeeID, whenCreated, whenChanged, PasswordLastSet

)



$sections += New-ReportSection 'Computer Accounts' @(

&#x20;   Get-ADComputer -Filter \* -Properties OperatingSystem,

&#x20;       whenCreated, whenChanged |

&#x20;       Sort-Object Name |

&#x20;       Select-Object Name, Enabled, OperatingSystem,

&#x20;           whenCreated, whenChanged

)



$sections += New-ReportSection 'Security Groups' @(

&#x20;   Get-ADGroup -Filter 'GroupCategory -eq "Security"' `

&#x20;       -Properties whenCreated, whenChanged |

&#x20;       Sort-Object Name |

&#x20;       Select-Object Name, GroupScope, whenCreated, whenChanged

)



$sections += New-ReportSection 'DC01 Shared Folders' @(

&#x20;   Get-SmbShare |

&#x20;       Where-Object { -not $\_.Special } |

&#x20;       Select-Object Name, Path, Description

)



\# Current GPO inventory; this is not a GPO change history.

try {

&#x20;   Import-Module GroupPolicy -ErrorAction Stop



&#x20;   $sections += New-ReportSection 'Current Group Policy Objects' @(

&#x20;       Get-GPO -All -ErrorAction Stop |

&#x20;           Select-Object DisplayName, GpoStatus,

&#x20;               CreationTime, ModificationTime

&#x20;   )

}

catch {

&#x20;   $sections += "<h2>Group Policy Objects</h2><p>Unable to retrieve GPOs: $(Encode-Html $\_.Exception.Message)</p>"

}



\# Record the earliest event currently retained in the Security log.

try {

&#x20;   $oldest = Get-WinEvent -LogName Security -Oldest -MaxEvents 1 `

&#x20;       -ErrorAction Stop



&#x20;   $sections += "<h2>Security Log Coverage</h2><p>Earliest retained event: $(Encode-Html $oldest.TimeCreated)</p>"

}

catch {

&#x20;   $sections += "<p>Unable to determine Security log coverage: $(Encode-Html $\_.Exception.Message)</p>"

}



\# Relevant Security event IDs.

$eventIDs = @(

&#x20;   1102,                   # Security log cleared

&#x20;   4719,                   # Audit policy changed

&#x20;   4720,4722,4723,4724,     # User created/enabled/password operations

&#x20;   4725,4726,4738,4740,4767,# Disabled/deleted/changed/locked/unlocked

&#x20;   4727,4728,4729,4730,     # Global security group changes

&#x20;   4731,4732,4733,4734,4735,# Domain-local security group changes

&#x20;   4737,4754,4755,4756,4757,4758, # Other security group changes

&#x20;   4741,4742,4743,          # Computer account changes

&#x20;   5136,5137,5139,5141      # Directory object changes

)



try {

&#x20;   # Limit output size; newest matching events are returned first.

&#x20;   $events = @(

&#x20;       Get-WinEvent -FilterHashtable @{

&#x20;           LogName = 'Security'

&#x20;           Id      = $eventIDs

&#x20;       } -MaxEvents 2000 -ErrorAction Stop |

&#x20;           Select-Object TimeCreated, Id, RecordId,

&#x20;               KeywordsDisplayNames, Message

&#x20;   )



&#x20;   $sections += "<p>Audit history contains up to the newest 2,000 matching events. Events describe recorded operations; check success/failure keywords and the message before interpreting them.</p>"



&#x20;   $sections += New-ReportSection 'Available Change Audit Events' $events

}

catch {

&#x20;   $sections += "<h2>Available Change Audit Events</h2><p>No matching events could be retrieved. Auditing may not have been enabled, records may no longer be retained, or access may have failed. Details: $(Encode-Html $\_.Exception.Message)</p>"

}



$style = @'

<style>

body { font-family: Segoe UI, Arial, sans-serif; margin: 32px; color: #243247; }

h1 { color: #153e63; }

h2 { margin-top: 32px; color: #153e63; }

table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }

th, td { border: 1px solid #ccd5df; padding: 8px; text-align: left;

&#x20;        vertical-align: top; overflow-wrap: anywhere; }

th { background: #153e63; color: white; }

tr:nth-child(even) { background: #f0f4f8; }

td { white-space: pre-wrap; }

p { line-height: 1.5; }

</style>

'@



$intro = @"

<h1>AKLAB Server Configuration and Available Change History</h1>

<p>Generated: $(Encode-Html (Get-Date)) | Server: $(Encode-Html $env:COMPUTERNAME)</p>

<p>This report combines current configuration with retained Security audit events.

Creation and modification timestamps do not reveal every historical change.

It is not a complete record of all changes since server creation.</p>

"@



ConvertTo-Html -Title 'AKLAB Server Report' -Head $style `

&#x20;   -Body ($intro + ($sections -join "`n")) |

&#x20;   Out-File -FilePath $reportPath -Encoding utf8



Invoke-Item $reportPath

