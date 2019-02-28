
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


    Describe "testing Write-CUPesterTests" {

       

        It '[Write-CUPesterTests] - Parameterless Should throw' {
            {Write-CUPesterTests } | Should throw
        }


        Context "Testing -Path with '*.ps1'" {

            
            It '[Write-CUPesterTests] - Path Plop.ps1 Should not throw' {

                #Arrange
                $File = "plop.ps1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                #Assert

                {Write-CUPesterTests -Path $FullFile } | Should Not Throw
            }

            It '[Write-CUPesterTests] - Path Plop.ps1 Should Create a Test file' {

                #Arrange
                $File = "plop.ps1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                Write-CUPesterTests -Path $FullFile
                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty

            }

            It '[Write-CUPesterTests] - Path .\Plop.ps1 -PassThru Should Create a Test file and return [System.IO.FileInfo]' {

                #Arrange
                $File = "plop.ps1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                $Out = Write-CUPesterTests -Path $FullFile -PassThru

                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                $Out | Should not beNullOrEmpty
                $Out.GetType().FullName | Should be 'System.IO.FileInfo'

            }

        }

        Context "Testing -Path with '*.psm1'" {
            It '[Write-CUPesterTests] - Path Plop.psm1 Should not throw' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 
    
                $FullFile = Join-Path -Path $TestDrive -ChildPath $File
                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force
    
                #Assert
    
                {Write-CUPesterTests -Path $FullFile} | Should Not Throw
            }

            It '[Write-CUPesterTests] - Path Plop.psm1 Should Create a Test file' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                Write-CUPesterTests -Path $FullFile
                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty

            }

            It '[Write-CUPesterTests] - Path .\Plop.psm1 -PassThru Should Create a Test file and return [System.IO.FileInfo]' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                $Out = Write-CUPesterTests -Path $FullFile -PassThru

                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                $Out | Should not beNullOrEmpty
                $Out.GetType().FullName | Should be 'System.IO.FileInfo'

            }
        }


        Context "Testing -Path with 'Folder'" {

            It '[Write-CUPesterTests] - Path [System.IO.DirectoryInfo] Should not throw' {
    
                {Write-CUPesterTests -Path $TestDrive} | Should Not Throw
            }

            It '[Write-CUPesterTests] - Path [Folder] Should Create a Test file' {

                #Arrange
                $File = "plop.psm1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                Write-CUPesterTests -Path $TestDrive
                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty

            }

            It '[Write-CUPesterTests] - Path [Folder] -Passtru Should Create a Test file and return [System.IO.FileInfo]' {
                
                    Get-ChildItem -Path $TestDrive | Remove-Item -Force
                
                #Arrange
                $File = "plop.ps1"
                
                #Act 

                $FullFile = Join-Path -Path $TestDrive -ChildPath $File

                Out-file -InputObject $ClassTest -FilePath $FullFile -Encoding utf8 -Force

                $Out = Write-CUPesterTests -Path $TestDrive -PassThru

                #Assert

                Get-ChildItem -Path $TestDrive -Filter '*.Tests.ps1' | Should Not beNullOrEmpty
                $Out | Should not beNullOrEmpty
                $Out.GetType().FullName | Should be 'System.IO.FileInfo'

            }
        }



        
    }
}