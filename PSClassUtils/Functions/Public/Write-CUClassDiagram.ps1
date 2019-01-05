function Write-CUClassDiagram {
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
        Author: lxLeChat
        Version: 
        www: https://github.com/LxLeChat
        Report bugs or ask for feature requests here:
        https://github.com/Stephanevg/Write-CUClassDiagram
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(Mandatory=$True)]
        [String]$Path,

        [Parameter(Mandatory=$False)]
        [ValidateSet('Unique','Combined')]
        $OutPutType = 'Combined',

        [Parameter(Mandatory=$False)]
        [ValidateSet('jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot')]
        [string]$OutputFormat = 'png',

        [Parameter(Mandatory=$False)]
        [ValidateScript({ Test-Path $_ })]
        [String]$ExportFolder,

        [Parameter(Mandatory=$False)]
        [Switch]$IgnoreCase,

        [Parameter(Mandatory=$False)]
        [Switch]$ShowComposition,

        [Parameter(Mandatory=$False)]
        [Switch]$Show,

        [Parameter(Mandatory = $false)]
        [Switch]
        $PassThru,

        [Parameter(Mandatory = $False)]
        [String[]]$Exclude

    )

    ## Recurse Parameter should be present only when Path Parameter is a directory, and has child directories
    ## Otherwise Recurse Parameter is Useless
    DynamicParam{
        $DynamicParams=New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $PathItem = get-item $PSBoundParameters['Path']

        If ( ($PathItem -is [System.Io.DirectoryInfo]) -and ((gci $PathItem -Directory).Count -gt 0) ) {
            $ParameterName = "Recurse"
            $ParameterAttributes = New-Object System.Management.Automation.ParameterAttribute
            $Parameter = New-Object System.Management.Automation.RuntimeDefinedParameter $ParameterName,switch,$ParameterAttributes
            $DynamicParams.Add($ParameterName,$Parameter)
            return $DynamicParams
        }
    }

    Begin {

        ## ScriptBlock to find classes in file(s)
        $FindClasses = {
            param($a)
            If ( $PSBoundParameters['Exclude'] ) {
                Write-Verbose "Write-CuClassDiagram -> Exclude Parameter Specified..."
                Get-ChildItem -path $a -Include '*.ps1', '*.psm1' | Get-CUCLass | Where-Object Name -NotIn $PSBoundParameters['Exclude'] |  Group-Object -Property Path
            } Else {
                Write-Verbose "Write-CuClassDiagram -> Exclude Parameter NOT Specified..."
                Get-ChildItem -path $a -Include '*.ps1', '*.psm1' | Get-CUCLass  | Group-Object -Property Path    
            }
        }

        ## ScriptBlock to generate graph
        $GenerateGraph = {
            param($a)
            $GraphParams.InputObject = $a
            Out-CUPSGraph @GraphParams
        }

        ## ScriptBlock For Export, valid not matter what..!
        $ExportInvoke = {
            ## PassThru Specified
            If ( $PSBoundParameters['PassThru'] ) {
                Write-Verbose "Write-CuClassDiagram -> PassThru Parameter Specified... Returning Graph Variable Content..."
                $Graph
                $null = $Graph | Export-PSGraph @ExportParams
            } Else {
                Write-Verbose "Write-CuClassDiagram -> PassThru Parameter NOT Specified... Export Graph(s)..."
                $Graph | Export-PSGraph @ExportParams
            }
        }
    }
    
    Process {

        ## Create GraphParameters Hashtable
        $GraphParams = @{}
        If ( $PSBoundParameters['IgnoreCase'] ) { $GraphParams.IgnoreCase = $True }
        If ( $PSBoundParameters['ShowComposition'] ) { $GraphParams.ShowComposition = $True }

        ## Create ExportParams Hashtable
        $ExportParams = @{}
        $ExportParams.OutputFormat = If( $Null -ne $PSBoundParameters['OutPutFormat'] ){ $PSBoundParameters['OutPutFormat'] }Else{ $OutputFormat }
    
    
        ## Depending on the Type of the Path Parameter... File or Directory, other (default)
        $PathItem = Get-Item $PSBoundParameters['Path']

        Switch ( $PathItem ) {

            { $PSItem -is [System.Io.FileInfo] } {
                Write-Verbose "Write-CuClassDiagram -> Dealing with a File..."

                ## Looking for Classes
                $Classes = $FindClasses.Invoke($PSItem)
                
                If ( $Null -ne $Classes ) {
                    $Graph =  $GenerateGraph.Invoke($Classes)
                    If ( $PSBoundParameters['ExportFolder'] ) ## Export must be made in a specified folder
                    {
                        $ExportSplattingParameters = @{
                            Path = $PSBoundParameters['ExportFolder']
                            ChildPath = ($([System.io.FileInfo]$GraphParams['inputobject'].name).BaseName+'.'+$ExportParams.OutPutFormat)
                        }
                        $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                    } Else ## Export must be in the same directory
                    {
                        $ExportSplattingParameters = @{
                            Path = $([System.io.FileInfo]$GraphParams['inputobject'].name).DirectoryName
                            ChildPath = ($([System.io.FileInfo]$GraphParams['inputobject'].name).BaseName+'.'+$ExportParams.OutPutFormat)
                        }
                        $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                    }
                    $ExportInvoke.Invoke()
                } ## Empty class variable, not a class file
            } ## Not a file

            { $PSItem -is [System.Io.DirectoryInfo] } {
                Write-Verbose "Write-CuClassDiagram -> Dealing with a Directory..."
                If ( $PSBoundParameters['Recurse'] ) {
                    Write-Verbose "Write-CuClassDiagram -> Recurse parameter used..."
                    ## If OutPutType is not specified, we must use the default value, wich is Combined
                    If ( ($PSBoundParameters['OutPutType'] -eq 'Combined') -or ( $null -eq $PSBoundParameters['OutPutType'] ) ) {
                        Write-Verbose "Write-CuClassDiagram -> OutPutType Per Directory..."
                        Foreach ( $Directory in $(Get-ChildItem -path $PSItem -Directory -Recurse) ) {
                            ## Looking for Classes
                            $Classes = $FindClasses.Invoke($Directory.FullName+'\*')
                            If ( $Null -ne $Classes ) {
                                $Graph =  $GenerateGraph.Invoke()
                                If ( $PSBoundParameters['ExportFolder'] ) {
                                    $ExportSplattingParameters = @{
                                        Path = $PSBoundParameters['ExportFolder']
                                        ChildPath = ($Directory.Name+'.'+$ExportParams.OutPutFormat)
                                    }
                                    $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                                } Else {
                                    $ExportSplattingParameters = @{
                                        Path = $Directory.PSParentPath
                                        ChildPath = ($PSItem.Name+'.'+$ExportParams.OutPutFormat)
                                    }
                                    $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                                }
                                $ExportInvoke.Invoke()
                            } ## No Classe(s) found, Next directory please ..   
                        } ## No more directories to parse
                    } ## Option Combined for OutPutType was not specified

                    If ( $PSBoundParameters['OutPutType'] -eq 'Unique' ) {
                        Write-Verbose "Write-CuClassDiagram -> OutPutType Per File..."
                        ## Looking for Classes
                        $FindClasses.Invoke(''+$PSitem+'\*')
                        Foreach ( $Group in $Classes ) {
                            $Graph =  $GenerateGraph.Invoke()
                            If ( $PSBoundParameters['ExportFolder'] ) {
                                $ExportSplattingParameters = {
                                    Path = $PSBoundParameters['ExportFolder']
                                    ChildPath = ($([System.io.FileInfo]$GraphParams['inputobject'].name).BaseName+'.'+$ExportParams.OutPutFormat)
                                }
                                $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                            } Else {
                                $ExportSplattingParameters = {
                                    Path = $([System.io.FileInfo]$GraphParams['inputobject'].name).DirectoryName
                                    ChildPath = ($([System.io.FileInfo]$GraphParams['inputobject'].name).BaseName+'.'+$ExportParams.OutPutFormat)
                                }
                                $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                            }
                            $ExportInvoke.Invoke()
                        }
                    } ## Option Unique for OutPutType was not specified
                } Else {
                    Write-Verbose "Write-CuClassDiagram -> Recurse Parameter NOT specified..."
                    ## Looking for Classes
                    $Classes = $FindClasses.Invoke(''+$PSitem+'\*')
                    If ( $Null -ne $Classes ) {
                        Write-Verbose "Write-CuClassDiagram -> $($Classes.Count) Class(es) were found..."
                        ## If OutPutType is not specified, we must use the default value, wich is Combined
                        If ( ($PSBoundParameters['OutPutType'] -eq 'Combined') -or ( $null -eq $PSBoundParameters['OutPutType'] ) ) {
                            Write-Verbose "Write-CuClassDiagram -> OutPutType Per Directory..."
                            $Graph =  $GenerateGraph.Invoke($Classes)
                            If ( $PSBoundParameters['ExportFolder'] ) {
                                
                                $ExportSplattingParameters = @{
                                    Path = $($PSBoundParameters['ExportFolder'])
                                    ChildPath = $($PSItem.Name+'.'+$ExportParams.OutPutFormat)
                                }
                                $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                            } Else {
                                $ExportSplattingParameters = @{
                                    Path = $PSItem.FullName
                                    ChildPath = ($PSItem.Name+'.'+$ExportParams.OutPutFormat)
                                }
                                $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters 
                            }
                            ## Export ScriptBlock invokation
                            $ExportInvoke.Invoke()
                        }
                        If ( $PSBoundParameters['OutPutType'] -eq 'Unique' ) {
                            Write-Verbose "Write-CuClassDiagram -> OutPutType Per File..."

                            Foreach ( $Group in $Classes ) {
                                ## Graph ScriptBlock invokation
                                $Graph = $GenerateGraph.Invoke()
                                
                                ## Generate Export Parameters
                                If ( $PSBoundParameters['ExportFolder'] ) {
                                    $ExportSplattingParameters = @{
                                        Path = $PSBoundParameters['ExportFolder']
                                        ChildPath = ($(get-item $Group.Name).BaseName +'.'+ $ExportParams.OutPutFormat)
                                    }
                                    $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                                } Else {
                                    $ExportSplattingParameters = @{
                                        Path = $PSItem.FullName
                                        ChildPath = ($(get-item $Group.Name).BaseName +'.'+ $ExportParams.OutPutFormat)
                                    }
                                    $ExportParams.DestinationPath = Join-Path @ExportSplattingParameters
                                }

                                ## Export ScriptBlock invokation
                                $ExportInvoke.Invoke()
                            }
                        }

                    } ## No Classes found
                } ## Not a directory nor a file
            } ## Not a directory .. it's something else ... !

            Default {
                Throw 'Path Parameter must be a file or a directory...'
            }
            ## Bye bye
        }
    }
    
    End { <# The end #> }
}