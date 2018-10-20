Class ClassParameter {
    [String]$Name
    [String]$Type
    hidden $Raw

    ClassProperty([String]$Name,[String]$Type){

        $this.Name = $Name
        $This.Type = $Type

    }

    ClassProperty([String]$Name,[String]$Type,$Raw){

        $this.Name = $Name
        $This.Type = $Type
        $this.Raw = $Raw

    }
}