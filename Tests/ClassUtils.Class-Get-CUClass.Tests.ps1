#$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'Get-CUClass'" {

        
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
        copy-item -Path $ClassScript -Destination $ClassScript.Replace("WoopClass.ps1","WoopClass2.ps1")

        it '[PARAMETER][Parameterless] Should return an object of type CUClass' {
            #This one is a bit 'tricky'. the classes that are returned, are the ones already loaded by the PSClassUtils module.
            #This, it is okay to have them there, but we might hide them in the future (which would make sense), so this test might fail, and probably should be 
            #rewriten.

            $a = Get-CUClass -Path $ClassScript
            $a[0].GetType().FullName | should be CUClass
        }

        It '[PARAMETER][-Path] Single file Should not throw'{
            {Get-CUClass -Path $ClassScript} | should not throw
            
        }
        it '[PARAMETER][-Path] Single file Should return an object of type CUClass' {
            $a = Get-CUClass -Path $ClassScript
            $a[0].GetType().Name | should be CUClass
        }
        it '[PARAMETER][-Path] When parameter is empty should throw'{
            {Get-CUClass -Path ""} | should throw
        }

        It '[PIPELINE] Piping a single fileInfo should not throw'{
            { $ClassScript | Get-CUClass} | Should Not Throw
        }

        It '[PIPELINE] Piping a single fileInfo should return an CUClass'{
            ($ClassScript| Get-CUClass)[0].GetType().FullName | should be "CUClass"
        }

        copy-item -Path $ClassScript -Destination $ClassScript.Replace("WoopClass.ps1","WoopClass2.ps1")

        It '[PARAMETER][-Path] array of files Should not throw'{
            {Get-CUClass -Path $Testdrive.FullName} | should not throw
            
        }
        it '[PARAMETER][-Path] array of files Should return an array of objects of type ASTDocument' {
            $classes = Get-CUClass -Path $Testdrive.FullName
            foreach ($class in $Classes){

                $Class.GetType().FullName | should be ASTDocument
            }
        }
        
    }
}