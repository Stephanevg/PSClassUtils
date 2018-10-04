$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

write-verbose "Loading Private Functions"
$PrivateFunctions = gci "$ScriptPath\Functions\Private" -Filter *.ps1 | Select -Expand FullName



foreach ($Private in $PrivateFunctions){
    write-verbose "importing function $($function)"
    try{
        . $Private
    }catch{
        write-warning $_
    }
}

write-verbose "Loading Public Functions"
$PublicFunctions = gci "$ScriptPath\Functions\public" -Filter *.ps1 | Select -Expand FullName


foreach ($public in $PublicFunctions){
    write-verbose "importing function $($function)"
    try{
        . $public
    }catch{
        write-warning $_
    }
}

$PrivateClasses = gci "$ScriptPath\Classes\Private" -Filter *.ps1 | sort Name | Select -Expand FullName


foreach ($Private in $PrivateClasses){
    write-verbose "importing Class $($function)"
    try{
        . $Private
    }catch{
        write-warning $_
    }
}