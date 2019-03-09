
Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope -ModuleName PsClassUtils -ScriptBlock {

    $ClassTest = @'
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

    [String]TrickyMethod([String]$Salutations,[Bool]$IsthatTrue){
        return $this.String
    }

    [void] VoidedMethod(){
        #Do stuff
    }

    [string] static MyStaticMethod(){
        #Does Stuff
        return "plop"
    }
}
'@


    Describe "testing write-CupesterTest" {

       

        It '[write-CupesterTest] - Parameterless Should throw' {
            {write-CupesterTest } | Should throw
        }


        Context "Testing -Path with '*.ps1'" {

            
            It '[write-CupesterTest] - Path Plop.ps1 Should not throw' {

                #Arrange
                $File = "plop.ps1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                #Assert

                {write-CupesterTest -Path $FullFile } | Should Not Throw
            }

            It '[write-CupesterTest] - Path Plop.ps1 Should Create a Test file' {

                #Arrange
                $File = "plop.ps1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                write-CupesterTest -Path $FullFile
                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty

            }

            It '[write-CupesterTest] - Path .\Plop.ps1 -PassThru Should Create a Test file and return [System.IO.FileInfo]' {

                #Arrange
                $File = "plop.ps1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                $Out = write-CupesterTest -Path $FullFile -PassThru

                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                $Out | Should not beNullOrEmpty
                $Out.GetType().FullName | Should be 'System.IO.FileInfo'

            }

            It '[write-CupesterTest] - Path .\Plop.ps1 -ExportFolderPath [System.IO.DirectoryInfo] Should Create a Tests file on alternative path' {

                #Arrange
                $File = "plop.ps1"
                
                gci -Path $TestDrive | Remove-Item -Force
                $FullFile = Join-Path -Path $TestDrive -ChildPath $File
                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force
                $ExportFolderPath = Join-Path -Path $TestDrive -ChildPath "Export"
                mkdir $ExportFolderPath | out-null

                #Act 


                write-CupesterTest -Path $FullFile -ExportFolderPath $ExportFolderPath




                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should beNullOrEmpty
                Get-ChildItem -Path $ExportFolderPath -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                

            }

            It '[write-CupesterTest] - Path .\Plop.ps1 -IgnoreParameterLessConstructor Should not add the parameterless constructor test.' {

                #Arrange
                $File = "plop.ps1"
                
                #Act 
                gci $testdrive | remove-item -force -Recurse
                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                write-CupesterTest -Path $TestDrive -IgnoreParameterLessConstructor
                #Assert

                $f = Gci -path $TestDrive -Filter "*.tests.ps1"

                $res = select-string -Pattern '^.*Constructor.*-.*Parameterless should not Throw.*$' -Path $f.FullName

                $Res | Should beNullOrEmpty  

            }

        }

        Context "Testing -Path with '*.psm1'" {
            It '[write-CupesterTest] - Path Plop.psm1 Should not throw' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 
    
                $FullFile = Join-Path -Path $TestDrive -ChildPath $File
                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force
    
                #Assert
    
                {write-CupesterTest -Path $FullFile} | Should Not Throw
            }

            It '[write-CupesterTest] - Path Plop.psm1 Should Create a Test file' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                write-CupesterTest -Path $FullFile
                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty

            }

            It '[write-CupesterTest] - Path .\Plop.psm1 -PassThru Should Create a Test file and return [System.IO.FileInfo]' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                $Out = write-CupesterTest -Path $FullFile -PassThru

                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                $Out | Should not beNullOrEmpty
                $Out.GetType().FullName | Should be 'System.IO.FileInfo'

            }

            It '[write-CupesterTest] - Path .\Plop.psm1 -ExportFolderPath [System.IO.DirectoryInfo] Should Create a Tests file on alternative path' {

                #Arrange
                $File = "plop.psm1"
                
                gci -Path $TestDrive | Remove-Item -Force
                $FullFile = Join-Path -Path $TestDrive -ChildPath $File
                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force
                $ExportFolderPath = Join-Path -Path $TestDrive -ChildPath "Export"
                mkdir $ExportFolderPath | out-null
                
                #Act 


                write-CupesterTest -Path $FullFile -ExportFolderPath $ExportFolderPath




                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should beNullOrEmpty
                Get-ChildItem -Path $ExportFolderPath -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                

            }

            It '[write-CupesterTest] - Path .\Plop.psm1 -IgnoreParameterLessConstructor Should not add the parameterless constructor test.' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 

                gci $testdrive | remove-item -force -Recurse
                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                write-CupesterTest -Path $TestDrive -IgnoreParameterLessConstructor
                #Assert

                $f = Gci -path $FullFile -Filter "*.tests.ps1"

                $res = select-string -Pattern '^.*Constructor.*-.*Parameterless should not Throw.*$' -Path $f.FullName

                $Res | Should beNullOrEmpty 

            }
        }


        Context "Testing -Path with 'Folder'" {

            It '[write-CupesterTest] - Path [System.IO.DirectoryInfo] Should not throw' {
    
                {write-CupesterTest -Path $TestDrive} | Should Not Throw
            }

            It '[write-CupesterTest] - Path [Folder] Should Create a Test file' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                write-CupesterTest -Path $TestDrive
                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty

            }

            It '[write-CupesterTest] - Path [Folder] -Passtru Should Create a Test file and return [System.IO.FileInfo]' {
                
                    Get-ChildItem -Path $TestDrive | Remove-Item -Force
                
                #Arrange
                $File = "plop.ps1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                $Out = write-CupesterTest -Path $TestDrive -PassThru

                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                $Out | Should not beNullOrEmpty
                $Out.GetType().FullName | Should be 'System.IO.FileInfo'

            }

            It '[write-CupesterTest] - Path [Folder] -ExportFolderPath [System.IO.DirectoryInfo] Should Create a Tests file on alternative path' {

                #Arrange
                $File = "plop.psm1"
                
                gci -Path $TestDrive | Remove-Item -Force
                $FullFile = Join-Path -Path $TestDrive -ChildPath $File
                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                $ExportFolderPath = Join-Path -Path $TestDrive -ChildPath "Export"
                mkdir $ExportFolderPath | out-null
                
                #Act 

                write-CupesterTest -Path $TestDrive -ExportFolderPath $ExportFolderPath

                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should beNullOrEmpty
                Get-ChildItem -Path $ExportFolderPath -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                

            }

            It '[write-CupesterTest] - Path [Folder] -IgnoreParameterLessConstructor Should not add the parameterless constructor test.' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 

                gci $testdrive | remove-item -force -Recurse
                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                write-CupesterTest -Path $TestDrive -IgnoreParameterLessConstructor
                #Assert

                $f = Gci -path $TestDrive -Filter "*.tests.ps1"

                $res = select-string -Pattern '^.*Constructor.*-.*Parameterless should not Throw.*$' -Path $f.FullName

                $Res | Should beNullOrEmpty 

            }
        }

        Context "Testing -ModuleFolderPath" {

            It '[write-CupesterTest] - ModuleFolderPath & -Path should not be allowed.' {

                #Arrange
                
                
                #Act 

               

                #Assert
                {write-CupesterTest -Path $TestDrive -ModuleFolderPath $TestDrive} | Should throw


            }

            It '[write-CupesterTest] - ModuleFolderPath Plop Should Create a Test file' {

                #Arrange
                $File = "plop.psm1"
                $FakeModulePath = Join-Path $TestDrive -ChildPath "plop" 
                mkdir $FakeModulePath | out-null
                $psd1 = New-ModuleManifest -Path ($FakeModulePath + ".plop.psd1")

                #Act 

                $FullFile = Join-Path -Path $FakeModulePath -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                write-CupesterTest -Path $FullFile
                #Assert

                Get-ChildItem -Path $FakeModulePath -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1'  | Should beNullOrEmpty
            }
        }
    }
}