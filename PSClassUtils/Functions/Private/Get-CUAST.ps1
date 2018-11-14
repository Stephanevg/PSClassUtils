Function Get-CUAst {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True,ValueFromPipeline = $true)]
        [Alias('FullName')]
        [System.IO.FileInfo[]]$Path
    )
    
    begin {}
    
    process {
        foreach($p in $Path){

            If ( $P.Extension -in '.ps1','.psm1') {
                #[scriptblock]::Create( $(Get-Content -Path $P.FullName -Raw) ).Ast
                $Raw = [System.Management.Automation.Language.Parser]::ParseFile($p.FullName, [ref]$null, [ref]$Null)
                $AST = $Raw.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)

                ## If AST Count -gt 1 we need to retourn each one of them separatly
                Switch ($AST.count) {
                    
                    { $AST.count -eq 1 } {
                        $AST
                    }

                    { $AST.count -gt 1 } {
                        Foreach ( $x in $AST ) {
                            $x
                        }
                    }
                }
            }
        }
    }
    
    end {
    }
}

