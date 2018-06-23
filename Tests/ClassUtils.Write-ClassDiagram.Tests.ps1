$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\utilities.Tattoo.psm1"
Import-module "..\.\PowershellClassUtils.psm1" -Force

Describe "Testing Write-ClassDiagram" {

$TestCaseClass = @"
    
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
    
"@

InModuleScope "PowershellClassUtils" {
$ClassScript = Join-Path -Path $Testdrive -ChildPath "WoopClass.ps1"
 $TestCaseClass | Out-File -FilePath $ClassScript -Force


        it 'Parameter: -Path: Should return Object of type [FileInfo]' {
            $ret = Write-ClassDiagram -Path $ClassScript
            $ret.GetType().Name | should be 'FileInfo'
        }

        it 'Parameter: -Path: Should Create a graph in same folder' {
            $ret = Write-ClassDiagram -Path $ClassScript
            $Ret.DirectoryName | should be $Testdrive.FullName
        }

        it "Parameter: -ExportPath 'Should throw if file name is added.'" {
            $Guid = [Guid]::NewGuid().Guid + ".txt"
            $File = Join-Path -Path $Testdrive -ChildPath $Guid
            #$null = mkdir $NewFolder
            {Write-ClassDiagram -Path $ClassScript -ExportFolder $File} | should throw
            
        }

        it "Parameter: -ExportPath: 'Should throw if folder does not exist'" {
            $Guid = [Guid]::NewGuid().Guid
            $NewFolder = Join-Path -Path $Testdrive -ChildPath $Guid
            $null = mkdir $NewFolder
            $ret = Write-ClassDiagram -Path $ClassScript -ExportFolder $NewFolder
            $Ret.DirectoryName | should be $NewFolder
        }

        it "Parameter: -ExportPath: 'Should Create a graph in Other folder'" {
            $Guid = [Guid]::NewGuid().Guid
            $NewFolder = Join-Path -Path $Testdrive -ChildPath $Guid
            $null = mkdir $NewFolder
            $ret = Write-ClassDiagram -Path $ClassScript -ExportFolder $NewFolder
            $Ret.DirectoryName | should be $NewFolder
        }

        it 'Parameter: -OutputFormat: Should Create a graph in Other format' {
            $ret = Write-ClassDiagram -Path $ClassScript -OutputFormat gif
            $ret.extension | should be ".gif"
        }

        

        it 'Parameter: -Passthru: Should return psgraph object' {
            $ret = Write-ClassDiagram -Path $ClassScript -PassThru
            $ret.GetType().Name | should not be "FileInfo"
            $ret[0] | should be 'digraph g {'
        }


        it 'Should throw if psgraph module is not found' {
            if(get-Module psgraph){

                remove-module psgraph
            }

            Mock get-module -MockWith {
                return $null
            }

            {Write-ClassDiagram -Path $ClassScript } | should throw
            Assert-MockCalled get-module
        }

    }

}