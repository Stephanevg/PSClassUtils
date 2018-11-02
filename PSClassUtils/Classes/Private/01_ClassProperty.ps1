Class ClassProperty {
    [String]$ClassName
    [String]$Name
    [String]$Type
    [string]$Visibility
    Hidden $Raw

    ClassProperty([String]$ClassName,[String]$Name,[String]$Type){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type

    }

    ClassProperty([String]$ClassName,[String]$Name,[String]$Type,[String]$Visibility){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type
        $this.Visibility = $Visibility

    }

    ClassProperty([String]$ClassName,[String]$Name,[String]$Type,[String]$Visibility,$Raw){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type
        $this.Visibility = $Visibility
        $this.Raw = $Raw

    }
}