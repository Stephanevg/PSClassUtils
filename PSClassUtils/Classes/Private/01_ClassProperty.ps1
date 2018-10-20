Class ClassProperty {
    [String]$Name
    [String]$Type
    [string]$Visibility = ""
    $Raw

    ClassProperty([String]$Name,[String]$Type){

        $this.Name = $Name
        $This.Type = $Type

    }

    ClassProperty([String]$Name,[String]$Type,[String]$Visibility){

        $this.Name = $Name
        $This.Type = $Type
        $this.Visibility = $Visibility

    }

    ClassProperty([String]$Name,[String]$Type,[String]$Visibility,$Raw){

        $this.Name = $Name
        $This.Type = $Type
        $this.Visibility = $Visibility
        $This.Raw = $Raw

    }
}