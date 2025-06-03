. "$PSScriptRoot\..\CONSTANTS.ps1"
function Set-AccountHideStatus {
    do {
        cls
        Write-Host "=================="
        Write-Host "= Show/Hide User ="
        Write-Host "=================="
        Write-Host "NOTE: Opening ISE and running this script as your ADM account"
        Write-Host "makes this script easier to use!"
        Write-Host

        $username = Read-Host "Username"

        Get-AccountHideStatus -Username $username

        Write-Host "1. Show"
        Write-Host "2. Hide"
        Write-Host "Enter any other key to cancel."
        Write-Host
        $option = Read-Host "Enter a number"

        switch ($option) {
            "1" { $decision = $false }
            "2" { $decision = $true }
            default { return }
        }

        if ((whoami) -like "cdhb\adm-*") {
            Set-ADUser $username -Replace @{msExchHideFromAddressLists=$decision}
        } else {
            $Credential = Get-ADMCredential
            Start-Process Powershell -NoNewWindow -WorkingDirectory $FILE_PATH -Credential $Credential -ArgumentList "-Command", "Set-ADUser $username -Replace @{msExchHideFromAddressLists=[bool]::Parse('$decision')}"
        }
        Start-Sleep -Seconds 3

        Get-AccountHideStatus -Username $username

    } until ((Read-Host "Enter 'q' to quit, hit 'Enter' to repeat") -eq 'q')
}

function Get-AccountHideStatus {
    param ( [string]$Username )
    $user = try {
                Get-ADUser $Username -Properties msExchHideFromAddressLists -Server $AD_CDHB
            } catch {
                Get-ADUser $Username -Properties msExchHideFromAddressLists -Server $AD_WCDHB
            }
    $isHidden = $user | Select-Object -ExpandProperty msExchHideFromAddressLists
    if ($isHidden -eq $null) { $isHidden = "Not set" }

    Write-Host
    Write-Host "Is hidden: $isHidden"
    Write-Host
}