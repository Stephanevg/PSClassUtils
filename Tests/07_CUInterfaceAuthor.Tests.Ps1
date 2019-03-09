using module C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\PSClassUtils\PSClassUtils.psd1

InModuleScope -ModuleName PsClassUtils -ScriptBlock {

    Describe '[CUInterfaceAuthor]-[Constructors]' {

        It '[CUInterfaceAuthor]-[Constructor]([string]Name,[type]Interface) should Not Throw' {

            # -- Arrange


            [string]$Name = 'plop'


            [type]$Interface = 'System.Collections.IEqualityComparer'

            # -- Act

            # -- Assert

            {[CUInterfaceAuthor]::New($Name, $Interface)} | Should Not Throw 

        }# end of it block


    }# end of Describe block
    Describe '[CUInterfaceAuthor]-[Methods]' {

        #Public Method
        It '[CUInterfaceAuthor] --> GetPropertySection() : [string] - should Not Throw' {

            # -- Arrange
            [string]$Name = 'plop'


            [type]$Interface = 'System.Collections.IEqualityComparer'
            # -- Act

            $Instance = [CUInterfaceAuthor]::New($Name, $Interface)

            # -- Assert

            {$Instance.GetPropertySection()} | Should Not Throw

        } #End It Block

        #Public Method
        It '[CUInterfaceAuthor] --> GetPropertySection() : [string] - should return type [string]' {

            # -- Arrange

            [string]$Name = 'plop'


            [type]$Interface = 'System.Collections.IEqualityComparer'
            
            # -- Act

            $Instance = [CUInterfaceAuthor]::New($Name, $Interface)

            # -- Assert

            ($Instance.GetPropertySection()).GetType().Name | should be string

        } #End It Block

        #Public Method
        It '[CUInterfaceAuthor] --> GetMethodSection() : [string] - should Not Throw' {

            [string]$Name = 'plop'


            [type]$Interface = 'System.Collections.IEqualityComparer'
            
            # -- Act

            $Instance = [CUInterfaceAuthor]::New($Name, $Interface)
            

            # -- Assert

            {$Instance.GetMethodSection()} | Should Not Throw

        } #End It Block

        #Public Method
        It '[CUInterfaceAuthor] --> GetMethodSection() : [string] - should return type [string]' {

            [string]$Name = 'plop'


            [type]$Interface = 'System.Collections.IEqualityComparer'
            
            # -- Act

            $Instance = [CUInterfaceAuthor]::New($Name, $Interface)
            
            # -- Assert

            ($Instance.GetMethodSection()).GetType().Name | should be string

        } #End It Block

    }#EndDescribeBlock

}#End InModuleScope


