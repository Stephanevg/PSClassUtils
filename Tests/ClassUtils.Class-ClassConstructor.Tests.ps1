#$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

Import-Module -Force $PSScriptRoot\..\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'ClassConstructor'" {

        Context "[ClassConstructor] Constructors and Instantiation" {

        
            it '[ClassConstructor][Instantiation] (Empty ClassProperty Array) should create an instance without throwing' {
                $Properties = [ClassProperty[]]@()
                {[ClassConstructor]::New("DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[ClassConstructor][Instantiation] (ClassProperty 1 element) should create an instance without throwing' {
                $Properties = [ClassProperty[]]@()
                $Properties += [ClassProperty]::New("PropName", "String")
                {[ClassConstructor]::New("DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[ClassConstructor][Instantiation] (ClassProperty 10 elements) should create an instance without throwing' {
                $Properties = [ClassProperty[]]@()
                for ($i = 0; $i++; $i -eq 10) {
                    $Properties += [ClassProperty]::New("Prop$1", "String")
                }
            
                {[ClassConstructor]::New("DoStuffPlease", "String", $Properties)} | should not throw
            }
        }
        Context "[ClassConstructor] Properties" {

        
            it '[ClassConstructor][Properties] Instance should have 3 Properties' {
            
                $Properties = [ClassProperty[]]@()
                $Instance = [ClassConstructor]::New("DoStuffPlease", "String", $Properties)
                ($Instance | gm | ? {$_.MemberType -eq "Property"} | measure).Count | should be 3
            }

            $Properties = [ClassProperty[]]@()
            $Properties += [ClassProperty]::New("PropName", "String")
            $Instance = [ClassConstructor]::New("DoStuffPlease", "String", $Properties)
            $Values = @("Name", "ReturnType", "Properties")
            Foreach ($prop in $values) {
        
                it "[ClassConstructor][Properties][$($prop)] Should be present on instance" {
                
                    ($Instance | gm | ? {$_.MemberType -eq "Property" -and $_.Name -eq $prop}).Name | should be $prop
            
                }
            }

        }
    }
}