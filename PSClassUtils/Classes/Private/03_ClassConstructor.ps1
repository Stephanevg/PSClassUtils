Class ClassConstructor {
    [String]$Name
    [String]$ReturnType
    [ClassProperty[]]$Properties
    hidden $Raw

    ClassConstructor([String]$Name,[String]$ReturnType,[ClassProperty[]]$Properties){
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Properties = $Properties
    }

    ClassConstructor([String]$Name,[String]$ReturnType,[ClassProperty[]]$Properties,$Raw){
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Properties = $Properties
        $This.Raw = $Raw
    }

}