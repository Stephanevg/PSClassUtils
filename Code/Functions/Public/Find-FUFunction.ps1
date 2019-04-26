Function Find-FUFunction {
    <#
    .SYNOPSIS
        Find All Functions declaration inside a ps1/psm1 file and their inner commands.
    .DESCRIPTION
        Find All Functions declaration inside a ps1/psm1 file.
        Return an object describing a powershell function. Output a custom type: FUFunction.
    .EXAMPLE
        PS C:\> Find-FUFunction .\PSFunctionExplorer.psm1

        Name                  Commands                                             Path
        ----                  --------                                             ----
        Find-Fufunction       {Get-Command, Get-Alias, Select-Object, Get-Item...} C:\PSFunctionExplorer.psm1
        Write-Fufunctiongraph {Get-Item, Resolve-Path, Find-Fufunction, Graph...}  C:\PSFunctionExplorer.psm1

        return all function present in the PSFunctionExplorer.psm1 and every commands present in it.
    .EXAMPLE
        PS C:\> Find-FUFunction .\PSFunctionExplorer.psm1 -ExcludePSCmdlets
        Name                  Commands                                Path
        ----                  --------                                ----
        Find-Fufunction       {}                                      C:\Users\Lx\GitPerso\PSFunctionUtils\PSFunctionExplorer\PSFunctionExplorer.psm1
        Write-Fufunctiongraph {Find-Fufunction, Graph, Node, Edge...} C:\Users\Lx\GitPerso\PSFunctionUtils\PSFunctionExplorer\PSFunctionExplorer.psm1

        Return all function present in the PSFunctionExplorer.psm1 and every commands present in it, but exclude default ps cmdlets.
    .INPUTS
        Path. Accepts pipeline inputs
    .OUTPUTS
        A FUFunction custom object
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Path,
        [Switch]$ExcludePSCmdlets
    )
    
    begin {
        If ( $PSBoundParameters['ExcludePSCmdlets'] ) {
            $ToExclude = (Get-Command -Module "Microsoft.PowerShell.Archive","Microsoft.PowerShell.Utility","Microsoft.PowerShell.ODataUtils","Microsoft.PowerShell.Operation.Validation","Microsoft.PowerShell.Management","Microsoft.PowerShell.Core","Microsoft.PowerShell.LocalAccounts","Microsoft.WSMan.Management","Microsoft.PowerShell.Security","Microsoft.PowerShell.Diagnostics","Microsoft.PowerShell.Host").Name
            $ToExclude += (Get-Alias | Select-Object -Property Name).name
        }
    }
    
    process {
        ForEach( $p in $Path) {
            $item = get-item (resolve-path -path $p).path
            If ( $item -is [system.io.FileInfo] -and $item.Extension -in @('.ps1','.psm1') ) {
                Write-Verbose ("[FUFunction]Analyzing {0} ..." -f $item.FullName)
                $t = [FUUtility]::GetRawASTFunction($item.FullName)
                Foreach ( $RawASTFunction in $t ) {
                    If ( $PSBoundParameters['ExcludePSCmdlets'] ) {
                        [FUUtility]::GetFunction($RawASTFunction,$ToExclude,$Path)
                    } Else {
                        [FUUtility]::GetFunction($RawASTFunction,$Path)
                    }
                }
            }
        }
    }
    
    end {
    }
}