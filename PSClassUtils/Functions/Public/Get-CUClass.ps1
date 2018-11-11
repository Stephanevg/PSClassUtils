function Get-CUClass {
    <#
    .SYNOPSIS
        This function returns all classes, loaded in memory or present in a ps1 or psm1 file.
    .DESCRIPTION
        By default, the function will return all loaded classes in the current PSSession.
        You can specify a file path to explore the classes present in a ps1 or psm1 file.
    .PARAMETER ClassName
        Specify the name of the class.
    .PARAMETER Path
        The path of a file containing PowerShell Classes.
    .PARAMETER Raw
        The raw switch will display the raw content of the Class.
    .EXAMPLE
        PS C:\> Get-CUClass
        Return all classes alreay loaded in current PSSession.

        PS C:\> Get-CUClass -ClassName CUClass
        Return the particuluar CUCLass.

        PS C:\> Get-CUClass -Path .\test.psm1,.\test2.psm1
        Return all classes present in the test.psm1 and test2.psm1 file.

        PS C:\> Get-CUClass -Path .\test.psm1 -ClassName test
        Return test class present in the test.psm1 file.

        PS C:\PSClassUtils> Get-ChildItem -recurse | Get-CUClass
        Return all classes, recursively, present in the C:\PSClassUtils Folder.
    .INPUTS
        Accepts type [System.IO.FileInfo]
    .OUTPUTS
        Return type [CuClass]
    .NOTES
        Author: Tobias Weltner
        Version: ??
        Source --> http://community.idera.com/powershell/powertips/b/tips/posts/finding-powershell-classes
        Participate & contribute --> https://github.com/Stephanevg/PSClassUtils
    #>


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
  
