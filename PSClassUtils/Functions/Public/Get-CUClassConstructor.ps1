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
    [cmdletBinding(DefaultParameterSetName="All")]
    Param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set1")]
        [CUClass[]]$InputObject,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set2",ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path
    )

    BEGIN {}

    PROCESS {

        If ( $MyInvocation.PipelinePosition -eq 1 ) {
            
            $ClassParams = @{}

            If ( $null -ne $PSBoundParameters['Path'] ) {
                Foreach ( $Path in $PSBoundParameters['Path'] ) {
                    $Path = Get-Item (resolve-path $Path).Path
                    $ClassParams.Path = $Path.FullName
                }
            }

            If ( $null -ne $PSBoundParameters['ClassName'] ) {
                $ClassParams.ClassName = $PSBoundParameters['ClassName']
            }

            $x = Get-CuClass @ClassParams
            If ( $Null -ne $x ) {
                $x.GetCuClassConstructor()
            }


        } Else {

            Switch ($PSCmdlet.ParameterSetName) {

                "Set1" {

                    $ClassFilter = If( $PSBoundParameters['ClassName'] ) { $PSBoundParameters['ClassName'] } Else { "*" }
                    Foreach ( $Class in $InputObject ) {
                        If ( $Class.Name -like $ClassFilter ){
                            $Class.GetCuClassConstructor()
                        }
                    }
                    
                }

                "Set2" {

                    $ClassParams = @{}
                    If( $PSBoundParameters['ClassName'] ) { 
                        $ClassParams.ClassName = $PSBoundParameters['ClassName']
                    }

                    Foreach ( $P in $Path ) {
                        
                        If ( $P.Extension -in '.ps1', '.psm1') {
                            $ClassParams.Path = $P.FullName
                            ## On recupere la classe, Si c'est un ps1 ou psm1 qui ne contient pas de classes alors x est null
                            $x = Get-CuClass @ClassParams
                            If ( $Null -ne $x) {
                                $x.GetCuClassConstructor()
                            }
                        }

                    }

                }

            }

        }

    }

    END {}

}