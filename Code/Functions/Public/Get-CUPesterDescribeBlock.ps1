Function Get-CUPesterDescribeBlock {
    [CmdletBinding()]
    Param(
        $Path,
        $InputObject
    )
    if($Path){
        $P = Get-Item -path $Path
        $Raw = [System.Management.Automation.Language.Parser]::ParseFile($p.FullName, [ref]$null, [ref]$Null)

    }elseif($InputObject){
        $Raw = [System.Management.Automation.Language.Parser]::ParseInput($InputObject,[ref]$null, [ref]$Null)
    }
    $String = $Raw.FindAll( {$args[0] -is [System.Management.Automation.Language.StringConstantExpressionAst]}, $true)
    $Data = @()
    $Data += $String | ? {$_.StringConstantType -eq "BareWord" -and $_.Value -eq 'Describe'}
    $AllDescribeBlocks = @()
    Foreach($d in $data){

        $Hash = @{}
        $Hash.ElementType = $d.Value
        $Hash.ItBlocks = @()
        $Hash.Tags = ""
        $Hash.ItBlocks += Get-CUPesterITBlock -InputObject $d.Parent.Extent.Text
        $Hash.Content = $d.Parent.Extent.Text
       
        $Obj = [PesterDescribeBlock]::New($Hash.Name,$Hash.ItBlocks,[PesterType]::Describe,$Hash.Content,[String[]]$Tags)
        
            $Pattern = '^.*-tag(?<Tags>.*$)'
            $Options = @()
            $Options += [System.Text.RegularExpressions.RegexOptions]::Multiline
            $Options += [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
            $rgx = [regex]::New($Pattern,$Options)
            $MyMatches = $rgx.Match($d.Parent.Extent.Text)
            $Hash.Tags = $MyMatches.Groups['Tags'].Value
        $Obj.Tags = $Hash.Tags

        $AllDescribeBlocks += $Obj
    }

    Return $AllDescribeBlocks
}