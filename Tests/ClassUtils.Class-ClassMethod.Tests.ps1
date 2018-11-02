Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'ClassMethod'" {

        Context "[ClassMethod] Constructors and Instantiation" {

        
            it '[ClassMethod][Instantiation] (Empty ClassProperty Array) should create an instance without throwing' {
                $Properties = [ClassParameter[]]@()
                {[ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[ClassMethod][Instantiation] (ClassProperty 1 element) should create an instance without throwing' {
                $Properties = [ClassParameter[]]@()
                $Properties += [ClassParameter]::New("PropName", "String")
                {[ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[ClassMethod][Instantiation] (ClassProperty 10 elements) should create an instance without throwing' {
                $Properties = [ClassParameter[]]@()
                for ($i = 0; $i++; $i -eq 10) {
                    $Properties += [ClassParameter]::New("Prop$1", "String")
                }
            
                {[ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }
        }
        Context "[ClassMethod] Properties" {

        
            it '[ClassMethod][Properties] Instance should have 3 Properties' {
            
                $Properties = [ClassParameter[]]@()
                $Instance = [ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)
                ($Instance | gm | ? {$_.MemberType -eq "Property"} | measure).Count | should be 4
            }

            $Properties = [ClassParameter[]]@()
            $Properties += [ClassParameter]::New("PropName", "String")
            $Instance = [ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)
            $Values = @("Name", "Type")
            Foreach ($prop in $values) {
        
                it "[ClassMethod][Properties][$($prop)] Should be present on instance" {
                
                    ($Instance.Parameter | gm | ? {$_.MemberType -eq "Property" -and $_.Name -eq $prop}).Name | should be $prop
            
                }
            }

        }
    }
}