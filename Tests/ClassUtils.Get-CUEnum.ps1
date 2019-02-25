Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Get-CUEnum"{
        Context "Basics"{
            It "ParameterLess should throw"{

                {Get-CUEnum} | Should throw
            }

$TestEnum = @"

Enum Woop {
    wap
    wep
    wet
}

"@

    $EnumPath = Join-Path $TestDrive -ChildPath "Woop.ps1"
    Out-File -FilePath $EnumPath -InputObject $TestEnum
            It "Parameter -Path Should not throw"{

                {Get-CUEnum -Path $EnumPath} | Should Not Throw
            }

            $en = Get-CUEnum -Path $EnumPath
            It "Parameter -Path Should Have correct Name"{

                
                $En.Name | Should be 'Woop' 
            }

            It "Parameter -Path Should Have correct Members"{

                $memb = @("wap","wep","wet")
                Foreach($m in $memb){

                    $En.Member | Should -Contain $m
                }
            }
        }
    }

}