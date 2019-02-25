Class CUClassMethod {
    [String]$ClassName
    [String]$Name
    [String]$ReturnType
    [CUClassParameter[]]$Parameter
    hidden $Raw
    [Bool]$Static
    

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
        
    }

    SetIsStatic([Bool]$IsStatic){
        $this.Static = $IsStatic
    }

    [Bool] IsStatic(){
        return $this.Static
    }

}