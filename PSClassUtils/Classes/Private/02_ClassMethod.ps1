Class ClassMethod {
    [String]$Name
    [String]$ReturnType
    [ClassProperty[]]$Properties
    hidden $Raw

    ClassMethod([String]$Name,[String]$ReturnType,[ClassProperty[]]$Properties){
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Properties = $Properties
    }

    ClassMethod([String]$Name,[String]$ReturnType,[ClassProperty[]]$Properties,$Raw){
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Properties = $Properties
        $This.Raw
    }

}