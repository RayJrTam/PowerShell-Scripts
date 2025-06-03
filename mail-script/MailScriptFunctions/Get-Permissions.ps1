function Get-Permissions {
    param ( [string]$Type )

    do {
        cls
        Write-Host "===================================="
        Write-Host "===================================="
        Write-Host "==                                =="
        Write-Host "==  QUERY USER ACCESS - $Type  =="
        Write-Host "==                                =="
        Write-Host "===================================="
        Write-Host "===================================="
        Write-Host

        $Alias = Read-Host "Alias"

        switch ($Type) {
            "Mailbox " {
                $Owner = (Get-MailboxPermission $alias -Owner).Owner
                Write-Host
                Write-Host "Owner: $Owner"
                Get-MailboxPermission $alias | Select User,AccessRights | Sort User | Format-Table
            }

            "Calendar" {
                $Alias = $alias + ":\Calendar"
                Get-MailboxFolderPermission $Alias | Select User,AccessRights | Sort-Object { $_.User.DisplayName } | Format-Table
            }
        }
    } until ((Read-Host "Enter 'q' to quit, hit 'Enter' to repeat") -eq 'q')
}