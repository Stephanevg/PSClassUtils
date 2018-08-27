Function Write-CUClassDiagram {
    <#
    .SYNOPSIS
        This script allows to document automatically existing script(s)/module(s) containing classes by generating the corresponding UML Diagram.
    .DESCRIPTION
        Automatically generate a UML diagram of scripts/Modules that contain powershell classes.

    .PARAMETER Path

    The path that contains the classes that need to be documented. 
    The path parameter should point to either a .ps1 and .psm1 file.

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

    .NOTES
        Author: Stéphane van Gulick
        Version: 0.8.2
        www: www.powershellDistrict.com
        Report bugs or ask for feature requests here:
        https://github.com/Stephanevg/Write-CUClassDiagram
    #>
  
    [CmdletBinding()]
    Param(
    
        
        [Parameter(Mandatory=$true,ParameterSetName='File')]
        [ValidateScript({
                test-Path $_
        })]
        [System.IO.FileInfo]
        $Path,

        [Parameter(Mandatory=$true,ParameterSetName='Folder')]
        [ValidateScript({
                test-Path $_
        })]

        [System.IO.DirectoryInfo]
        $FolderPath,


        [Parameter(Mandatory=$false)]
        [System.IO.DirectoryInfo]
        $ExportFolder,

        [ValidateSet('jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot')]
        [string]
        $OutputFormat = 'png',

        [Parameter(Mandatory = $False)]
        [Switch]$Show,

        [Parameter(Mandatory = $False)]
        [Switch]
        $PassThru,

        [Parameter(Mandatory = $False)]
        [Switch]
        $IgnoreCase
    )
    if(!(Get-Module -Name PSGraph)){
        #Module is not loaded
        if(!(get-module -listavailable -name psgraph )){
            #Module is not present
            throw "The module PSGraph is a prerequisite for this script to work. Please Install PSGraph first using Install-Module PSGraph"
        }else{
            Import-Module psgraph -Force
        }
    }
    

    #Methods are called FunctionMemberAst
    #Properties are called PropertyMemberAst

    #region preparing paths

    if ($Path){
        [System.IO.FileInfo]$File = $Path.FullName
        $ExportFileName = $file.BaseName + "." + $OutputFormat

    }elseif($FolderPath){
        $ExportFileName = "Diagram" + "." + $OutputFormat

        
    }

    if(!($ExportFolder)){

        if($FolderPath){
            $SourceFolder = $FolderPath.FullName
        }else{

            $SourceFolder = $file.Directory.FullName
        }
        $FullExportPath = join-Path -Path $SourceFolder -ChildPath $ExportFileName
        
    }else{
        if($ExportFolder.Exists){

            $FullExportPath = Join-Path $ExportFolder.FullName -ChildPath $ExportFileName
        }else{
            throw "$($ExportFolder.FullName) Doesn't exist"
        }

    }

    #endregion


    if($Path){
        #Regular way
        $AllItems = $Path
    }ElseIf($FolderPath){
        
        $AllItems = Get-ChildItem -path $FolderPath.FullName -Recurse

    }

    
    
    
    
    $Graph = Graph {
        Foreach($File in $AllItems){
    
            $AST = [System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$null, [ref]$Null)
        
            $type = $ast.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
            $Enums = $type | ? {$_.IsEnum -eq $true}
            $Classes = $type | ? {$_.IsClass -eq $true}
        
            subgraph -Attributes @{label=($File.BaseName)} -ScriptBlock {

            
                Foreach ($Class in $Classes) {

                    $Properties = $Class.members | ? {$_ -is [System.Management.Automation.Language.PropertyMemberAst]}
                    If($IgnoreCase){
                        $RecordName = ConvertTo-titleCase -String $Class.Name
                    }else{

                        $RecordName =  $Class.Name
                    }
                    
                    $Constructors = $Class.members | ? {$_.IsConstructor -eq $true}
                    $AllMembers = @()
                    $AllMembers = $Class.members | ? {$_.IsConstructor -eq $false} #| Select Name,@{name="type";expression = {$_.PropertyType.Extent.Text}}

                    Record -Name $RecordName {

                        #Properties

                        if ($Properties) {

                            Foreach ($pro in $Properties) {
                                $visibility = "+"
                                if ($pro.IsHidden) {
                                    $visibility = "-"
                                }
                            
                                $n = "$($visibility) [$($pro.PropertyType.TypeName.Name)] `$$($pro.Name)"
                                if ($n) {

                                    Row -label "$($n)"  -Name "Row_$($pro.Name)"
                                }
                                else {
                                    $pro.name
                                }
            
                            }
                            Row "-----Constructors-----"  -Name "Row_Separator_Constructors"
                        }

                        #Constructors

                        foreach ($con in $Constructors) {

                            $Parstr = ""
                            foreach ($c in $con.Parameters) {
                                $Parstr = $Parstr + $c.Extent.Text + ","
                            }
                            $Parstr = $Parstr.trim(",")
                            $RowName = "$($con.ReturnType.Extent.Text) $($con.Name)"
                            if ($Parstr) {
                                $RowName = $RowName + "(" + $Parstr + ")"
                            }
                            else {

                                $RowName = $RowName + "()"

                            }


                            Row $RowName -Name "Row_$($con.Name)"
                        }


                        #Methods
                        Row "-----Methods-----"  -Name "Row_Separator_Methods"
                        foreach ($mem in $AllMembers) {
                            $visibility = "+"
                            $Parstr = ""
                            foreach ($p in $mem.Parameters) {
                                $Parstr = $Parstr + $p.Extent.Text + ","
                            }
                            $Parstr = $Parstr.trim(",")
                            $RowName = "$($mem.ReturnType.Extent.Text) $($mem.Name)"
                            if ($Parstr) {
                                $RowName = $RowName + "(" + $Parstr + ")"
                            }
                            else {

                                $RowName = $RowName + "()"

                            }

                        
                            if ($mem.IsHidden) {
                                $visibility = "-"
                            }
                            $RowName = $visibility + $RowName
                            Row $RowName -Name "Row_$($mem.Name)"
                        }
                    
                
                    }#End Record
                }#end foreach Class


                #Inheritence (Creating Edges)
                Foreach($Class in $Classes){
                    if($Class.BaseTypes.Count -ge 1){
                        Foreach($BaseType in $Class.BaseTypes){
                            if($IgnoreCase){
                                $Parent = ConvertTo-titleCase -String $Class.Name
                                $Child = ConvertTo-titleCase -String $BaseType.TypeName.FullName
                            }Else{
                                $Parent = $Class.Name
                                $Child = $BaseType.TypeName.FullName
                            }
                            
                            edge -From $Child -To $Parent
                        }
                        
                    }#End If
                    
                }#End Inheritence

            }#End SubGraph
        } 
    }#End Graph
    
    $Export = $Graph | Export-PSGraph -DestinationPath $FullExportPath  -OutputFormat $OutputFormat

    If($Show){
        $Graph | Show-PSGraph
    }

    if($PassThru){
        $Graph
    }else{
        $Export
    }

}