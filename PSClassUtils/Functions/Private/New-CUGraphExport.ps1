function New-CUGraphExport {
    <#
    .SYNOPSIS
        Helper function to generate a Graph export file, wraps Export-PSGraph.
    .DESCRIPTION
        Helper function to generate a Graph export file , wraps Export-PSGraph.
    .NOTES
        Private function for PSClassUtils, used in Write-CUClassDiagram
    #>

    param (
        $Graph,
        $PassThru,
        $Path,
        $ChildPath,
        $OutPutFormat
    )
    
    $ExportParams = @{
        OutPutFormat = $OutPutFormat
        DestinationPath = Join-Path -Path $Path -ChildPath ($ChildPath+'.'+$OutPutFormat)
    }
    
    If ( $PassThru ) {
        $Graph
        $null = $Graph | Export-PSGraph @ExportParams
    } Else {
        $Graph | Export-PSGraph @ExportParams
    }

}
