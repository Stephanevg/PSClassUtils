Class CUClassConstructor {
    [String]$ClassName
    [String]$Name
    [CUClassParameter[]]$Parameter
    hidden $Raw
    #hidden $Extent

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
        #$This.Extent = $Raw.Extent.Text
    }

}