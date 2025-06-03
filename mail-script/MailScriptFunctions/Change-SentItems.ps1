function Change-SentItems {
    do {
        cls
        Write-Host "==============================================="
        Write-Host "= Mailbox - Enable mailbox copy of Sent Items ="
        Write-Host "==============================================="
        Write-Host
        Write-Host
        $mbxname = Read-Host 'Mailbox Name?'
        
        if ($mbxname -eq "quit") {break}

        Write-Host
        Write-Host "Before"
        Write-Host
        (Get-Mailbox $mbxname | Select MessageCopyForSendOnBehalfEnabled, MessageCopyForSentAsEnabled | Format-List | Out-String).trim()
        Write-Host

        # Sent Items in shared mailbox AND personal mailbox
        Set-Mailbox $mbxname -MessageCopyForSendOnBehalfEnabled $True -MessageCopyForSentAsEnabled $True

        Write-Host "After"
        Write-Host
        (Get-Mailbox $mbxname | Select MessageCopyForSendOnBehalfEnabled, MessageCopyForSentAsEnabled | Format-List | Out-String).trim()
        Write-Host
    }
    until ((Read-Host "Enter 'q' to quit, hit 'Enter' to repeat") -eq 'q')
}