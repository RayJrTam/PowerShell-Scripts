function Set-CLDPermission {
    param ( [string]$Type )

    do {
        cls
        Write-Host
        Write-Host "Calendar - $Type User"
        Write-Host
        Write-Host "------------------------"
        Write-Host
        $mbxname = Read-Host "Calendar alias or email address"

        if ($mbxname -eq "quit") { break }

        $usrname = Read-Host "Username"

        if ($type -ne "Remove") { $PermissionLevel = Select-PermissionLevel }
        
        $cldname = $mbxname + ":\Calendar"

        try {
            switch ($Type) {
                "Add" {
                    Add-MailboxFolderPermission $cldname -User $usrname -AccessRights $PermissionLevel -ErrorAction Stop
                }
                "Edit" {
                    Set-MailboxFolderPermission $cldname -User $usrname -AccessRights $PermissionLevel -ErrorAction Stop
                }
                "Remove" {
                    Write-Host "Please wait..."
                    Remove-MailboxFolderPermission $cldname -User $usrname -confirm:$false -ErrorAction Stop
                }
            }
            Get-MailboxFolderPermission $cldname | Select User,AccessRights | Sort-Object { $_.User.DisplayName } | Format-Table
        } catch { Display-ErrorMessage }
    } until ((Read-Host "Enter 'q' to quit, hit 'Enter' to repeat") -eq 'q')
}