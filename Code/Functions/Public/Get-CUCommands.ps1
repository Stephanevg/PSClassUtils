function Get-CUCommands {
    <#
    .SYNOPSIS
        Returns the list of commands available in the PSclassUtils module
    .DESCRIPTION
        All public commands will be returned.
    .EXAMPLE
        Get-CUCommands

    .NOTES
        Author: Stéphane van Gulick
        
    #>
    [CmdletBinding()]
    param (
        
    )
    
    return Get-Command -Module PSClassUtils
}