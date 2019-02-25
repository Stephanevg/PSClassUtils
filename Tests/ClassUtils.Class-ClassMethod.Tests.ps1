Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'CUClassMethod'" {

        Context "[CUClassMethod] Constructors and Instantiation" {

        
            it '[CUClassMethod][Instantiation] (Empty CUClassMethod Array) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                {[CUClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[CUClassMethod][Instantiation] (CUClassMethod 1 element) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                $Properties += [CUClassParameter]::New("PropName", "String")
                {[CUClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }

            it '[CUClassMethod][Instantiation] (CUClassMethod 10 elements) should create an instance without throwing' {
                $Properties = [CUClassParameter[]]@()
                for ($i = 0; $i++; $i -eq 10) {
                    $Properties += [CUClassParameter]::New("Prop$1", "String")
                }
            
                {[CUClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)} | should not throw
            }
        }
        Context "[CUClassMethod] Properties" {


            $Properties = [CUClassParameter[]]@()
            $Properties += [CUClassParameter]::New("PropName", "String")
            $Instance = [CUClassMethod]::New("ClassName","DoStuffPlease", "String", $Properties)
            $Values = @("Name", "Type")
            Foreach ($prop in $values) {
        
                it "[CUClassMethod][Properties][$($prop)] Should be present on instance" {
                
                    ($Instance.Parameter | gm | ? {$_.MemberType -eq "Property" -and $_.Name -eq $prop}).Name | should be $prop
            
                }
            }

        }
    }
}