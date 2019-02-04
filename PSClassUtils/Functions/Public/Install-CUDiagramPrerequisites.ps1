function Install-CUDiagramPrerequisites {
    <#
    .SYNOPSIS
        This function installs the prerequisites for PSClassUtils.
    .DESCRIPTION   
        Installation of PSGraph
    .EXAMPLE
        Istall-CUDiagramPrerequisites
    .EXAMPLE
        Istall-CUDiagramPrerequisites -proxy "10.10.10.10" -Scope CurrentUser
    .NOTES   
        Author: Stephanevg
        Version: 2.0
    #>

    [CmdletBinding()]
    param (
        [String]$Proxy,
        [ValidateSet("AllUsers","CurrentUser")][String]$Scope = "AllUsers"        
    )
    
    if(!(Get-Module -Name PSGraph)){
        #Module is not loaded
        if(!(get-module -listavailable -name psgraph )){
            if($proxy){
                write-verbose "Install PSGraph"
                Install-Module psgraph -Verbose -proxy $proxy -Scope $Scope
                Import-Module psgraph -Force
            }else{
                write-verbose "Install PSGraph"
                Install-Module psgraph -Verbose -Scope $Scope
                Import-Module psgraph -Force
            }
        }else{
            Import-Module psgraph -Force
        }

        Install-GraphViz
    }
}