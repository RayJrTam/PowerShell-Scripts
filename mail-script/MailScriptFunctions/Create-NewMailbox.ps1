. "$PSScriptRoot\..\CONSTANTS.ps1"
function Create-NewMailbox {
    # EAC website is a better and easier alternative
    cls
    Write-Host "NOTE: The Exchange Admin Center now allows making shared mailboxes on-prem that syncs to the cloud."
    Write-Host "Please log into EAC, then login with your ADM account."
    Write-Host "To make the shared mailbox, click the + icon and select 'Office 365 mailbox'."
    Write-Host
    Write-Host "If in the event that you still want to use the script, enter 'continue'."
    Write-Host "Enter anything else to return to the Main Menu."
    if ((Read-Host "Continue?") -eq "continue") { cls } else {break}

    cls
    Write-Host "========================="
    Write-Host "= Create Shared Mailbox ="
    Write-Host "========================="
    Write-Host

    # Initialize variables
    $DisplayName = $null
    $UPN = $null
    $JobNumber = $null
    $OU = "cdhb.local/Resource MBX"
    $WhoAmI = (whoami).split("\")[1]
    $Date = Get-Date -Format "dd/MM/yyyy"
    $PasswordToSave = $null
    $IsRoom = $false

    # Ask and confirm mailbox details
    while ($DisplayName -eq $null) {$DisplayName = Read-Host "Display name (not email address!)"}
    $MaxLength = [System.Math]::Min($DisplayName.Length, 20) # max 20 characters allowed for aliases
    $UPN = $DisplayName.replace(" ", "").Substring(0, $MaxLength)
    while ($JobNumber -eq $null) { $JobNumber = Read-Host "Job number" }
    if ((Read-Host "Is this a Room mailbox? (y/n)") -eq "y") {
        $IsRoom = $True
    }
    Write-Host
    Write-Host "Summary:"
    Write-Host "Display name: $DisplayName"
    Write-Host "Username: $UPN"
    Write-Host "Job number: $JobNumber"
    Write-Host "Mailbox is a Room: $IsRoom"
    if ((Read-Host "Proceed? (y/n)") -eq "n") { return }

    
    # Generate password
    Write-Host
    Write-Host "A password will be randomly generated."
    Write-Host
    $GeneratePassword = -join ((65..90) + (97..122) | Get-Random -Count 16 | %{[char]$_})
    $GeneratePassword = $GeneratePassword + (Get-Random -InputObject 1,2,3,4,5,6,7,8,9)
    Write-Host "The password is $GeneratePassword"
    Write-Host "Please copy this into the ticket as an internal comment before proceeding."
    pause
    $Password = ConvertTo-SecureString -AsPlainText $GeneratePassword -Force

    # Login as ADM
    if (!$UserCredential) { $UserCredential = Get-ADMCredential }
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Authentication Kerberos -Credential $UserCredential
    Import-PSSession $Session -DisableNameChecking -AllowClobber

    # Create the mailbox
    try {
        # For some reason, -Room and -Shared can't be used at the same time...
        # Was hoping to give either one a True or False depending on user input
        if ($IsRoom) {
            New-RemoteMailbox -Room -Name $DisplayName -Password $Password -UserPrincipalName "$UPN@cdhb.health.nz" -PrimarySmtpAddress "$UPN@cdhb.health.nz" -OnPremisesOrganizationalUnit $OU -ErrorAction Stop
        } else {
            New-RemoteMailbox -Shared -Name $DisplayName -Password $Password -UserPrincipalName "$UPN@cdhb.health.nz" -PrimarySmtpAddress "$UPN@cdhb.health.nz" -OnPremisesOrganizationalUnit $OU -ErrorAction Stop
        }
    } catch {
        cls
        Write-Host
        Write-Host "Error! See message below."
        Write-Host $Error[0].Exception
        Write-Host
        Write-Host "If the mailbox already exists, here's what you've typed for convenience:"
        Write-Host "$DisplayName | $UPN"
        Write-Host "Returning back to Main Menu..."
        Write-Host
        pause
        break
    }
    Write-Host "Waiting 10 seconds for the mailbox to appear in AD..."
    Start-Sleep -Seconds 10
    Write-Host "Setting password to never expire"
    Write-Host "Setting password to never change"
    Write-Host "Setting description: Created by $WhoAmI on $Date ref $JobNumber"
    Write-Host "Setting proxy addresses"
    Write-Host "Setting mailbox to copy sent items in both sender and mailbox"
    if ((whoami) -like "cdhb\adm-*") {
        Set-ADUser $UPN -CannotChangePassword $true -PasswordNeverExpires $true -Title $DisplayName -Description "Created by $WhoAmI on $Date ref $JobNumber"
    } else {
        Write-Host
        Write-Host "You're not running ISE as your ADM account!"
        Write-Host "Please re-open your PowerShell editor as your ADM account!"
    }

    if ($IsRoom -eq "y") {
        Set-CalendarProcessing $UPN -AutomateProcessing AutoAccept -BookingWindowInDays 365
    }

    Write-Host
    Write-Host "Mailbox created!"
    Write-Host "Please wait for 30-40 minutes before granting access to users."
    Write-Host "Note: Please refresh AD, freshly created accounts won't immediately show the custom description and other stuff..."
    Write-Host "Note: You will be asked to log into CADO again because you've recently logged in as ADM."
    Write-Host "Don't worry, just click into your account again."
    Write-Host
    pause
    Remove-Variable DisplayName, UPN, JobNumber
    Remove-PSSession $Session
}

function Get-ADMCredential {
    return $Credential = $host.ui.PromptForCredential("Need ADM credentials", "Please include the domain!", "", "")
}