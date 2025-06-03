<#
This script is intended to compile all common mail scripts into one:
- Mailbox  (Add/Remove Full Access)
- Calendar (Add/Edit/Remove Folder Access)
- Mailbox & Calendar - Get permission list
- Change Sent Items behaviour

This is to avoid having to open multiple different scripts.

This script was also designed to:
- Install the ExchangeOnlineManagement module if required, no user input needed.
- Check if the user is already logged in with CADO.
If not, user is prompted to login, otherwise it just proceeds.

Authors: Raymond Tamse Jr
#>

# Global constants
#
."$PSScriptRoot\CONSTANTS.ps1"
$ACCESS_LEVELS = @("Owner", "PublishingEditor", "Editor", "PublishingAuthor", "Author", "Contributor", "Reviewer")
$CAL_DEFAULT_OPTION = 6 # Reviewer
$FILE_PATH = "$PSScriptRoot"

# Checks if the EO module is installed, installs the module otherwise
# Only works if both Mail Script.ps1 and Verify-EOM.ps1 are in the same folder!
&"$FILE_PATH\MailScriptFunctions\Verify-EOM.ps1"

# Importing helper functions
$HELPER_FILE_PATH = $FILE_PATH + "\MailScriptFunctions"
. $HELPER_FILE_PATH\Set-MBXPermission.ps1
. $HELPER_FILE_PATH\Get-Permissions.ps1
. $HELPER_FILE_PATH\Set-CLDPermission.ps1
. $HELPER_FILE_PATH\Change-SentItems.ps1
. $HELPER_FILE_PATH\Create-NewMailbox.ps1

. $HELPER_FILE_PATH\Get-PermissionLevels.ps1
. $HELPER_FILE_PATH\Select-PermissionLevel.ps1
. $HELPER_FILE_PATH\Change-MailboxType.ps1

. $HELPER_FILE_PATH\Set-AccountHideStatus.ps1

while (1) {
    Write-Host "Please login with your CADO account."
    try {Get-Mailbox TestMailbox -ErrorAction Stop} catch { Connect-ExchangeOnline }
    cls
    Write-Host "========================================"
    Write-Host "= EO Mail Script - Full Access Version ="
    Write-Host "========================================"
    Write-Host
    Write-Host "1.  Mailbox - Add User"
    Write-Host "2.  Mailbox - Remove User"
    Write-Host "3.  Mailbox - Check Permissions"
    Write-Host "4.  Mailbox - Change Sent Items behavior"
    Write-Host "5.  Mailbox - Create Shared Mailbox"
    Write-Host
    Write-Host "6.  Calendar - Add User"
    Write-Host "7.  Calendar - Edit User"
    Write-Host "8.  Calendar - Remove User"
    Write-Host "9.  Calendar - Check Permissions"
    Write-Host "10. ---"
    Write-Host
    Write-Host "11. User/Mailbox - Show/Hide from Address Book"
    Write-Host "12. Mailbox - Change Type"
    Write-Host "13. Mailbox - Set Owner"
    Write-Host

    $option = Read-Host "Enter a number"

    switch ($option) {
        1 {Set-MBXPermission -Type "Add"}
        2 {Set-MBXPermission -Type "Remove"}
        3 {Get-Permissions -Type "Mailbox "}
        4 {Change-SentItems}
        5 {Create-NewMailbox}
        6 {Set-CLDPermission -Type "Add"}
        7 {Set-CLDPermission -Type "Edit"}
        8 {Set-CLDPermission -Type "Remove"}
        9 {Get-Permissions -Type "Calendar"}
        11 {Set-AccountHideStatus}
        12 {Change-MailboxType}
        13 {Set-MBXPermission -Type "Owner"}
    }  
}