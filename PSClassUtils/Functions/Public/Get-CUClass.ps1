function Get-CUClass{
  [CmdletBinding()]
  Param(
    $Name = '*'
  )
  <#
    .SYNOPSIS
        This function returns all currently loaded powershell classes.
    .DESCRIPTION
        
    .EXAMPLE
        Get-CUClass

        Employee
        ExternalEmployee
        InternalEmployee

    .INPUTS
        String
    .OUTPUTS
        String
    .NOTES   
        Author: Tobias Weltner
        Version: ??
        Source --> http://community.idera.com/powershell/powertips/b/tips/posts/finding-powershell-classes

    #>

  [AppDomain]::CurrentDomain.GetAssemblies() |
  Where-Object { $_.GetCustomAttributes($false) |
      Where-Object { $_ -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute]} } |
      ForEach-Object { $_.GetTypes() |
      Where-Object IsPublic |
      Where-Object { $_.Name -like $Name } |
      Select-Object -ExpandProperty Name
  }
  
}