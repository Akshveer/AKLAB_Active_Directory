**AKLAB Active Directory Help Desk Lab**

**Project Overview**
I built AKLAB to practice how an IT help desk supports users in a Windows domain. I set up the lab in VirtualBox, worked through 24 simulated support tickets, and documented the troubleshooting steps, resolutions, and verification results.

**To view the project**


**Lab Environment**
The lab runs on the aklab.local domain. DC01 is the Windows Server domain controller and DNS server. CLIENT01 is a Windows 11 Pro workstation joined to the domain. I used CLIENT01 to test domain sign-ins, shared folder access, and applied Group Policy settings. The [architecture diagram](Lab%20Architecture%20Diagram.png) shows how the two machines fit together.

**Help Desk Scenarios**
The tickets cover password resets, account lockouts, employee onboarding and offboarding, shared folder permissions, and backup issues. For the Employees shared folder ticket, I verified access from CLIENT01 while signed in as the affected domain user. I also used Group Policy results to confirm which policies applied to the workstation.

The [resolved tickets](Tickets/Resolved%20Tickets/) contain the individual cases. The [ticket register](Tickets/TicketRegister.xlsx) tracks them, and the [knowledge base PDF](Tickets/AKLabResolvedTicketsKnowledgeBase.pdf) brings the support guidance together in one place.

**PowerShell and Reporting**
I used [PowerShell scripts](Scripts%20Used/Powershell%20IT%20Administration/) to report on directory users and group membership, find disabled accounts, export an organizational unit inventory, and create employee accounts. The [detailed project report](Reports/AKLABDetailedReport.pdf) explains the setup and implementation. The [Reports folder](Reports/) includes the server configuration, directory user inventory, and Group Policy results.

**Project Showcase**
The [project landing page source](index.html) brings the architecture, reports, scripts, and searchable ticket list together. The [knowledge base portal source](AKLABTicketKnowledgeBasePortal.html) is also available in the repository. Both pages are designed to open as websites when the repository is published through GitHub Pages.

**Author**
Akshveer Kaur
