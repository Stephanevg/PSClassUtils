Class CUClassConstructor {
    [String]$ClassName
    [String]$Name
    [CUClassParameter[]]$Parameter
    hidden $Raw

    CUClassConstructor([String]$ClassName,[String]$Name,[CUClassParameter[]]$Parameter){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.Parameter = $Parameter
    }

    CUClassConstructor([String]$ClassName,[String]$Name,[CUClassParameter[]]$Parameter,$Raw){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.Parameter = $Parameter
        $This.Raw = $Raw
    }

}