Class ASTDocument {
    [System.Management.Automation.Language.StatementAst[]]$Classes
    [System.Management.Automation.Language.StatementAst[]]$Enums
    $Source
    $ClassName

    ASTDocument ([System.Management.Automation.Language.StatementAst[]]$Classes,[System.Management.Automation.Language.StatementAst[]]$Enums,$Source){
        $This.Classes = $Classes
        $This.Enums = $Enums
        $This.Source = $Source
        $This.ClassName = $Classes.Name
    }
}