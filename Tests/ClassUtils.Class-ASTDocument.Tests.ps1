Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

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


    Describe "Testing Class: 'ASTDocument'" {

        #Mock -CommandName New-Object {ASTDocument} -mockWtih
        it 'Parameterless Constructor: Should throw'{
            
            
            {[ASTDocument]::New()} | should throw
            #$ClassScript = Join-Path -Path $Testdrive -ChildPath "WoopClass.ps1"
            #$TestCaseClass | Out-File -FilePath $ClassScript -Force
            
            
        }

        #I would need to mock the ASTDOcument class. I haven't found a way to do so. 
        #Please share if you know how to do.
        
    }
}