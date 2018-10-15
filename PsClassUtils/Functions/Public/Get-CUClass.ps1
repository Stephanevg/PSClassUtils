function Get-CUClass{
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
        
    .OUTPUTS
        ASTDocument
    .NOTES   
        Author: Tobias Weltner
        Version: ??
        Source --> http://community.idera.com/powershell/powertips/b/tips/posts/finding-powershell-classes

    #>
    [CmdletBinding(DefaultParameterSetName="Normal")]
    Param(
      [Parameter(ParameterSetName="Normal",Mandatory=$False,ValueFromPipeline=$False)]
      $Name = '*',
      [Alias("FullName")]
      [Parameter(ParameterSetName="Path",Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [System.IO.FileInfo[]]$Path
    )
    BEGIN{}

    PROCESS{

        If ($Null -eq $PSBoundParameters['Path']) {

            $LoadedClasses = [AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object { $_.GetCustomAttributes($false) |
            Where-Object { $_ -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute]} } |
            ForEach-Object { $_.GetTypes() |
                Where-Object IsPublic |
                Where-Object { $_.Name -like $Name } |
            Select-Object @{l='Path';e={($_.Module.ScopeName.Replace([char]0x29F9,'\').replace([char]0x589,':')) -replace '^\\',''}}
            }
            
            Foreach ( $Class in $LoadedClasses ) {
                Get-CUAst -Path $Class.Path
            }
            
        } Else {

            Foreach ( $P in $Path ) {

                If ( $MyInvocation.PipelinePosition -eq 1 ) {
                    $P = Get-Item (resolve-path $P).Path
                }

                If ( $P.Extension -in '.ps1','.psm1') {
                    Get-CUAst -Path $P.FullName
                }
            }

        }
    }

    END{}  
  }
  