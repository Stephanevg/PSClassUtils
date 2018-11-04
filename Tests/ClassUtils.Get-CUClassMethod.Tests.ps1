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
        
        

        it 'Should Return 4 methods' {


            (Get-CUClass -Path $ClassScript -ClassName Wap | Get-CUClassMethod | measure).Count | should be 4
        }

        Context 'Validating Properties' {
            $Properties = @("Name","Properties","ReturnType")
            $methods = Get-CUClass -Path $ClassScript -ClassName Wap | Get-CUClassMethod
            foreach ($prop in $Properties){

                it "Should have Property: $($Prop)" {
                    ($methods | gm).Name -contains $prop
                }
            }

        
            foreach($w in $methods){
                    if($w.Parameter){

                        it "$($w.Name) should have Parameter of type 'ClassParameter[]'" {

                            $w.Parameter.GetType().Name | should be 'ClassParameter[]'
                        }
                    }
            }

                $DoChildthing4 = Get-CUClass -Path $ClassScript -ClassName Wap | Get-CUClassMethod | ? {$_.Name -eq 'DoChildthing4'}
                it "should have property Name with value: 'DoChildthing4' " {

                    $DoChildthing4.Name | should be 'DoChildthing4'

                }

                it "should have property ReturnType with value: 'Bool' " {

                    $DoChildthing4.ReturnType | should be '[Bool]'
                    
                }

                it "should have property Properties with 3 properties " {

                    ($DoChildthing4.Parameter | Measure).Count | should be 3
                    
                }
                

                foreach ($p in $DoChildthing4.Parameter){
                    switch ($p.Name){
                        "MyString" {
                            it "Property : 'MyString' should be of type '[string'] " {
        
                                $p.Type | should be '[String]'
                                
                            }
                            break
                        }
                        "MyInt" {
                            it "Property : 'MyInt' should be of type '[int]' " {
        
                                $p.Type | should be '[int]'
                                
                            }
                            Break
                        }
                        "MyDate" {
                            it "Property : 'MyDate' should be of type '[DateTime]' " {
        
                                $p.Type | should be '[DateTime]'
                                
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

            $methods = Get-CUClass -Path $ClassScript -ClassName Wap | Get-CUClassMethod
            foreach($w in $methods){
                    it "Method $($w.Name)(): should be of type 'CUClassMethod'" {
        
                        $w.GetType().Name | should be 'CUClassMethod'
                    }
            }
        }

        
        Context "[CUClassMethod] Parameters"{

            
            
            it '[CUClassMethod][Parameter][-Path] when given a path, it should not throw'{
                {Get-CUClassMethod -Path $ClassScript -ClassName "wap"} | should not throw
            }
            

            it '[CUClassMethod][Parameter][-Path] should return type CUClassMethod'{
                $ret = Get-CUClassMethod -Path $ClassScript -ClassName "wap"
                foreach($r in $ret){
                 $r.GetType().fullName | should be "CUClassMethod"
                }
            }

            it '[CUClassMethod][Parameter][-Path][-Raw] It should not throw'{
                {Get-CUClassMethod -Path $ClassScript -ClassName "Wap" -Raw} | should not throw
            }

            it '[CUClassMethod][Parameter][-raw] It should return the right type'{
                $raws = Get-CUClassMethod -Path $ClassScript -ClassName "wap" -Raw
                foreach($r in $raws){
                 $r.GetType().fullName | should be "System.Management.Automation.Language.FunctionMemberAst"   
                }
            }
            
        }
        <#
        Context "[CUClassMethod] Parameters"{

            it "Should work with Path"{

                #$ClassParmPath= Get-Item "File"
                #Get-CUClassConstructor -ClassName ClassParameter -Path $ClassParmPath
                #Get-CuClassMethod -Path $ClassParmPath -ClassName "CUClass"
                Throw "Not implemented. Please write this test"
            }


        }
        #>
        #>
    }
    
        
    
}