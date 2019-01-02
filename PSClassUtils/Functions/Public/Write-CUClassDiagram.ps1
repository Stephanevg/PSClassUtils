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
        [Switch]$Recurse,

        [Parameter(Mandatory=$False)]
        [ValidateSet('PerFile','PerDirectory')]
        $OutPutDiagram = 'PerDirectory',

        [Parameter(Mandatory=$False)]
        [ValidateSet('jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot')]
        [string]
        $OutputFormat = 'png',

        [Parameter(Mandatory=$False)]
        [ValidateScript({ Test-Path $_ })]
        [String]
        $ExportFolder,

        [Parameter(Mandatory=$False)]
        [Switch]$IgnoreCase,

        [Parameter(Mandatory=$False)]
        [Switch]$ShowComposition,

        [Parameter(Mandatory=$False)]
        [Switch]$Show,

        [Parameter(Mandatory = $false)]
        [Switch]
        $PassThru

    )
    
    Begin {}
    
    Process {

        ## Create GraphParameters
        $GraphParams = @{}
        If ( $PSBoundParameters['IgnoreCase'] ) { $GraphParams.IgnoreCase = $True }
        If ( $PSBoundParameters['ShowComposition'] ) { $GraphParams.ShowComposition = $True }

        ## Create ExportParams
        $ExportParams = @{}
        $ExportParams.OutputFormat = If( $Null -ne $PSBoundParameters['OutPutFormat'] ){ $PSBoundParameters['OutPutFormat'] }Else{ $OutputFormat }
    
    
        ## Depending on the Type of the Path Parameter... File or Directory, other (default)
        $PathItem = Get-Item $PSBoundParameters['Path']
        Switch ( $PathItem ) {

            { $PSItem -is [System.Io.FileInfo] } {
                
                Write-Verbose "Write-CuClassDiagram -> Dealing with a File..."

                $Class = Get-CUCLass -path $PSItem | Group-Object -Property Path
                If ( $Null -ne $Class ) {
                    $GraphParams.InputObject = $Class
                    $Graph =  Out-CUPSGraph @GraphParams
                    If ( $PSBoundParameters['ExportFolder'] ) {
                        $ExportParams.DestinationPath = Join-Path $PSBoundParameters['ExportFolder'] -ChildPath ($([System.io.FileInfo]$GraphParams['inputobject'].name).BaseName+'.'+$ExportParams.OutPutFormat)
                    } Else {
                        $ExportParams.DestinationPath = Join-Path $([System.io.FileInfo]$GraphParams['inputobject'].name).DirectoryName -ChildPath ($([System.io.FileInfo]$GraphParams['inputobject'].name).BaseName+'.'+$ExportParams.OutPutFormat)
                    }
                    
                    ## PassThru Specified
                    If ( $PSBoundParameters['PassThru'] ) {
                        Write-Verbose "Write-CuClassDiagram -> PassThru Parameter Specified... Export Graph(s)..."
                        $Graph
                        $null = $Graph | Export-PSGraph @ExportParams
                    } Else {
                        Write-Verbose "Write-CuClassDiagram -> PassThru Parameter NOT Specified... Export Graph(s)..."
                        $Graph | Export-PSGraph @ExportParams
                    }

                } ## Empty class variable, not a class file

            } ## Not a file

            { $PSItem -is [System.Io.DirectoryInfo] } {

                Write-Verbose "Write-CuClassDiagram -> Dealing with a Directory..."
                
                If ( $PSBoundParameters['Recurse'] ) {

                    Write-Verbose "Write-CuClassDiagram -> Recurse parameter used..."

                    ## If OutPutDiagram is not specified, we must use the default value, wich is PerDirectory
                    If ( ($PSBoundParameters['OutPutDiagram'] -eq 'PerDirectory') -or ( $null -eq $PSBoundParameters['OutPutDiagram'] ) ) {

                        Write-Verbose "Write-CuClassDiagram -> OutPutDiagram Per Directory..."
                        
                        Foreach ( $Directory in $(Get-ChildItem -path $PSItem -Directory -Recurse) ) {

                            $Classes = Get-ChildItem -path $($Directory.FullName+'\*') -Include '*.ps1', '*.psm1' | Get-CUCLass  | Group-Object -Property Path

                            If ( $Null -ne $Classes ) {

                                $GraphParams.InputObject = $Classes
                                $Graph =  Out-CUPSGraph @GraphParams

                                If ( $PSBoundParameters['ExportFolder'] ) {
                                    $ExportParams.DestinationPath = Join-Path $PSBoundParameters['ExportFolder'] -ChildPath ($Directory.Name+'.'+$ExportParams.OutPutFormat)
                                } Else { 
                                    $ExportParams.DestinationPath = Join-Path $Directory.PSParentPath -ChildPath ($PSItem.Name+'.'+$ExportParams.OutPutFormat)
                                }

                                ## PassThru Specified
                                If ( $PSBoundParameters['PassThru'] ) {
                                    Write-Verbose "Write-CuClassDiagram -> PassThru Parameter Specified... Export Graph(s)..."
                                    $Graph
                                    $null = $Graph | Export-PSGraph @ExportParams
                                } Else {
                                    Write-Verbose "Write-CuClassDiagram -> PassThru Parameter NOT Specified... Export Graph(s)..."
                                    $Graph | Export-PSGraph @ExportParams
                                }

                            } ## No Classes found, Next directory please ..
                            
                        } ## No more directories to parse

                    } ## Option PerDirectory for OutPutDiagram was not specified

                    If ( $PSBoundParameters['OutPutDiagram'] -eq 'PerFile' ) {

                        Write-Verbose "Write-CuClassDiagram -> OutPutDiagram Per File..."

                        $Classes = Get-ChildItem -path "$($PSItem)\*" -Include "*.ps1", "*.psm1" -Recurse | Get-CUCLass  | Group-Object -Property Path
                        Foreach ( $Group in $Classes ) {
                            
                            $GraphParams.InputObject = $Group
                            $Graph =  Out-CUPSGraph @GraphParams

                            If ( $PSBoundParameters['ExportFolder'] ) {
                                $ExportParams.DestinationPath = Join-Path $PSBoundParameters['ExportFolder'] -ChildPath ($([System.io.FileInfo]$GraphParams['inputobject'].name).BaseName+'.'+$ExportParams.OutPutFormat)
                            } Else {
                                $ExportParams.DestinationPath = Join-Path $([System.io.FileInfo]$GraphParams['inputobject'].name).DirectoryName -ChildPath ($([System.io.FileInfo]$GraphParams['inputobject'].name).BaseName+'.'+$ExportParams.OutPutFormat)
                            }

                            ## PassThru Specified
                            If ( $PSBoundParameters['PassThru'] ) {
                                Write-Verbose "Write-CuClassDiagram -> PassThru Parameter Specified... Export Graph(s)..."
                                $Graph
                                $null = $Graph | Export-PSGraph @ExportParams
                            } Else {
                                Write-Verbose "Write-CuClassDiagram -> PassThru Parameter NOT Specified... Export Graph(s)..."
                                $Graph | Export-PSGraph @ExportParams
                            }
                        }
                    } ## Option PerFile for OutPutDiagram was not specified
                    
                } Else {

                    Write-Verbose "Write-CuClassDiagram -> Recurse Parameter was not specified..."

                    $Classes = Get-ChildItem -path "$($PSItem)\*" -Include "*.ps1", "*.psm1" | Get-CUCLass | Group-Object -Property Path
                    
                    If ( $Null -ne $Classes ) {

                        Write-Verbose "Write-CuClassDiagram -> $($Classes.Count) Class(es) were found..."

                        ## If OutPutDiagram is not specified, we must use the default value, wich is PerDirectory
                        If ( ($PSBoundParameters['OutPutDiagram'] -eq 'PerDirectory') -or ( $null -eq $PSBoundParameters['OutPutDiagram'] ) ) {

                            Write-Verbose "Write-CuClassDiagram -> OutPutDiagram Per Directory..."

                            $GraphParams.InputObject = $Classes
                            $Graph =  Out-CUPSGraph @GraphParams
    
                            If ( $PSBoundParameters['ExportFolder'] ) {
                                $ExportParams.DestinationPath = Join-Path $PSBoundParameters['ExportFolder'] -ChildPath ($PSItem.Name+'.'+$ExportParams.OutPutFormat)
                            } Else {
                                $ExportParams.DestinationPath = Join-Path $PSItem.FullName -ChildPath ($PSItem.Name+'.'+$ExportParams.OutPutFormat)
                            }
                            
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
    
                        If ( $PSBoundParameters['OutPutDiagram'] -eq 'PerFile' ) {

                            Write-Verbose "Write-CuClassDiagram -> OutPutDiagram Per File..."

                            ##loop
                            Foreach ( $Group in $Classes ) {
                                $GraphParams.InputObject = $Group
                                $Graph =  Out-CUPSGraph @GraphParams
    
                                If ( $PSBoundParameters['ExportFolder'] ) {
                                    $ExportParams.DestinationPath = Join-Path $PSBoundParameters['ExportFolder'] -ChildPath ($(get-item $Group.Name).BaseName +'.'+ $ExportParams.OutPutFormat)
                                } Else {
                                    $ExportParams.DestinationPath = Join-Path $PSItem.FullName -ChildPath ($(get-item $Group.Name).BaseName +'.'+ $ExportParams.OutPutFormat)
                                }

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