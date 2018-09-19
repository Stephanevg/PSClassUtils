Class ASTDocument {
    [System.Management.Automation.Language.StatementAst[]]$Classes
    [System.Management.Automation.Language.StatementAst[]]$Enums

    ASTDocument ([System.Management.Automation.Language.StatementAst[]]$Classes,[System.Management.Automation.Language.StatementAst[]]$Enums){
        $This.Classes = $Classes
        $This.Enums = $Enums
    }
}