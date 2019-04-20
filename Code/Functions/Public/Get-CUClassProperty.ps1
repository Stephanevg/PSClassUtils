Function Get-CUClassProperty {
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
        [String[]]$Path,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(ValueFromPipeline=$True)]
        [ValidateScript({
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
            $item=Get-Item -Path (Resolve-Path -Path $Path).path 
            $ClassParams.Path = $Item.FullName
        }

        If ($InputObject) {
            $ClassParams.ClassName = $ClassName
        }

       
        $Class = Get-CuClass @ClassParams
        If ($Class) {

            If($Raw){
                $Class.GetCuClassProperty().Raw
            }else{

                $Class.GetCuClassProperty()
            }
        }

        <# If ( $MyInvocation.PipelinePosition -eq 1 ) {
            ## Not from the Pipeline
            If ( $Null -eq $PSBoundParameters['InputObject'] ) {
                Throw "Please Specify an InputObject of type CUClass"
            }
            If ( $Null -eq $PSBoundParameters['ClassName'] ) {
                $InputObject.GetCuClassProperty()
            } Else {
                Foreach ( $C in $ClassName ){
                    ($InputObject | where Name -eq $c).GetCuClassProperty()
                }
            }

        } Else {
            ## From the Pipeline
            If ( $Null -eq $PSBoundParameters['ClassName'] ) {
                $InputObject.GetCuClassProperty()
            } Else {
                Throw "-ClassName parameter must be specified on the left side of the pipeline"
            }
        }
 #>
    }

    END {}

}