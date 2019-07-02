Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class: 'ClassEnum'" {

        Context "[ClassEnum] Constructors and Instantiation" {

            $EnumName = "Woop"
            $EnumMembers = @("riri","fifi","pluplu")
            it '[ClassEnum][Instantiation] (One member) should create an instance without throwing' {
                
                {[ClassEnum]::New($EnumName, "plop")} | should not throw
            }

            it '[ClassEnum][Instantiation] (two members) should create an instance without throwing' {
                
                {[ClassEnum]::New($EnumName,$EnumMembers)} | should not throw
            }

            it '[ClassEnum][Instantiation]Should have correct properties values' {
                
                $enum = [ClassEnum]::New($EnumName,$EnumMembers)

                $Enum.Name | should be $EnumName

                Foreach($mem in $enum.Member){
                    $mem -in $EnumMembers | should be $true
                }

            } 
        }
    }
}

