function Select-PermissionLevel {
    Get-PermissionLevels
    $option = Read-Host 'Access Level? Type a number. (Press Enter for Reviewer)'
    if ($option -eq $NULL -or $option -eq "") {
        $option = $CAL_DEFAULT_OPTION
    } else { $option = $option - 1 }
    return $ACCESS_LEVELS[$option]
}