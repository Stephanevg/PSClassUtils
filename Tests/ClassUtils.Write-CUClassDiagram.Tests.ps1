$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\utilities.Tattoo.psm1"
Import-Module -Force $PSScriptRoot\..\PSClassUtils.psm1

Describe "Testing Write-CUClassDiagram" {

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

InModuleScope "PSClassUtils" {
    $ClassScript = Join-Path -Path $Testdrive -ChildPath "WoopClass.ps1"
    $TestCaseClass | Out-File -FilePath $ClassScript -Force


        it 'Parameter: -Path (file): Should return Object of type [FileInfo]' {
            $ret = Write-CUClassDiagram -Path $ClassScript
            $ret.GetType().Name | should be 'FileInfo'
        }

        it 'Parameter: -Path (file): Should Create a graph in same folder' {
            $ret = Write-CUClassDiagram -Path $ClassScript
            $Ret.DirectoryName | should be $Testdrive.FullName
        }
        
        it "Parameter: Path (folder): Should create graph from classes located in seperate files in a specific folder" {
            $FolderPathFolder = Join-Path -Path $Testdrive -ChildPath "FolderPath"
            $null = mkdir $FolderPathFolder
            $Path_File1 = Join-Path -Path $FolderPathFolder -ChildPath "woop.ps1"
            $File1 | Out-File -FilePath $Path_File1 -Force

            $Path_File2 = Join-Path -Path $FolderPathFolder -ChildPath "wap.ps1"
            $File2 | Out-File -FilePath $Path_File2 -Force

            $Path_File3 = Join-Path -Path $FolderPathFolder -ChildPath "wep.ps1"
            $File3 | Out-File -FilePath $Path_File3 -Force

            $b = Write-CUClassDiagram -Path $FolderPathFolder -PassThru
            $b -cmatch '"Woop" \[label=.*' | should Not beNullOrEmpty
            $b -cmatch '"Woop"->"Wap"' | should match '"Woop"->"Wap"'
            $b -cmatch '"Woop"->"Wep"' | should match '"Woop"->"Wep"'

        }

        it "Parameter: -ExportPath 'Should throw if file name is added.'" {
            $Guid = [Guid]::NewGuid().Guid + ".txt"
            $File = Join-Path -Path $Testdrive -ChildPath $Guid
            
            {Write-CUClassDiagram -Path $ClassScript -ExportFolder $File} | should throw
            
        }

        it "Parameter: -ExportPath: 'Should throw if folder does not exist'" {
            $Guid = [Guid]::NewGuid().Guid
            $NewFolder = Join-Path -Path $Testdrive -ChildPath $Guid
            $null = mkdir $NewFolder
            $ret = Write-CUClassDiagram -Path $ClassScript -ExportFolder $NewFolder
            $Ret.DirectoryName | should be $NewFolder
        }

        it "Parameter: -ExportPath: 'Should Create a graph in Other folder'" {
            $Guid = [Guid]::NewGuid().Guid
            $NewFolder = Join-Path -Path $Testdrive -ChildPath $Guid
            $null = mkdir $NewFolder
            $ret = Write-CUClassDiagram -Path $ClassScript -ExportFolder $NewFolder
            $Ret.DirectoryName | should be $NewFolder
        }

        it 'Parameter: -OutputFormat: Should Create a graph in Other format' {
            $ret = Write-CUClassDiagram -Path $ClassScript -OutputFormat gif
            $ret.extension | should be ".gif"
        }

        

        it 'Parameter: -Passthru: Should return psgraph object' {
            $ret = Write-CUClassDiagram -Path $ClassScript -PassThru
            $ret.GetType().Name | should not be "FileInfo"
            $ret[0] | should be 'digraph g {'
        }


        

    $TestCaseSensitityClass = @'
    
        Class WooP {
            [String]$String
            [int]$number
        
            Woop([String]$String,[int]$Number){
        
            }
        
            [String]DoSomething(){
                return $this.String
            }
        }
        
        Class Wap : wOOp {
            [String]$prop3
        
            DoChildthing(){}
        
        }
        
        Class Wep : WoOp {
            [String]$prop4
        
            DoOtherChildThing(){
        
            }
        }
        
'@      

        it 'Parameter: -IgnoreCase: Should create correct graph ignoring case' {
            $ClassScriptCaseSensitive = Join-Path -Path $Testdrive -ChildPath "WoopClassCase.ps1"
            $TestCaseSensitityClass | Out-File -FilePath $ClassScriptCaseSensitive -Force
            $a = Write-CUClassDiagram -Path $ClassScriptCaseSensitive -PassThru -IgnoreCase
            $a -cmatch '"Woop" \[label=.*' | should not benullOrEmpty
            $a -cmatch '"Woop"->"Wap"' | should match '"Woop"->"Wap"'
            $a -cmatch '"Woop"->"Wep"' | should match '"Woop"->"Wep"'
            $a -cmatch 'wOOp' | should beNullOrEmpty
            $a -cmatch 'WoOp' | should beNullOrEmpty
            $a -cmatch 'WooP' | should beNullOrEmpty
        }

        $File1 = @'
    
        Class Woop {
            [String]$String
            [int]$number
        
            Woop([String]$String,[int]$Number){
        
            }
        
            [String]DoSomething(){
                return $this.String
            }
        }
'@
    
    $File2 = @'
        Class Wap : Woop {
            [String]$prop3
        
            DoChildthing(){}
        
        }
'@
    $File3 = @'
        Class Wep : Woop {
            [String]$prop4
        
            DoOtherChildThing(){
        
            }
        }
        
'@
        
        #It is best to keep this test at the end, and it will unload the module PSGraph, and can cause some issues while testing.
        it 'Should throw if psgraph module is not found' {
            if(get-Module psgraph){

                remove-module psgraph
            }

            Mock get-module -MockWith {
                return $null
            }

            {Write-CUClassDiagram -Path $ClassScript } | should throw
            Assert-MockCalled get-module
        }

    }

}
