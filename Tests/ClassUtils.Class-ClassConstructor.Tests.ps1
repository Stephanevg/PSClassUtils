#$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'CUClassConstructor'" {

        Context "[CUClassConstructor] Constructors and Instantiation" {

        
            it '[CUClassConstructor][Instantiation] (Empty CUClassParameter Array) should create an instance without throwing' {
                $Parameter = [CUClassParameter[]]@()
                {[CUClassConstructor]::New("DoStuffPlease", "String", $Parameter)} | should not throw
            }

            it '[CUClassConstructor][Instantiation] (CUClassParameter 1 element) should create an instance without throwing' {
                $Parameter = [CUClassParameter[]]@()
                $Parameter += [CUClassParameter]::New("classname","PropName", "String")
                {[CUClassConstructor]::New("DoStuffPlease", "String", $Parameter)} | should not throw
            }

            it '[CUClassConstructor][Instantiation] (CUClassParameter 10 elements) should create an instance without throwing' {
                $Parameter = [CUClassParameter[]]@()
                for ($i = 0; $i++; $i -eq 10) {
                    $Parameter += [CUClassParameter]::New("ClassName","Prop$1", "String")
                }
            
                {[CUClassConstructor]::New("DoStuffPlease", "String", $Parameter)} | should not throw
            }
        }
        Context "[CUClassConstructor] Parameter" {

        
            it '[CUClassConstructor][Parameter] Instance should have 3 Parameter' {
            
                $Parameter = [CUClassParameter[]]@()
                $Instance = [CUClassConstructor]::New("DoStuffPlease", "String", $Parameter)
                ($Instance | gm | ? {$_.MemberType -eq "Property"} | measure).Count | should be 3
            }

            $Parameter = [CUClassParameter[]]@()
            $Parameter += [CUClassParameter]::New("PropName", "String")
            $Instance = [CUClassConstructor]::New("DoStuffPlease", "String", $Parameter)
            $Values = @("Name", "Type")
            #Write-Host ($Instance | gm | ? {$_.MemberType -eq "Property"})
            Foreach ($prop in $values) {
        
                it "[CUClassConstructor][Parameter][$($prop)] Should be present on instance" {
                
                    ($Instance.Parameter | gm | ? {$_.MemberType -eq "Property" -and $_.Name -eq $prop}).Name | should be $prop
            
                }
            }

        }
    }
}