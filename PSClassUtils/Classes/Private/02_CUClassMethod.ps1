Class CUClassMethod {
    [String]$ClassName
    [String]$Name
    [String]$ReturnType
    [CUClassParameter[]]$Parameter
    hidden $Raw
    #hidden $Extent

    CUClassMethod([String]$ClassName,[String]$Name,[String]$ReturnType,[CUClassParameter[]]$Parameter){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Parameter = $Parameter
    }

    CUClassMethod([String]$ClassName,[String]$Name,[String]$ReturnType,[CUClassParameter[]]$Parameter,$Raw){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Parameter = $Parameter
        $This.Raw = $Raw
        #$This.Extent = $Raw.Extent.Text
    }

}