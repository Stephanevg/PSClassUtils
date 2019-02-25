function Test-IsCustomType {

# Test-PowershellDynamicClass Psobject

# Test-PowershellDynamicClass MyClass

# extrait et adapté de  https://github.com/PowerShell/PowerShell-Tests

 

 

Param (

   [ValidateNotNullOrEmpty()]

   [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]

  [type] $Type

)

 

Process {

   $attrs = @($Type.Assembly.GetCustomAttributes($true))

     $result = @($attrs | Where { $_  -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute] })

     return ($result.Count -eq 1)

}

}

