Class CUClassParameter {
    [String]$Name
    [String]$Type
    hidden $Raw

    CUClassParameter([String]$Name,[String]$Type){

        $this.Name = $Name
        $This.Type = $Type

    }

    CUClassParameter([String]$Name,[String]$Type,$Raw){

        $this.Name = $Name
        $This.Type = $Type
        $this.Raw = $Raw

    }
}