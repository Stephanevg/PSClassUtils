Function Get-ClassMethods{
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
