using module C:\Users\Lx\GitPerso\PSFunctionUtils\PSFunctionExplorer\PSFunctionExplorer.psm1

InModuleScope -ModuleName PSFunctionExplorer -ScriptBlock {

Describe '[FUFunction]-[Constructors]'{

    $TestCaseFunctions = @'
    Function test-funcA {
        "plop"
    }
    
    Function test-funcB {
        test-funcA
    }
    
'@


    $FunctionScript = Join-Path -Path $Testdrive -ChildPath "fufunction.ps1"
    $TestCaseFunctions | Out-File -FilePath $FunctionScript -Force

It '[FUFunction]-[Constructor]([System.Management.Automation.Language.FunctionDefinitionAST]Raw,Path) should Not Throw' {

# -- Arrange
$ast = [FUUtility]::GetRawASTFunction($FunctionScript)

[System.Management.Automation.Language.FunctionDefinitionAST]$Raw=$ast[0]

$Path=$FunctionScript

# -- Assert

{[FUFunction]::New($Raw,$Path)} | Should Not Throw 

}# end of it block


It '[FUFunction]-[Constructor]([System.Management.Automation.Language.FunctionDefinitionAST]Raw,ExclusionList,Path) should Not Throw' {

# -- Arrange

$ast = [FUUtility]::GetRawASTFunction($FunctionScript)

[System.Management.Automation.Language.FunctionDefinitionAST]$Raw=$Ast[0]

$ExclusionList=@('Get-ChildItem','Get-Item')

$Path=$FunctionScript

# -- Assert

{[FUFunction]::New($Raw,$ExclusionList,$Path)} | Should Not Throw 

}# end of it block

}# end of Describe block


Describe '[FUFunction] - Test returned Object' {

    $TestCaseFunctions = @'
    Function test-funcA {
        "plop"
    }
    
    Function test-funcB {
        test-funcA
        $null = get-item
        $null = get-childitem
    }
    
'@


    $FunctionScript = Join-Path -Path $Testdrive -ChildPath "fufunction.ps1"
    $TestCaseFunctions | Out-File -FilePath $FunctionScript -Force

    It '[FUFunction]-[Return] should return a function called Test-Funcb' {

        # -- Arrange
        
        $ast = [FUUtility]::GetRawASTFunction($FunctionScript)
        
        [System.Management.Automation.Language.FunctionDefinitionAST]$Raw=$Ast[1]
        
        $Path=$FunctionScript
        
        # -- Assert
        
        ([FUFunction]::New($Raw,$Path)).Name | Should be "Test-FuncB" 
        
        }# end of it block

    It '[FUFunction]-[Return] Test-FuncB Commands Property count should be 3' {

        # -- Arrange
        
        $ast = [FUUtility]::GetRawASTFunction($FunctionScript)
        
        [System.Management.Automation.Language.FunctionDefinitionAST]$Raw=$Ast[1]
        
        $Path=$FunctionScript
        
        # -- Assert
        
        ([FUFunction]::New($Raw,$Path)).Commands.Count | Should be "3" 
        
    }# end of it block

    It '[FUFunction]-[Return] Test-FuncB Commands Property count should be 1 after Exclusion of GCI & Get-Item' {

        # -- Arrange
        
        $ast = [FUUtility]::GetRawASTFunction($FunctionScript)
        
        [System.Management.Automation.Language.FunctionDefinitionAST]$Raw=$Ast[1]
        
        $Path=$FunctionScript

        $ExclusionList = @('Get-ChildItem','Get-Item')
        
        # -- Assert
        
        ([FUFunction]::New($Raw,$ExclusionList,$Path)).Commands.Count | Should be "1" 
        
    }# end of it block
}
Describe '[FUUtility]-[Methods]'{

$TestCaseFunctions = @'
Function test-funcA {
    "plop"
}

Function test-funcB {
    test-funcA
} 
'@


$FunctionScript = Join-Path -Path $Testdrive -ChildPath "fufunction.ps1"
$TestCaseFunctions | Out-File -FilePath $FunctionScript -Force

#Public Method
It '[FUUtility] --> ToTitleCase($String) : [String] - should Not Throw' {

# -- Arrange

[string]$String = 'test-a'

# -- Assert

{[FUUtility]::ToTitleCase($String)} | Should Not Throw

} #End It Block

#Public Method
It '[FUUtility] --> ToTitleCase($String) : [String] - should return type [String]' {

# -- Arrange
[string]$String = 'test-a'

# -- Assert

([FUUtility]::ToTitleCase($String)).GetType().Name | should be String

} #End It Block

#Public Method
It '[FUUtility] --> GetRawASTFunction($Path) : [Object[]] - should Not Throw' {

# -- Arrange

$Path = $FunctionScript

# -- Assert

{[FUUtility]::GetRawASTFunction($Path)} | Should Not Throw

} #End It Block

#Public Method
It '[FUUtility] --> GetRawASTFunction($Path) : [Object[]] - should return type [Object[]]' {

# -- Arrange
$Path = $FunctionScript

# -- Assert

([FUUtility]::GetRawASTFunction($Path)).GetType().Name | should be Object[]

} #End It Block

#Public Method
It '[FUUtility] --> GetRawASTFunction($Path) : should count 2' {

    # -- Arrange
    $Path = $FunctionScript

    # -- Assert
    
    ([FUUtility]::GetRawASTFunction($Path)).count | should be 2
    
    } #End It Block

#Public Method
It '[FUUtility] --> GetFunction($RawASTFunction,$path) : [FUFunction] - should Not Throw' {

# -- Arrange

$ast = [FUUtility]::GetRawASTFunction($FunctionScript)

$RawASTFunction = $ast[0]

$path = $FunctionScript

# -- Assert

{[FUUtility]::GetFunction($RawASTFunction,$path)} | Should Not Throw

} #End It Block

#Public Method
It '[FUUtility] --> GetFunction($RawASTFunction,$path) : [FUFunction] - should return type [FUFunction]' {

# -- Arrange
$ast = [FUUtility]::GetRawASTFunction($FunctionScript)

$RawASTFunction = $ast[0]

$path = $FunctionScript

# -- Assert

([FUUtility]::GetFunction($RawASTFunction,$path)).GetType().Name | should be FUFunction

} #End It Block

#Public Method
It '[FUUtility] --> GetFunction($RawASTFunction,$Exculde,$path) : [FUFunction] - should Not Throw' {

# -- Arrange

$ast = [FUUtility]::GetRawASTFunction($FunctionScript)

$RawASTFunction = $ast[0]

$path = $FunctionScript

$Exclude = @('get-childitem','get-stuff')


# -- Assert

{[FUUtility]::GetFunction($RawASTFunction,$Exclude,$path)} | Should Not Throw

} #End It Block

#Public Method
It '[FUUtility] --> GetFunction($RawASTFunction,$Exculde,$path) : [FUFunction] - should return type [FUFunction]' {

# -- Arrange
$ast = [FUUtility]::GetRawASTFunction($FunctionScript)

$RawASTFunction = $ast[0]

$path = $FunctionScript

$Exclude = @('get-childitem','get-stuff')

# -- Assert

([FUUtility]::GetFunction($RawASTFunction,$Exclude,$path)).GetType().Name | should be FUFunction

} #End It Block

}#EndDescribeBlock

}#End InModuleScope


