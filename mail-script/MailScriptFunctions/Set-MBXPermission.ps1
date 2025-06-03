. "$PSScriptRoot\..\CONSTANTS.ps1"
function Set-MBXPermission {
    param ( [string]$Type )

    do {
        cls
        Write-Host
        Write-Host "Mailbox - $Type User"
        Write-Host
        Write-Host "Enter 'quit' for Mailbox Name or Username"
        Write-Host "if you've selected this option by mistake."
        Write-Host "------------------------"
        Write-Host

        $OriginalType = $Type
        $AutoMap = $false

        while (($mbxname -eq $null) -or ($mbxname -eq "")) {
            Write-Host "Example: TestMailbox, TestMailbox@cdhb.health.nz"
            Write-Host
            $mbxname = Read-Host "Enter mailbox alias or email address"
        }
        while ((($usrname -eq $null) -or ($usrname -eq "")) -and ($mbxname -ne "quit")) {
            $usrname = Read-Host "Username"
        }

        if (($mbxname -eq "quit") -or ($usrname -eq "quit")) { break }
        
        try {
            $mbx = Get-Mailbox $mbxname -ErrorAction SilentlyContinue
            try {
                $usr = Get-ADUser -Identity $usrname -Properties * -Server $AD_CDHB
            } catch {
                $usr = Get-ADUser -Identity $usrname -Properties * -Server $AD_WCDHB
            }
            if ($Type -eq "Add") {
                if ((Read-Host "Do you want this mailbox to auto-map to their Outlook? (y/n)") -eq "y") {
                        $AutoMap = $true
                }

                Add-MailboxPermission $mbxname -User $usrname -AccessRights fullaccess -InheritanceType All -AutoMapping $AutoMap -ErrorAction Stop | Out-Null
                Set-Mailbox $mbxname -GrantSendOnBehalfTo @{Add="$usrname"}
                Write-Host "Done! Make sure that you advise the user how to add a shared mailbox on Outlook."

                $Type = Open-OWAMailbox -mbxname $mbxname -usrname $usrname
            }
            if ($Type -eq "Remove") {
                Remove-MailboxPermission -Identity $mbxname -User $usrname -AccessRights fullaccess -confirm:$false -ErrorAction Stop

                # Removing possible auto-map
                Add-MailboxPermission $mbxname -User $usrname -AccessRights fullaccess -InheritanceType All -AutoMapping $false -ErrorAction Stop | Out-Null
                Remove-MailboxPermission -Identity $mbxname -User $usrname -AccessRights fullaccess -confirm:$false -ErrorAction Stop

                Set-Mailbox $mbxname -GrantSendOnBehalfTo @{remove="$usrname"}
            }
            if ($Type -eq "Owner") {
                Add-MailboxPermission $mbxname -Owner $usrname | Out-Null
                Add-MailboxPermission $mbxname -User $usrname -AccessRights fullaccess -InheritanceType All -AutoMapping $AutoMap -ErrorAction Stop | Out-Null
                Set-Mailbox $mbxname -GrantSendOnBehalfTo @{Add="$usrname"}
                Write-Host "Owner set! Full Access also granted."
            }

            # Duplicate of Get-Permissions.ps1
            $Owner = (Get-MailboxPermission $mbxname -Owner).Owner
            Write-Host
            Write-Host "Owner: $Owner"
            Get-MailboxPermission $mbxname | Select User,AccessRights | Sort User | Format-Table

        } catch {
        `	Write-Host
            Display-ErrorMessage
            Write-Host
            if ($mbx -eq $null) { Write-Host "Mailbox '$mbxname' not found!" }
            if ($usr -eq $null) { Write-Host "User '$usrname' not found!" }
            Write-Host
        }
        Remove-Variable mbxname, usrname
        $Type = $OriginalType
    } until ((Read-Host "Enter 'q' to quit, hit 'Enter' to repeat") -eq 'q')
}

function Open-OWAMailbox {
    param ( [string]$mbxname, [string]$usrname, [string]$Type )

    $CurrentUser = [Environment]::UserName
    $AdmUser = $CurrentUser.substring(4)
    if (($CurrentUser -eq $usrname) -or ($AdmUser -eq $usrname)) {
        $email = Get-Mailbox  $mbxname | Select-Object -ExpandProperty PrimarySmtpAddress
        start microsoft-edge:http://outlook.office.com/mail/$email

        Write-Host
        Write-Host "Looks like you've granted yourself access!"
        if ((Read-Host "Once you're done, do you want to remove your access? (y/n)") -eq "y") {
            return "Remove"
        }
    }
}