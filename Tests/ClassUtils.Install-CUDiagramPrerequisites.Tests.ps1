Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Function: 'Install-CUDiagramPrerequisites'" {
        it '[Function][Parameter] The proxy parameter should be available.' {

            (Get-Command Install-CUDiagramPrerequisites).Parameters.keys -contains "proxy"  

        }
        it '[Function][Parameter] The scope parameter should be available.' {

            (Get-Command Install-CUDiagramPrerequisites).Parameters.keys -contains "scope"  

        } 
    }
}
