Function Get-ClassMethods{
    <#
    .SYNOPSIS
        This function returns all existing methods of a specific powershell class.
    .DESCRIPTION
        The Powershell Class must be loaded in memory for this function to work.
    .EXAMPLE

         Get-ClassMethods -ClassName wap

        Name          ReturnType Properties
        ----          ---------- ----------
        DoChildthing  void
        DoChildthing2 void       {Prop1, Prop2}
        DoChildthing3 string     {Prop1, Prop2, Prop3}
        DoChildthing4 bool       {Prop1, Prop2, Prop3}
        DoSomething   string     {Prop1, Prop2, Prop3}

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
    
     $Methods = invoke-expression "[$($ClassName)].GetMethods()" | where-object {($_.IsHideBySig) -eq $false}

     Foreach($Method in $Methods){
         $Parameters = $Method.GetParameters()
         If($Parameters){
             [ClassProperty[]]$Params = @()
             foreach($Parameter in $Parameters){

                $Params += [ClassProperty]::New($Parameter.Name,$Parameter.ParameterType)

             }
         }
         [ClassMethod]::New($Method.Name,$Method.ReturnType,$Params)
     }
}
