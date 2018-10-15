function Get-CURaw {
    <#
    .SYNOPSIS
        Return the raw content of a ps1 or psm1 file as a AST scriptblock type.
    .DESCRIPTION
        Return the raw content of a ps1 or psm1 file as a AST scriptblock type.
    .EXAMPLE
        PS C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils> Get-CURaw -Path .\Classes\Private\01_ClassProperty.ps1
        Attributes         : {}
        UsingStatements    : {}
        ParamBlock         :
        BeginBlock         :
        ProcessBlock       :
        EndBlock           : Class ClassProperty {
                                [String]$Name
                                [String]$Type

                                ClassProperty([String]$Name,[String]$Type){

                                    $this.Name = $Name
                                    $This.Type = $Type

                                }
                            }
        DynamicParamBlock  :
        ScriptRequirements :
        Extent             : Class ClassProperty {
                                [String]$Name
                                [String]$Type

                                ClassProperty([String]$Name,[String]$Type){

                                    $this.Name = $Name
                                    $This.Type = $Type

                                }
                            }
        Parent             :

        The cmdlet return an AST type representing the content of the 01_ClassProperty.ps1 file
    .INPUTS
        Path of a ps1 or psm1 file
    .OUTPUTS
       ScriptBlockAST
    .NOTES
        Ref: https://mikefrobbins.com/2018/09/28/learning-about-the-powershell-abstract-syntax-tree-ast/ for implementing -raw AST
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(ParameterSetName="Path",Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path
    )
    
    BEGIN{}
    
    PROCESS{

        Foreach ( $P in $Path ) {
            
            If ( $MyInvocation.PipelinePosition -eq 1 ) {
                $P = Get-Item (resolve-path $P).Path
            }

            If ( $P.Extension -in '.ps1','.psm1') {
                [scriptblock]::Create( $(Get-Content -Path $P.FullName -Raw) ).Ast
            }

        }

    }
    
    END{}
}