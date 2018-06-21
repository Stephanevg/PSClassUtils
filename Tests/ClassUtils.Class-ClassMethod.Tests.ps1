Import-module "..\.\PowershellClassUtils.psm1" -Force

InModuleScope PowershellClassUtils -ScriptBlock {

    Describe "Testing Class: 'ClassMethod'" {

        Context "[ClassMethod] Constructors and Instantiation" {

        
            it '[ClassMethod][Instantiation] (Empty ClassProperty Array) should create an instance without throwing' {
                $Properties = [ClassProperty[]]@()
                {[ClassMethod]::New("DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[ClassMethod][Instantiation] (ClassProperty 1 element) should create an instance without throwing' {
                $Properties = [ClassProperty[]]@()
                $Properties += [ClassProperty]::New("PropName", "String")
                {[ClassMethod]::New("DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[ClassMethod][Instantiation] (ClassProperty 10 elements) should create an instance without throwing' {
                $Properties = [ClassProperty[]]@()
                for ($i = 0; $i++; $i -eq 10) {
                    $Properties += [ClassProperty]::New("Prop$1", "String")
                }
            
                {[ClassMethod]::New("DoStuffPlease", "String", $Properties)} | should not throw
            }
        }
        Context "[ClassMethod] Properties" {

        
            it '[ClassMethod][Properties] Instance should have 3 Properties' {
            
                $Properties = [ClassProperty[]]@()
                $Instance = [ClassMethod]::New("DoStuffPlease", "String", $Properties)
                ($Instance | gm | ? {$_.MemberType -eq "Property"} | measure).Count | should be 3
            }

            $Properties = [ClassProperty[]]@()
            $Properties += [ClassProperty]::New("PropName", "String")
            $Instance = [ClassMethod]::New("DoStuffPlease", "String", $Properties)
            $Values = @("Name", "ReturnType", "Properties")
            Foreach ($prop in $values) {
        
                it "[ClassMethod][Properties][$($prop)] Should be present on instance" {
                
                    ($Instance | gm | ? {$_.MemberType -eq "Property" -and $_.Name -eq $prop}).Name | should be $prop
            
                }
            }

        }
    }
}