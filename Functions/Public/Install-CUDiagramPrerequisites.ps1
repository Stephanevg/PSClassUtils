function Install-CUDiagramPrerequisites {
    [CmdletBinding()]
    param (
        
    )
    
    if(!(Get-Module -Name PSGraph)){
        #Module is not loaded
        if(!(get-module -listavailable -name psgraph )){
            write-verbose "Install PSGraph"
            Install-Module psgraph -Verbose
            Import-Module psgraph -Force
            
        }else{
            Import-Module psgraph -Force
        }

        Install-GraphViz
    }
}