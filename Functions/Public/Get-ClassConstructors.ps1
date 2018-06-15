Function Get-ClassConstructors{
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