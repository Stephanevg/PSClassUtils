$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\utilities.Tattoo.psm1"
Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

Describe "Testing Get-CUClassMethod"{
    
    InModuleScope PSClassUtils {


        $TestCaseClass = @'
        Class Woop {
            [String]$String
            [int]$number
        
            Woop(){
    
            }
    
            Woop([String]$String,[int]$Number){
        
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
        
        

        it 'Should Return 5 methods' {


            (Get-CUClassMethod -ClassName "Wap" | measure).Count | should be 5
        }

        Context 'Validating Properties' {
            $Properties = @("Name","Properties","ReturnType")
            $methods = Get-CUClassMethod -ClassName "Wap"
            foreach ($prop in $Properties){

                it "Should have Property: $($Prop)" {
                    ($methods | gm).Name -contains $prop
                }
            }

        
            foreach($w in $methods){
                    if($w.Properties){

                        it "$($w.Name) should have property of type 'ClassProperty[]'" {

                            $w.Properties.GetType().Name | should be 'ClassProperty[]'
                        }
                    }
            }

                $DoChildthing4 = Get-CUClassMethod -ClassName "Wap" | ? {$_.Name -eq 'DoChildthing4'}
                it "should have property Name with value: 'DoChildthing4' " {

                    $DoChildthing4.Name | should be 'DoChildthing4'

                }

                it "should have property ReturnType with value: 'Bool' " {

                    $DoChildthing4.ReturnType | should be 'Bool'
                    
                }

                it "should have property Properties with 3 properties " {

                    ($DoChildthing4.Properties | Measure).Count | should be 3
                    
                }
                

                foreach ($p in $DoChildthing4.Properties){
                    switch ($p.Name){
                        "MyString" {
                            it "Property : 'MyString' should be of type 'string' " {
        
                                $p.Type | should be 'String'
                                
                            }
                            break
                        }
                        "MyInt" {
                            it "Property : 'MyInt' should be of type 'int' " {
        
                                $p.Type | should be 'int'
                                
                            }
                            Break
                        }
                        "MyDate" {
                            it "Property : 'MyDate' should be of type 'Date' " {
        
                                $p.Type | should be 'DateTime'
                                
                            }
                            Break
                        }
                        default {
                            throw "Unhandled property type."
                        }
                    }
                    
                    
                }
                
        }
        

        Context 'Testing Method types'{

            $methods = Get-CUClassMethod -ClassName "Wap"
            foreach($w in $methods){
                    it "Method $($w.Name)(): should be of type 'ClassMethod'" {
        
                        $w.GetType().Name | should be 'ClassMethod'
                    }
            }
        }

    }
    
        
    
}