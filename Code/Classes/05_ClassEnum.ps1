Class ClassEnum {

    [String]$Name
    [String[]]$Member

    ClassEnum([String]$Name,[String[]]$Member){
        $this.Name = $Name
        $this.Member = $Member
    }
}
