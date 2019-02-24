function New-CUGraphParameters {
    <#
    .SYNOPSIS
        Helper function to generate a Graph, wrap Out-CUPSGraph.
    .DESCRIPTION
        Helper function to generate a Graph, wrap Out-CUPSGraph.
    .NOTES
        Private function for PSClassUtils, used in Write-CUClassDiagram
    #>

    Param (
        $inputobject,
        $ignorecase,
        $showcomposition
    )

    $GraphParams = @{
        InputObject = $inputobject
    }

    If ( $ignorecase ) { $GraphParams.Add('IgnoreCase',$ignorecase) }
    If ( $showcomposition ) { $GraphParams.Add('ShowComposition',$showcomposition) }

    Out-CUPSGraph @GraphParams
    
}
