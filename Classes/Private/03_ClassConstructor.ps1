Class ClassConstructor {
    [String]$Name
    [String]$ReturnType
    [ClassProperty[]]$Properties

    ClassConstructor([String]$Name,[String]$ReturnType,[ClassProperty[]]$Properties){
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Properties = $Properties
    }

}