function Get-CUClass {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        $ClassName,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path,
        
        [Parameter(Mandatory = $False)]
        [Switch]$Raw = $False
    )

    BEGIN {
    }

    PROCESS {

        $ClassParams = @{}

        If ( $Null -ne $PSBoundParameters['ClassName'] ) {
            $ClassParams.ClassName = $PSBoundParameters['ClassName']
        }

        If ( $Null -ne $PSBoundParameters['Path'] ) {

            Foreach ( $Path in $PSBoundParameters['Path'] ) {
                If ( $Path.Extension -in '.ps1', '.psm1') {
                    If ($PSCmdlet.MyInvocation.ExpectingInput) {
                        $ClassParams.Path = $Path.FullName
                    } Else {
                        $ClassParams.Path = (Get-Item (Resolve-Path $Path).Path).FullName
                    }
            
                    $RawGlobalAST = Get-CURaw -Path $ClassParams.Path
                    $GlobalClassFromRaw = [CUClass]::New($RawGlobalAST)
                    
                    Switch ( $GlobalClassFromRaw.Ast ) {
                        { $GlobalClassFromRaw.Ast.count -eq 1 } {
                            If ( $PSBoundParameters['ClassName'] ) {
                                If ( $GlobalClassFromRaw.name -eq $PSBoundParameters['ClassName'] ) {
                                    If ( $PSBoundParameters['Raw'] ) {
                                        $GlobalClassFromRaw.Raw
                                    } Else {
                                        $GlobalClassFromRaw 
                                    }
                                }
                            } Else {
                                If ( $PSBoundParameters['Raw'] ) {
                                    $GlobalClassFromRaw.Raw
                                } Else {
                                    $GlobalClassFromRaw 
                                }
                            }
                            break;
                        }

                        { $GlobalClassFromRaw.Ast.count -gt 1 } {
                            Foreach ( $Class in $GlobalClassFromRaw.Ast ) {
                                If ( $PSBoundParameters['ClassName'] ) {
                                    If ( $Class.name -eq $PSBoundParameters['ClassName'] ) {
                                        If ( $PSBoundParameters['Raw'] ) {
                                            ([CUClass]::New($Class)).Raw
                                        } Else {
                                            [CUClass]::New($Class) 
                                        }
                                    }
                                } Else {
                                    If ( $PSBoundParameters['Raw'] ) {
                                        ([CUClass]::New($Class)).Raw
                                    } Else {
                                        [CUClass]::New($Class) 
                                    }
                                }
                            }
                            break;
                        } 

                    }
                }
            }

        } Else {
            Foreach ( $RawAST in (Get-CULoadedClass @ClassParams ) ) {
                
                $GlobalClassFromRaw = [CUClass]::New($RawAST)
                
                ## Test if more than one class in document or if inheritances classes
                If ( $GlobalClassFromRaw.Ast.count -gt 1 ) {
                    Foreach ( $Class in $GlobalClassFromRaw.Ast ) {
                        If ( $PSBoundParameters['Raw'] ) {
                            ([CUClass]::New($Class)).Raw
                        } Else {
                            [CUClass]::New($Class) 
                        }
                    }
                } Else {
                    If ( $PSBoundParameters['Raw'] ) {
                        ($GlobalClassFromRaw).Raw
                    } Else {
                        $GlobalClassFromRaw 
                    }
                     
                }

            } 
        }
    }

    END {}  
}
  
