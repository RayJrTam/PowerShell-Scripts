function Change-MailboxType {
    do {
        cls
        Write-Host "========================="
        Write-Host "= Mailbox - Change Type ="
        Write-Host "========================="
        Write-Host
        $mbxname = Read-Host 'Mailbox Name?'
        if ($mbxname -eq "quit") {break}
            
        try {
            $MbxTypes = @("Regular", "Shared", "Room")
            $CurrentType = Get-Mailbox -Identity $mbxname -ErrorAction Stop | Select-Object -ExpandProperty RecipientTypeDetails
            
            Write-Host
            Write-Host "Current type: $CurrentType"
            Write-Host
            Write-Host "1. Regular"
            Write-Host "2. Shared"
            Write-Host "3. Room"
            Write-Host

            # prone to error, will need to limit input?
            $mbxtype = Read-Host 'Type a number, then hit Enter'

            switch ($mbxtype) {
                { @(1, 2, 3) -contains $_ } {
                    Set-Mailbox -Identity $mbxname -Type $MbxTypes[$mbxtype-1]
                    Start-Sleep 1
                    Write-Host
                    $CurrentType = Get-Mailbox -Identity $mbxname -ErrorAction Stop | Select-Object -ExpandProperty RecipientTypeDetails
                    Write-Host "New type: $CurrentType"
                    Write-Host
                }
                default {
                    Write-Host
                    Write-Host "Please enter a valid number."
                    Write-Host
                }
            }

        } catch { Display-ErrorMessage }
    }
    until ((Read-Host "Enter 'q' to quit, hit 'Enter' to repeat") -eq 'q')
}