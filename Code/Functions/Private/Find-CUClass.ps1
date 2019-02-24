function Find-CUClass {
    <#
    .SYNOPSIS
        Helper function to find classes, based on a path, Wraps Get-CuClass, return a Microsoft.PowerShell.Commands.GroupInfo object
    .DESCRIPTION
        Helper function to find classes, based on a path, Wraps Get-CuClass, return a Microsoft.PowerShell.Commands.GroupInfo object
    .NOTES
        Private function for PSClassUtils, used in Write-CUClassDiagram
    #>

    Param (
        $Item,
        $Exclude
    )

    If ( $Exclude ) {
        Write-Verbose "Find-CUClass -> Exclude Parameter Specified... $($Exclude.count) items to filter..."

        If ( $Exclude.Count -eq 1 ) {
            Get-ChildItem -path $item -Include '*.ps1', '*.psm1' | Get-CUCLass | Where-Object Name -NotLike $Exclude |  Group-Object -Property Path
        }

        If ( $Exclude.Count -gt 1 ) {
            Get-ChildItem -path $item -Include '*.ps1', '*.psm1' | Get-CUCLass | Where-Object Name -NotIn $Exclude |  Group-Object -Property Path
        }

    } Else {
        Write-Verbose "Find-CUClass -> Exclude Parameter NOT Specified..."
        Get-ChildItem -path $item -Include '*.ps1', '*.psm1' | Get-CUCLass | Group-Object -Property Path
    }
}