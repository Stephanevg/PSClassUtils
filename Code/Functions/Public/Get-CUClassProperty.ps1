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

        [Switch]$Raw

    )

    BEGIN {}

    PROCESS {

        $ClassParams = @{}

        If ($ClassName -or $PSBoundParameters['ClassName'] ) {
            $ClassParams.ClassName = $ClassName
        }

        Switch ( $PSCmdlet.ParameterSetName ) {

            ## CUClass as input
            Set1 {

                Foreach ( $Class in $InputObject ) {
                    If ( $ClassParams.ClassName ) {
                        If ( $Class.Name -eq $ClassParams.ClassName ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                ($Class.GetCuClassProperty()).Raw
                            } Else {
                                $Class.GetCuClassProperty()
                            }
                        }
                    } Else {
                        If ( $PSBoundParameters['Raw'] ) {
                            ($Class.GetCuClassProperty()).Raw
                        } Else {
                            $Class.GetCuClassProperty()
                        }
                    }
                }
                
            }

            ## File as Input
            Set2 {
                Write-Verbose '[Get-CUClassProperty][FileInput]'
                Foreach ( $P in $Path ) {
                    Write-Verbose '[Get-CUClassProperty][FileInput Path is: $($p.fullname) ]'
                    If ( $P.extension -in ".ps1",".psm1" ) {

                        If ($PSCmdlet.MyInvocation.ExpectingInput) {
                            $ClassParams.Path = $P.FullName
                        } Else {
                            $ClassParams.Path = (Get-Item (Resolve-Path $P).Path).FullName
                        }
                        
                        $x=Get-CuClass @ClassParams
                        If ( $null -ne $x.Property ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($x.GetCuClassProperty()).Raw
                            } Else {
                                $x.GetCuClassProperty()
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

                Foreach($Class in (Get-CuClass @ClassParams)) {
                    If ( $Class.Constructor.count -ne 0 ) {
                        If ( $Raw ) {
                            $Class.GetCuClassProperty().Raw
                        } Else {

                            $Class.GetCuClassProperty()
                        }
                        
                    }
                }
            }
        }

    }

    END {}

}
