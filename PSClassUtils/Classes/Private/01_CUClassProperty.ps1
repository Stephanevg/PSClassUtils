Class CUClassProperty {
    [String]$ClassName
    [String]$Name
    [String]$Type
    [string]$Visibility
    Hidden $Raw

    CUClassProperty([String]$ClassName,[String]$Name,[String]$Type){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type

    }

    CUClassProperty([String]$ClassName,[String]$Name,[String]$Type,[String]$Visibility){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type
        $this.Visibility = $Visibility

    }

    CUClassProperty([String]$ClassName,[String]$Name,[String]$Type,[String]$Visibility,$Raw){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type
        $this.Visibility = $Visibility
        $this.Raw = $Raw

    }
}