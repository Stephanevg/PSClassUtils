Class ASTDocument {
    [System.Management.Automation.Language.StatementAst[]]$Classes
    [System.Management.Automation.Language.StatementAst[]]$Enums
    $Source

    ASTDocument ([System.Management.Automation.Language.StatementAst[]]$Classes,[System.Management.Automation.Language.StatementAst[]]$Enums,$Source){
        $This.Classes = $Classes
        $This.Enums = $Enums
        $This.Source = $Source
    }
}