Class ClassParameter {
    [String]$Name
    [String]$Type
    hidden $Raw

    ClassParameter([String]$Name,[String]$Type){

        $this.Name = $Name
        $This.Type = $Type

    }

    ClassParameter([String]$Name,[String]$Type,$Raw){

        $this.Name = $Name
        $This.Type = $Type
        $this.Raw = $Raw

    }
}