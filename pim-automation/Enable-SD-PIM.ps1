# PIM Automation Project
# Date: 28 May 2025
# Author: Raymond Tamse

cls

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
$Start = (Get-Date).ToUniversalTime()
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