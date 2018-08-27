Function Get-CUClassConstructor{
    <#
    .SYNOPSIS
        This function returns all existing constructors of a specific powershell class.
    .DESCRIPTION
        The Powershell Class must be loaded in memory for this function to work.
    .EXAMPLE
         Get-CUClassConstructor -ClassName woop

        Name ReturnType Properties
        ---- ---------- ----------
        woop woop
        woop woop       {String, Number}
    .INPUTS
        String
    .OUTPUTS
        ClassConstructor
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

    $Constructors = invoke-expression "[$($ClassName)].GetConstructors()"

    Foreach($Constructor in $Constructors){
        
        $Parameters = $Constructor.GetParameters()
        If($Parameters){
            [ClassProperty[]]$Params = @()
            foreach($Parameter in $Parameters){

                $Params += [ClassProperty]::New($Parameter.Name,$Parameter.ParameterType)

            }
        }
        [ClassConstructor]::New($ClassName,$ClassName,$Params)
         
    }
}