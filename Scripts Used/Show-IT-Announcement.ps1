
# AKLAB IT - Announcement Notification
# Runs in the signed-in user's session

$AnnouncementPath = "\\DC01\CompanyShare\IT-Announcements\CurrentAnnouncement.json"

# Store seen announcement IDs separately for each user
$StateFolder = Join-Path $env:LOCALAPPDATA "AKLabIT"
$StateFile = Join-Path $StateFolder "SeenAnnouncements.txt"

try {
    # Reads the latest announcement
    $Announcement = Get-Content -LiteralPath $AnnouncementPath -Raw -ErrorAction Stop |
        ConvertFrom-Json -ErrorAction Stop

    $ID = [string]$Announcement.AnnouncementID

    if ([string]::IsNullOrWhiteSpace($ID)) {
        throw "AnnouncementID is missing."
    }

    # Create the local state folder if needed
    New-Item -Path $StateFolder -ItemType Directory -Force -ErrorAction Stop |
        Out-Null

    # Read IDs of announcements already displayed
    $SeenIDs = @()

    if (Test-Path -LiteralPath $StateFile) {
        $SeenIDs = @(Get-Content -LiteralPath $StateFile -ErrorAction Stop)
    }

    # Display only if this user has not seen this ID
    if ($ID -notin $SeenIDs) {

        Add-Type -AssemblyName System.Windows.Forms

        $Title = [string]$Announcement.Title
        $Message = [string]$Announcement.Message

        [System.Windows.Forms.MessageBox]::Show(
            $Message,
            $Title,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null

        # Record the ID after the user dismisses the message
        Add-Content -LiteralPath $StateFile -Value $ID -ErrorAction Stop
    }
}
catch {
    # Record errors for troubleshooting without
    # interrupting the user's Windows sign-in
    try {
        New-Item -Path $StateFolder -ItemType Directory -Force |
            Out-Null

        $LogPath = Join-Path $StateFolder "AnnouncementErrors.log"

        "$(Get-Date -Format s) - $($_.Exception.Message)" |
            Add-Content -LiteralPath $LogPath
    }
    catch {}
}
