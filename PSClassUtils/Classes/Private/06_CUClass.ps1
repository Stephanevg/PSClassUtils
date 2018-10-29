Class CUClass {
    [String]$Name
    [ClassProperty[]]$Property
    [ClassConstructor[]]$Constructor
    [ClassMethod[]]$Method
    Hidden $Raw

    CUClass($RawAST){
        $this.Raw = $RawAST
        $This.SetPropertiesFromRawAST($this.Raw)
    }

    CUClass ($Name,$Property,$Constructor,$Method){
        $This.Name = $Name
        $This.Property = $Property
        $This.Constructor = $Constructor
        $This.Method = $Method
    }
    CUClass ($Name,$Property,$Constructor,$Method,$RawAST){
        $This.Name = $Name
        $This.Property = $Property
        $This.Constructor = $Constructor
        $This.Method = $Method
        $This.Raw = $RawAST
    }

    [void] SetPropertiesFromRawAST($RawAST){
        $this.Name = $RawAST.Name
        $this.Constructor = Get-CUClassConstructor -ClassName $this.Name -InputObject $RawAST
        $this.Method = Get-CUClassMethod -InputObject $RawAST -ClassName $this.Name
        $this.Property = Get-CUClassProperty -InputObject $RawAST -ClassName $this.Name
    }
}