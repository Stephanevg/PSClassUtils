Class ClassMethod {
    [String]$Name
    [String]$ReturnType
    [ClassProperty[]]$Properties

    ClassMethod([String]$Name,[String]$ReturnType,[ClassProperty[]]$Properties){
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Properties = $Properties
    }

}