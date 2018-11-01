Import-Module -Force $PSScriptRoot\..\PSClassUtils\PSClassUtils.psm1

InModuleScope PSClassUtils -ScriptBlock {

    Describe "Testing Class-ClassProperty" {

        it '[Instantiation] should create an instance without throwing' {
            {[ClassProperty]::New("ClassName","String", "Value")} | should not throw
        }

        it '[Properties] Should have two Properties' {
            $Instance = [ClassProperty]::New("ClassName","String", "Value")
            ($Instance | gm | ? {$_.MemberType -eq "Property"} | measure).Count | should be 5
        }


        $Instance = [ClassProperty]::New("ClassName","String", "Value")
        $Values = @("Name", "Type")
        Foreach ($prop in $values) {
        
            it "[Properties][$($prop)] Should be present" {
                ($Instance | gm | ? {$_.MemberType -eq "Property" -and $_.Name -eq $prop}).Name | should be $prop
            
            }
        }
    }
}