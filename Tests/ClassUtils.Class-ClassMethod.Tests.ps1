Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'ClassMethod'" {

        Context "[ClassMethod] Constructors and Instantiation" {

        
            it '[ClassMethod][Instantiation] (Empty CUClassProperty Array) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                {[ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[ClassMethod][Instantiation] (CUClassProperty 1 element) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                $Properties += [CUClassParameter]::New("PropName", "String")
                {[ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[ClassMethod][Instantiation] (CUClassProperty 10 elements) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                for ($i = 0; $i++; $i -eq 10) {
                    $Properties += [CUClassParameter]::New("Prop$1", "String")
                }
            
                {[ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }
        }
        Context "[ClassMethod] Properties" {

        
            it '[ClassMethod][Properties] Instance should have 3 Properties' {
            
                $Properties = [CUClassParameter[]]@()
                $Instance = [ClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)
                ($Instance | gm | ? {$_.MemberType -eq "Property"} | measure).Count | should be 4
            }

            $Properties = [CUClassParameter[]]@()
            $Properties += [CUClassParameter]::New("PropName", "String")
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