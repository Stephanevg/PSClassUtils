$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\utilities.Tattoo.psm1"
Import-module "..\.\PSClassUtils.psm1" -Force

Describe "Testing Get-ClassConstructors"{
    
    InModuleScope PSClassUtils {


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
        . $ClassScript
        
        

        it 'Should Return 3 Constructors' {


            (Get-ClassConstructors -ClassName "Woop" | measure).Count | should be 3
        }

        Context 'Validating Properties' {
            
            $Properties = @("String","Number","Time")
            $Constructors = Get-ClassConstructors -ClassName "Woop"
            foreach ($prop in $Properties){

                it "Should have Property: $($Prop)" {
                    ($Constructors | gm).Name -contains $prop
                }
            }

        
            foreach($w in $Constructors){
                    if($w.Properties){

                        it "$($w.Name) should have property of type 'ClassProperty[]'" {

                            $w.Properties.GetType().Name | should be 'ClassProperty[]'
                        }
                    }
            }
        }
    }
    
        
    
}