Class ClassMethod {
    [String]$ClassName
    [String]$Name
    [String]$ReturnType
    [ClassParameter[]]$Parameter
    hidden $Raw

    ClassMethod([String]$ClassName,[String]$Name,[String]$ReturnType,[ClassParameter[]]$Parameter){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Parameter = $Parameter
    }

    ClassMethod([String]$ClassName,[String]$Name,[String]$ReturnType,[ClassParameter[]]$Parameter,$Raw){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Parameter = $Parameter
        $This.Raw
    }

}