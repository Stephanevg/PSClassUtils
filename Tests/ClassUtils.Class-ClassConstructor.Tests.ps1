#$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'ClassConstructor'" {

        Context "[ClassConstructor] Constructors and Instantiation" {

        
            it '[ClassConstructor][Instantiation] (Empty CUClassParameter Array) should create an instance without throwing' {
                $Parameter = [CUClassParameter[]]@()
                {[ClassConstructor]::New("DoStuffPlease", "String", $Parameter)} | should not throw
            }

            it '[ClassConstructor][Instantiation] (CUClassParameter 1 element) should create an instance without throwing' {
                $Parameter = [CUClassParameter[]]@()
                $Parameter += [CUClassParameter]::New("classname","PropName", "String")
                {[ClassConstructor]::New("DoStuffPlease", "String", $Parameter)} | should not throw
            }

            it '[ClassConstructor][Instantiation] (CUClassParameter 10 elements) should create an instance without throwing' {
                $Parameter = [CUClassParameter[]]@()
                for ($i = 0; $i++; $i -eq 10) {
                    $Parameter += [CUClassParameter]::New("ClassName","Prop$1", "String")
                }
            
                {[ClassConstructor]::New("DoStuffPlease", "String", $Parameter)} | should not throw
            }
        }
        Context "[ClassConstructor] Parameter" {

        
            it '[ClassConstructor][Parameter] Instance should have 3 Parameter' {
            
                $Parameter = [CUClassParameter[]]@()
                $Instance = [ClassConstructor]::New("DoStuffPlease", "String", $Parameter)
                ($Instance | gm | ? {$_.MemberType -eq "Property"} | measure).Count | should be 3
            }

            $Parameter = [CUClassParameter[]]@()
            $Parameter += [CUClassParameter]::New("PropName", "String")
            $Instance = [ClassConstructor]::New("DoStuffPlease", "String", $Parameter)
            $Values = @("Name", "Type")
            #Write-Host ($Instance | gm | ? {$_.MemberType -eq "Property"})
            Foreach ($prop in $values) {
        
                it "[ClassConstructor][Parameter][$($prop)] Should be present on instance" {
                
                    ($Instance.Parameter | gm | ? {$_.MemberType -eq "Property" -and $_.Name -eq $prop}).Name | should be $prop
            
                }
            }

        }
    }
}