Class ClassConstructor {
    [String]$ClassName
    [String]$Name
    [String]$ReturnType
    [ClassParameter[]]$Parameter
    hidden $Raw

    ClassConstructor([String]$ClassName,[String]$Name,[String]$ReturnType,[ClassParameter[]]$Parameter){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Parameter = $Parameter
    }

    ClassConstructor([String]$ClassName,[String]$Name,[String]$ReturnType,[ClassParameter[]]$Parameter,$Raw){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Parameter = $Parameter
        $This.Raw = $Raw
    }

}