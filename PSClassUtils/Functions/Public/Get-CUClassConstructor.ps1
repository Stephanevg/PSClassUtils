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
    [OutputType([CUClassMethod[]])]
    Param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set1")]
        [CUClass[]]$InputObject,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set2",ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Mandatory=$False,DontShow)]
        [Switch]$Code
    )

    BEGIN {}

    PROCESS {

        Switch ( $PSCmdlet.ParameterSetName ) {

            ## CUClass as input
            Set1 {

                $ClassParams = @{}
                
                ## ClassName was specified
                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $Class in $InputObject ) {
                    If ( $ClassParams.ClassName ) {
                        If ( $Class.ClassName -eq $ClassParams.ClassName ) {
                            ## Code switch was used
                            If ( $Code ) {
                                $Class.GetCUClassConstructor() | select-object *,@{l="CodeText";e={$_.Extent}}
                            } Else {
                                $Class.GetCUClassConstructor()
                            }
                        }
                    } Else {
                        If ( $null -ne $Class.Constructor ) {
                            ## Code switch was used
                            If ( $Code ) {
                                $Class.GetCUClassConstructor() | select-object *,@{l="CodeText";e={$_.Extent}}
                            } Else {
                                $Class.GetCUClassConstructor()
                            }
                        }
                    }
                }
            }

            Set2 {

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $P in $Path ) {
                    $ClassParams = @{}
                    If ( $P.extension -in ".ps1",".psm1" ) {

                        If ($PSCmdlet.MyInvocation.ExpectingInput) {
                            $ClassParams.Path = $P.FullName
                        } Else {
                            $ClassParams.Path = (Get-Item (Resolve-Path $P).Path).FullName
                        }
                        
                        $x=Get-CuClass @ClassParams
                        If ( $null -ne $x.Constructor ) {
                            If ( $Code ) {
                                $x.GetCUClassConstructor() | select-object *,@{l="CodeText";e={$_.Extent}}
                            } Else {
                                $x.GetCUClassConstructor()
                            }
                        }
                    }
                }
            }

            Default {
                $ClassParams = @{}

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach($x in (Get-CuClass @ClassParams)){
                    If ( $x.Constructor.count -ne 0 ) {
                        If ( $Code ) {
                            $x.GetCUClassConstructor() | select-object *,@{l="CodeText";e={$_.Extent}}
                        } Else {
                            $x.GetCUClassConstructor()
                        }
                    }
                }
                
                
            }
        }

    }

    END {}

}