Function Write-CUClassDiagram {
    <#
    .SYNOPSIS
        This script allows to document automatically existing script(s)/module(s) containing classes by generating the corresponding UML Diagram.
    .DESCRIPTION
        Automatically generate a UML diagram of scripts/Modules that contain powershell classes.

    .PARAMETER Path

    The path that contains the classes that need to be documented. 
    The path parameter should point to either a .ps1, .psm1 file, or a directory containing either/both of those file types.

    .PARAMETER FolderPath

    This parameter is deprecated, and will be removed in a future version. Please use -Path instead

    .PARAMETER ExportFolder

    This optional parameter, allows to specifiy an alternative export folder. By default, the diagram is created in the same folder as the source file.

    .PARAMETER OutputFormat

        Using the parameter OutputFormat, it is possible change the default output format (.png) to one of the following ones:

        'jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot'

    .PARAMETER Show

    Open's the generated diagram immediatly

    .PARAMETER IgnoreCase
        By default, Class names MUST be case identical to have the Write-CUClassDiagram cmdlet generate the correct inheritence tree.
        When the switch -IgnoreCase is specified, All class names will be converted to 'Titlecase' to force the case, and ensure the inheritence is correctly drawed in the Class Diagram.
    
    .PARAMETER PassThru
        When specified, the raw Graph inn GraphViz format will be returned back in String format.

    .EXAMPLE

    #Generate a UML diagram of the classes located in MyClass.Ps1
    # The diagram will be automatically created in the same folder as the file that contains the classes (C:\Classes).

    Write-CUClassDiagram.ps1 -File C:\Classes\MyClass.ps1

    .EXAMPLE
        #Various output formats are available using the parameter "OutPutFormat"

        Write-CUClassDiagram.ps1 -File C:\Classes\Logging.psm1 -ExportFolder C:\admin\ -OutputFormat gif


        Directory: C:\admin


    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----       12.06.2018     07:47          58293 Logging.gif

    .EXAMPLE

    Write-CUClassDiagram -Path "C:\Modules\PSClassUtils\Classes\Private\" -Show

    Will generate a diagram of all the private classes available in the Path specified, and immediatley show the diagram.

    .NOTES
        Author: Stéphane van Gulick
        Version: 0.8.2
        www: www.powershellDistrict.com
        Report bugs or ask for feature requests here:
        https://github.com/Stephanevg/Write-CUClassDiagram
    #>
  
    [CmdletBinding()]
    Param(
    
        
        [Parameter(Mandatory=$false)]
        [ValidateScript({
                Test-Path $_
        })]
        [string]
        $Path,

        [String]
        $FolderPath,

        [Parameter(Mandatory=$false,ParameterSetName='Folder')]
        [switch]
        $Recurse,

        [Parameter(Mandatory=$false)]
        [System.IO.DirectoryInfo]
        $ExportFolder,

        [ValidateSet('jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot')]
        [string]
        $OutputFormat = 'png',

        [Parameter(Mandatory = $false)]
        [switch]$Show,

        [Parameter(Mandatory = $false)]
        [switch]
        $PassThru,

        [Parameter(Mandatory = $false)]
        [switch]
        $IgnoreCase
    )
    if (-not (Get-Module -Name PSGraph)) {
        #Module is not loaded
        if (-not (Get-Module -ListAvailable -Name PSGraph )) {
            #Module is not present
            throw 'The module PSGraph is a prerequisite for this script to work. Please Install PSGraph first using Install-Module PSGraph'
        } else {
            Import-Module PSGraph -Force
        }
    }
    
    if($FolderPath){
        $Path = $FolderPath
        write-warning "The parameter -FolderPath is deprecated, and will be removed in a future version. Please use -Path instead."
    }

    #Methods are called FunctionMemberAst
    #Properties are called PropertyMemberAst

    #region preparing paths
    $PathObject = Get-Item $Path
    if ($PathObject -is [System.IO.DirectoryInfo]) {
        $ExportFileName = "Diagram" + "." + $OutputFormat
        $FolderPath = $Path

        if ($Recurse) {

            $AllItems = Get-ChildItem -path "$($Path)\*" -Include "*.ps1", "*.psm1" -Recurse
        } else {
            $AllItems = Get-ChildItem -path "$($Path)\*" -Include "*.ps1", "*.psm1"
        }
        #$Path = $null
    }
    elseif ($PathObject -is [System.IO.FileInfo]) {
        [System.IO.FileInfo]$File = (Resolve-Path -Path $Path).Path
        $ExportFileName = $File.BaseName + "." + $OutputFormat
        $AllItems = $File
    }
    else {
        throw 'Path provided was not a file or folder'
    }

    if (-not ($ExportFolder)) {

        if ($FolderPath) {
            $SourceFolder = (Resolve-Path -Path $FolderPath).Path
        } else {

            $SourceFolder = $File.Directory.FullName
        }
        $FullExportPath = Join-Path -Path $SourceFolder -ChildPath $ExportFileName
        
    } else {
        if ($ExportFolder.Exists){

            $FullExportPath = Join-Path $ExportFolder.FullName -ChildPath $ExportFileName
        } else {
            throw "$($ExportFolder.FullName) Doesn't exist"
        }

    }

    #endregion

    $AST = Get-CUAst -Path $AllItems 
    
    $GraphParams = @{}
    $GraphParams.InputObject = $AST

    if ($IgnoreCase) {
        $GraphParams.IgnoreCase = $true
    }
    $Graph =  Out-CUPSGraph @GraphParams

    $Export = $Graph | Export-PSGraph -DestinationPath $FullExportPath  -OutputFormat $OutputFormat

    if ($Show) {
        $Graph | Show-PSGraph
    }

    if ($PassThru) {
        $Graph
    } else {
        $Export
    }

}
