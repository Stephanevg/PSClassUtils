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

            Write-Verbose "Current file $p"
            If ( $P.Extension -in '.ps1','.psm1') {
                Write-Verbose "Current file $p is a PS1 or PSM1 file..."
                $Raw = [System.Management.Automation.Language.Parser]::ParseFile($p.FullName, [ref]$null, [ref]$Null)
                $AST = $Raw.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)

                ## If AST Count -gt 1 we need to retourn each one of them separatly
                Switch ($AST.count) {
                    
                    { $AST.count -eq 1 } {
                        Write-Verbose "Current file $p contains 1 AST..."
                        $AST
                    }

                    { $AST.count -gt 1 } {
                        Write-Verbose "Current file $p contains $($ast.count) AST..."
                        Foreach ( $x in $AST ) {
                            $x
                        }
                    }

                    Default {
                        Write-Verbose "Current file $p contains $($ast.count) AST..."
                    }
                }
            } Else {
                Write-Verbose "Current file $p is not a PS1 or PSM1 file..."
            }
        }
    }
    
    end {
    }
}

