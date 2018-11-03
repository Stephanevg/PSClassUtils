Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'CUClassProperty'" {

        Context "[CUClassProperty] Constructors and Instantiation" {

        
            it '[CUClassProperty][Instantiation] (Empty CUClassProperty Array) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                {[CUClassProperty]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[CUClassProperty][Instantiation] (CUClassProperty 1 element) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                $Properties += [CUClassParameter]::New("PropName", "String")
                {[CUClassProperty]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[CUClassProperty][Instantiation] (CUClassProperty 10 elements) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                for ($i = 0; $i++; $i -eq 10) {
                    $Properties += [CUClassParameter]::New("Prop$1", "String")
                }
            
                {[CUClassProperty]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }
        }
        Context "[CUClassProperty] Properties" {

        
            it '[CUClassProperty][Properties] Instance should have 3 Properties' {
            
                $Properties = [CUClassParameter[]]@()
                $Instance = [CUClassProperty]::New("ClassName","DoStuffPlease", "String", $Properties)
                ($Instance | gm | ? {$_.MemberType -eq "Property"} | measure).Count | should be 4
            }

            $Properties = [CUClassParameter[]]@()
            $Properties += [CUClassParameter]::New("PropName", "String")
            $Instance = [CUClassProperty]::New("ClassName","DoStuffPlease", "String", $Properties)
            $Values = @("Name", "Type")
            Foreach ($prop in $values) {
        
                it "[CUClassProperty][Properties][$($prop)] Should be present on instance" {
                
                    ($Instance.Parameter | gm | ? {$_.MemberType -eq "Property" -and $_.Name -eq $prop}).Name | should be $prop
            
                }
            }

        }
    }
}