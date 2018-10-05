#$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

Import-Module -Force $PSScriptRoot\..\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'Get-CUAST'" {

        
        $TestCaseClass = @'
        Class Woop {
            [String]$String
            [int]$number
        
            Woop(){
    
            }

            Woop([String]$String,[int]$Number){
                
            }
            Woop([String]$String,[int]$Number,[DateTime]$Time){
            
            }
        
            [String]DoSomething(){
                return $this.String
            }
        }
        
        Class Wap :Woop {
            [String]$prop3
        
            DoChildthing(){}
            [int]DoChildthing2(){
                return 3
            }
            DoChildthing3([int]$Param1,[bool]$Param2){
                #Does stuff
            }
            [Bool] DoChildthing4([String]$MyString,[int]$MyInt,[DateTime]$MyDate){
                return $true
            }
            
        
        }
        
        Class Wep : Woop {
            [String]$prop4
        
            DoOtherChildThing(){
        
            }
        }
'@
    

        $ClassScript = Join-Path -Path $Testdrive -ChildPath "WoopClass.ps1"
        $TestCaseClass | Out-File -FilePath $ClassScript -Force

        it 'Should return an object of type ASTDocument' {
            $a = Get-CUAST -Path $ClassScript
            $a.GetType().FullName | should be ASTDocument
        }

        It 'Parameter: -PAth Should work'{
            $a = Get-CUAST -Path $ClassScript
            $a | should not beNullOrEmpty
            $a.GetType().FullName | should be ASTDocument
        }

        It 'Parameter: -InputObject Should work with pipeline input'{
            {$ClassScript | Get-CUAST} | Should Not Throw
        }

        It 'Parameter: -InputObject Should work as parameter'{
            ($ClassScript | Get-CUAST).GetType().FullName | should be "ASTDocument"
        }

        It '[BugFix] RelativePath: Should resolve Relative Path without throwing'{
            Push-Location
            set-location $Testdrive
            {Get-CUAst -Path ".\WoopClass.ps1"} | should not throw
            Pop-Location
        }

        It '[BugFix] RelativePath: Should point to correct file path'{
            Push-Location
            set-location $Testdrive
            $obj = Get-CUAst -Path ".\WoopClass.ps1"
            $obj.Source | should be $ClassScript
            Pop-Location
        }
    }
}