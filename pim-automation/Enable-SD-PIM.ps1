# PIM Automation Project
# Date: 28 May 2025
# Author: Raymond Tamse

cls

# TO-DO: Create time schedule constants rather than asking for user input for specific times
$option = Read-Host @"
Select option:
1. Enable PIM for today
2. Enable PIM for custom date
Input
"@


try { Import-Module AzureADPreview -ErrorAction Stop } catch { Install-Module -Name AzureADPreview -Scope CurrentUser }
$User = Connect-AzureAD

#Resource ID from CONSTANTS
. "$PSScriptRoot\CONSTANTS.ps1"

$RoleCollection = Get-AzureADMSPrivilegedRoleDefinition -ProviderId "aadGroups" -ResourceId $ResourceID | Where-Object {$_.DisplayName -eq 'Member'}
$RoleID = $RoleCollection.Id

$UPN = $User.Account.Id
$CurrentUser = Get-AzureADUser -Filter "UserPrincipalName eq '$UPN'"

# Schedule
$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = 'Once'

if ($option -eq "1") {
    $Start = (Get-Date).ToUniversalTime()
} else {
    $Start = Read-Host "Enter start date and time (e.g. 09/06/2025 08:00)"
    $Start = $Start.ToUniversalTime()
}

$End = (Get-Date).AddHours(9).ToUniversalTime()
$schedule.StartDateTime = $Start.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
$schedule.endDateTime = $End.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')

Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadGroups `
    -Schedule $schedule `
    -ResourceId $ResourceId `
    -RoleDefinitionId $RoleID `
    -SubjectId $CurrentUser.ObjectId `
    -AssignmentState "Active" `
    -Type "UserAdd" `
    -Reason "Work"