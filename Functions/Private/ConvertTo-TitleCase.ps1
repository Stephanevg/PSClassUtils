Function ConvertTo-titleCase {
    [CmdletBinding()]
    Param(
        [String]$String
    )

    $TextInfo = (Get-Culture).TextInfo
    return $TextInfo.ToTitleCase($string)
}