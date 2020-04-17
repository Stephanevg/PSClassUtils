using namespace System.Management.Automation.Language

class CUHelper {

    [CUClass[]] static FindClass() {
        ## sera retourner
        $x = @()

        $name = "*"

        [Array]$LoadedClasses = [AppDomain]::CurrentDomain.GetAssemblies() |
                Where-Object { $_.GetCustomAttributes($false) |
                Where-Object { $_ -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute]} } |
                ForEach-Object { 
                    $_.GetTypes() |
                    Where-Object IsPublic | Where-Object { $_.Name -like $name } |
                    Select-Object @{l = 'Path'; e = {($_.Module.ScopeName.Replace([char]0x29F9, '\').replace([char]0x589, ':')) -replace '^\\', ''}}
                }

            Foreach ( $Class in ($LoadedClasses | Select-Object -Property Path -Unique) ) {
                # Get-CUAst -Path $Class.Path
                ## On parse le fichier
                $ParsedFile = [Parser]::ParseFile($Class.Path, [ref]$null, [ref]$Null)
                ## un script  commence toujours par un nameblockast, on recherche donc ce type d'AST
                $NamedBlock = $ParsedFile.find({$args[0] -is [namedblockast]},$false)

                ## On parcour toutes les AST
                foreach ( $node in  $NamedBlock.FindAll({$args[0] -is [TypeDefinitionAst]},$false) ) {
                    $x += [CUClass]::new($node)
                }
            }
        return $x
    }

    [CUClass[]] static FindClass([string]$File) {
        ## sera retourner
        $x = @()
    
        ## On parse le fichier
        $ParsedFile = [Parser]::ParseFile($file, [ref]$null, [ref]$Null)
    
        ## un script  commence toujours par un nameblockast, on recherche donc ce type d'AST
        $NamedBlock = $ParsedFile.find({$args[0] -is [namedblockast]},$false)
    
        ## On parcour toutes les AST
        foreach ( $node in  $NamedBlock.FindAll({$args[0] -is [TypeDefinitionAst]},$false) ) {
            $x += [CUClass]::new($node)
        }
        return $x
    }
}