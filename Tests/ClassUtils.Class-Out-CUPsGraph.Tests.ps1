#$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

Import-Module -Force $PSScriptRoot\..\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    $TestCaseClass = @'
    
    Class Woop {
        [String]$String
        [int]$number
    
        Woop([String]$String,[int]$Number){
    
        }
    
        [String]DoSomething(){
            return $this.String
        }
    }
    
    Class Wap :Woop {
        [String]$prop3
    
        DoChildthing(){}
    
    }
    
    Class Wep : Woop {
        [String]$prop4
    
        DoOtherChildThing(){
    
        }
    }
    
'@

    Describe "Testing Class: 'Out-CUPSGraph'" {
        $ClassScript = Join-Path -Path $Testdrive -ChildPath "WoopClass.ps1"
        $TestCaseClass | Out-File -FilePath $ClassScript -Force

 
        it 'Should output a PSgraph' {
            Get-CUAST -PAth $ClassScript | Out-CUPSGraph | Select-String "digraph g {" | should not beNullOrEmpty
        }
    }
}