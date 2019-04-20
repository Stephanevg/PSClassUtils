Function Get-CUEnum{
    <#
    .SYNOPSIS
        This function returns enums existing in a document.
    .DESCRIPTION
        Returns a custom type [ClassEnum]
    .EXAMPLE
        Get-CuEnum -Path C:\plop\enum.ps1

        Returns:

        Name Member
        ---- ------
        woop {Absent, Present}

    .INPUTS
        String
    .OUTPUTS
        Classenum
    .NOTES   
        Author: Stéphane van Gulick
        Version: 0.2.0
        
    .LINK
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding()]
    Param(
        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Path
    )

   begin{

   }

   Process{
        ForEach( $p in $Path) {
            Write-Verbose "ICI"
            $item = get-item (resolve-path -path $p).path
                If ( $item -is [system.io.FileInfo] -and $item.Extension -in @('.ps1','.psm1') ) {
                Write-Verbose "[Get-CUEnum][Path] $($item.FullName)"
                $AST = Get-cuast -Path $item.FullName | Where-Object IsEnum
        
                foreach($enum in $AST){
                    [ClassEnum]::New($enum.Name,$enum.members.Name)
                }
            }
        }

        If ( $null -eq $PSBoundParameters['Path']) {
            Foreach ( $Enum in (Get-CULoadedClass ) ) {
                If($Enum.IsEnum){
                    [ClassEnum]::New($Enum.Name,$Enum.members.Name)
                }
            }
        }
   }
   End{

   }
}