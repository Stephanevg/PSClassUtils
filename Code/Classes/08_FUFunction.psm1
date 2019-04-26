class FUFunction {
    $Name
    [System.Collections.ArrayList]$Commands = @()
    $Path
    hidden $RawFunctionAST

    FUFunction ([System.Management.Automation.Language.FunctionDefinitionAST]$Raw,$Path) {
        $this.RawFunctionAST = $Raw
        $this.name = [FUUtility]::ToTitleCase($this.RawFunctionAST.name)
        $this.Path = $path
        $this.GetCommands()
    }

    FUFunction ([System.Management.Automation.Language.FunctionDefinitionAST]$Raw,$ExclusionList,$Path) {
        $this.RawFunctionAST = $Raw
        $this.Name = [FUUtility]::ToTitleCase($this.RawFunctionAST.name)
        $this.Path = $path
        $this.GetCommands($ExclusionList)
    }

    hidden GetCommands () {

        $t = $this.RawFunctionAST.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
        If ( $t.Count -gt 0 ) {
            ## si elle existe deja, on ajotue juste à ces commands
            ($t.GetCommandName() | Select-Object -Unique).Foreach({
                $Command = [FUUtility]::ToTitleCase($_)
                $this.Commands.Add($Command)
            })
        }
    }

    ## Overload
    hidden GetCommands ($ExclusionList) {

        $t = $this.RawFunctionAST.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
        If ( $t.Count -gt 0 ) {
            ($t.GetCommandName() | Select-Object -Unique).Foreach({
                $Command = [FUUtility]::ToTitleCase($_)
                If ( $ExclusionList -notcontains $Command) {
                    $this.Commands.Add($Command)
                }
            })
        }
    }
}

Class FUUtility {

    ## Static Method to TitleCase
    Static [String]ToTitleCase ([string]$String){
        return (Get-Culture).TextInfo.ToTitleCase($String.ToLower())
    }

    ## Static Method to return Function in AST Form, exclude classes
    [Object[]] static GetRawASTFunction($Path) {

        $RawFunctions   = $null
        $ParsedFile     = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$Null)
        $RawAstDocument = $ParsedFile.FindAll({$args[0] -is [System.Management.Automation.Language.Ast]}, $true)

        If ( $RawASTDocument.Count -gt 0 ) {
            ## source: https://stackoverflow.com/questions/45929043/get-all-functions-in-a-powershell-script/45929412
            $RawFunctions = $RawASTDocument.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $($args[0].parent) -isnot [System.Management.Automation.Language.FunctionMemberAst] })
        }

        return $RawFunctions
    }

    ## GetFunction, return [FuFunction]
    [FUFunction] Static GetFunction($RawASTFunction,$path){
        return [FUFunction]::New($RawASTFunction,$path)
    }

    ## GetFunctions Overload, with ExclustionList, return [FuFunction]
    [FUFunction] Static GetFunction($RawASTFunction,$Exculde,$path){
        return [FUFunction]::New($RawASTFunction,$Exculde,$path)
    }

}