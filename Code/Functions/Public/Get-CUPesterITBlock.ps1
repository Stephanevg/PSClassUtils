Function Get-CUPesterITBlock {
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
    $Data += $String | ? {$_.StringConstantType -eq "BareWord" -and $_.Value -eq 'it'}

    Foreach($d in $data){

        $Hash = @{value='';content=''}
        $Hash.ElementType = $d.Value
        $Hash.Content = $d.Parent.Extent.Text
        $Hash.Name = $d.Parent.commandElements.Value[1]
        $Hash.Value =  $d.Parent.CommandElements.Scriptblock.Extent
        $Hash.TestCases =  $d.Parent.Parent.PipelineElements.CommandElements[-1].Elements


        $AllItBlocks = @()
        $Obj = [PesterItBlock]::New($Hash.Name,$Hash.Value,[PesterType]::It,$Hash.Content,$Hash.TestCases)
        $AllItBlocks += $Obj
    }

    return $AllItBlocks
}