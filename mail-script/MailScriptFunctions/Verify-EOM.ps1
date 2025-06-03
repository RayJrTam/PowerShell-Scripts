# This script is called by Mail Script.ps1, please do not move or edit.

# Allow running random PowerShell scripts for current user only
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass

# Check if EOM is installed, no user input required
if (Get-Module -ListAvailable -Name ExchangeOnlineManagement) {
    cls
    Write-Host "EO module already installed."
} else {
    cls
    Write-Host "Installing the ExchangeOnlineManagement module (wait ~1 minute)..."

    # Trust the installation source (Microsoft advises to use this module, no worries!)
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

    $global:progresspreference = "SilentlyContinue"
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
    $global:progresspreference = "Continue"
}