Class ASTDocument {
    [System.Management.Automation.Language.StatementAst[]]$Classes
    [System.Management.Automation.Language.StatementAst[]]$Enums
    $Source
    $ClassName
    Hidden $Raw

    ASTDocument ([System.Management.Automation.Language.StatementAst[]]$Classes,[System.Management.Automation.Language.StatementAst[]]$Enums,$Source){
        $This.Classes = $Classes
        $This.Enums = $Enums
        $This.Source = $Source
        $This.ClassName = $Classes.Name
    }

    ASTDocument([System.Management.Automation.Language.StatementAst[]]$Classes,[System.Management.Automation.Language.StatementAst[]]$Enums,$Source,[System.Management.Automation.Language.ScriptBlockAst]$RawAST){
        $This.Classes = $Classes
        $This.Enums = $Enums
        $This.Source = $Source
        $This.ClassName = $Classes.Name
        $This.Raw = $RawAST
    }
}