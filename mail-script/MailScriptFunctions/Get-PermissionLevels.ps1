function Get-PermissionLevels {
    Write-Host
    Write-Host You will now need to specify an access level.
    Write-Host Enter a number for one of the following access levels:
    
    for ($i = 0; $i -lt $ACCESS_LEVELS.count; $i++) {
        $number = $i+1 
        Write-Host "$number." $ACCESS_LEVELS[$i]
    }
    Write-Host
}