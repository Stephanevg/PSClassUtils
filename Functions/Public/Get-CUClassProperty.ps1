Function Get-CUClassProperty{
    <#
    .SYNOPSIS
        This function returns all existing properties of a specific powershell class.
    .DESCRIPTION
        The Powershell Class must be loaded in memory for this function to work.
    .EXAMPLE
        Get-CUClassProperty -ClassName wap

        Name   Type
        ----   ----
        prop3  String
        String String
        number Int32

    .INPUTS
        String
    .OUTPUTS
        ClassMethod
    .NOTES   
        Author: Stéphane van Gulick
        Version: 0.7.1
        www.powershellDistrict.com
        Report bugs or submit feature requests here:
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$ClassName
    )

    $Properties = invoke-expression "[$($ClassName)].GetProperties()"
    if($Properties){

        Foreach($Property in $Properties){
    
            [ClassProperty]::New($Property.Name,$Property.PropertyType.Name)
    
        }
    }
}



