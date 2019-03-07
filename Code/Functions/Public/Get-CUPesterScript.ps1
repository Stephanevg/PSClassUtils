Function Get-CUPesterScript {
    [CmdletBinding()]
    Param(
        [System.IO.FileInfo]$path
    )
    $Hash = @{}
    $Hash.Path = $Path.FullName
    $Hash.Data = Get-CUPesterDescribeBlock -Path $path.FullName

    $obj = [PesterScript]::New($Path)
    return $obj
}