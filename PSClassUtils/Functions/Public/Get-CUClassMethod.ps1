Function Get-CuClassMethod {
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
    Param(

        [Alias("FullName")]
        [Parameter(ParameterSetName = "Path", Position = 1, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Mandatory = $True, ValueFromPipeline = $False)]
        [String[]]$ClassName,

        [Parameter(Mandatory = $false, ValueFromPipeline = $False)]
        [String]$MethodName,

        [Parameter(ValueFromPipeline = $True)]
        [ValidateScript( {
                If ( !($_.GetType().Name -eq "CUClass" ) ) { Throw "InputObect Must be of type CUClass.."} Else { $True }
            })]
        [Object[]]$InputObject,

        [Switch]$Raw
    )

    BEGIN {}

    PROCESS {

        $ClassParams = @{}

        If ($ClassName -or $PSBoundParameters['ClassName'] ) {
            $ClassParams.ClassName = $ClassName
        }

        If ($Path -or $PSBoundParameters['Path'] ) {
            $ClassParams.Path = $Path.FullName
        }

        If ($InputObject) {
            $ClassParams.ClassName = $ClassName
        }

       
        $Class = Get-CuClass @ClassParams
        If ($Class) {

            $Method = $Class.GetCuClassMethod()

            if($MethodName){
                $Method = $MethodName | ? {$_.Name -eq $MethodName}
            }

            if($Raw){
                $Method.raw
            }Else{
                $Method
            }
        }
    }




    END {}

}