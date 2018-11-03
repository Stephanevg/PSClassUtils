Function Get-CUClassConstructor {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [cmdletBinding()]
    [OutputType('AsCUClassConstructor','CUClassConstructor')]
    Param(
        [Alias("FullName")]
        [Parameter(ParameterSetName = "Path", Position=1, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Mandatory=$true, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(ValueFromPipeline=$True)]
        [Object[]]$InputObject
    )

    BEGIN {}

    PROCESS {



        $ClassParams = @{}

        If($ClassName -or $PSBoundParameters['ClassName'] ){
            $ClassParams.ClassName = $ClassName
        }

        If($Path -or $PSBoundParameters['Path'] ){
            $ClassParams.Path = $Path.FullName
        }

        If($InputObject){
            $ClassParams.ClassName = $ClassName
        }

       
            $Class = Get-CuClass @ClassParams
            If($Class){

                $Class.GetCuClassConstructor()
            }
        }


    END {}

}
