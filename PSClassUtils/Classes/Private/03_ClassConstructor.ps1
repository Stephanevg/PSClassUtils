Class ClassConstructor {
    [String]$ClassName
    [String]$Name
    [ClassParameter[]]$Parameter
    hidden $Raw

    ClassConstructor([String]$ClassName,[String]$Name,[ClassParameter[]]$Parameter){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.Parameter = $Parameter
    }

    ClassConstructor([String]$ClassName,[String]$Name,[ClassParameter[]]$Parameter,$Raw){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.Parameter = $Parameter
        $This.Raw = $Raw
    }

}