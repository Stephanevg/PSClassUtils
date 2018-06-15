Function Get-ClassProperties{
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



