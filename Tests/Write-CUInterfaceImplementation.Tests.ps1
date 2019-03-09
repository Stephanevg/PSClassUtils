
Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope -ModuleName PsClassUtils -ScriptBlock {

Describe "Testing Write-CUInterfaceImplementation"{

$Desiredinterface = @'
class plop : System.Collections.IEqualityComparer
{

  [System.Boolean]
  Equals([System.Object]$x, [System.Object]$y)
  {
    throw 'Equals not implemented '
  }

  [System.Int32]
  GetHashCode([System.Object]$obj)
  {
    throw 'GetHashCode not implemented '
  }

}
'@
    
    [type]$Interface = 'System.Collections.IEqualityComparer'
    $GeneratedInterface = Write-CUInterfaceImplementation -Name 'plop' -InterfaceType $Interface
    
    It '[Write-CUInterfaceImplementation] - Should throw if now parameters are passed'{
        
        {Write-CUInterfaceImplementation} | Should throw
    }

    It '[Write-CUInterfaceImplementation] - Should implement Interface correctly'{

        $Desiredinterface | should be $GeneratedInterface.TrimEnd()
    }
}

}