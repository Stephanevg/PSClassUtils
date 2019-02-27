
Enum PesterType {
    It
    Describe
    Context
}
Class PesterItBlock{
    [String]$Name
    [String]$Value
    [PesterType]$Type
    [String]$Content
    [HashTable]$TestCases
    [Bool]$Pending = $false
    [Bool]$Skipped = $False

    PesterITBlock([String]$Name,[String]$Value,[PesterType]$Type,[String]$Content,[HashTable]$TestCases){
        $this.Name = $Name
        $this.Value = $Value
        $this.Type = $Type
        $this.Content = $Content
        $This.TestCases = $TestCases
    }

    SetPending([Bool]$IsPending){
        $this.Pending = $IsPending
    }

    [Bool] IsPending(){
        return $This.Pending
    }

    SetSkipped([Bool]$IsSkipped){
        $this.Pending = $IsSkipped
    }

    [Bool] IsSkipped(){
        return $This.Skipped
    }

}
Class PesterDescribeBlock {
    [String]$Name
    [PesterItBlock[]]$ItBlocks
    [PesterType]$Type
    [String]$Fixture
    [String[]]$Tags

    PesterDescribeBlock([String]$Name,[PesterItBlock[]]$ItBlocks,[PesterType]$Type,[String]$Fixture,[String[]]$Tags){
        $this.Name = $Name
        $this.ItBlocks = $ItBlocks
        $this.Type = $Type
        $this.Fixture = $Fixture
        $This.Tags = $Tags
    }
}

Class PesterScript {
    [System.IO.FileInfo]$path
    [PesterDescribeBlock[]]$DescribeBlocks

    PesterScript([System.Io.FileInfo]$Path){
        $this.Path = $Path
        $This.DescribeBlocks = Get-CUPesterDescribeBlock -Path $This.path.FullName
    }
}
