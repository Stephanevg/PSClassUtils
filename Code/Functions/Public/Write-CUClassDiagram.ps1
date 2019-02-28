function Write-CUClassDiagram {
      <#
    .SYNOPSIS
        This script allows to document automatically existing script(s)/module(s) containing classes by generating the corresponding UML Diagram.
    .DESCRIPTION
        Automatically generate a UML diagram of scripts/Modules that contain powershell classes.
    .PARAMETER Path
        The path that contains the classes that need to be documented. 
        The path parameter should point to either a .ps1, .psm1 file, or a directory containing either/both of those file types.
    .PARAMETER ExportFolder
        This optional parameter, allows to specifiy an alternative export folder. By default, the diagram is created in the same folder as the source file.
    .PARAMETER OutPutFormat
        Using the parameter OutputFormat, it is possible change the default output format (.png) to one of the following ones:
        'jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot'
    .PARAMETER OutPutType
        OutPutType is a Set of 2 variables: Combined, Unique
        Combined, all files present in a directory are drawn in the same graph.
        Unique, all files present in a directory are drawn in their own graph.
    .PARAMETER Show
        Open's the generated diagram immediatly
    .PARAMETER IgnoreCase
        By default, Class names MUST be case identical to have the Write-CUClassDiagram cmdlet generate the correct inheritence tree.
        When the switch -IgnoreCase is specified, All class names will be converted to 'Titlecase' to force the case, and ensure the inheritence is correctly drawed in the Class Diagram.
    .PARAMETER PassThru
        When specified, the raw Graph in GraphViz format will be returned back in String format.
    .PARAMETER Recurse
        Dynamic Parameter, available only if the Path Parameter is a Directory containing other directories. If the parameter is used, all subfolders will be parsed.

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
        Author: Stephanevg / LxLeChat
        www: https://github.com/Stephanevg  https://github.com/LxLeChat
        Report bugs or ask for feature requests here:
        https://github.com/Stephanevg/PsClassUtils
    .LINK
        https://github.com/Stephanevg/PsClassUtils
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

        If ( ($PathItem -is [System.Io.DirectoryInfo]) -and ((Get-ChildItem -Path $PathItem -Directory).Count -gt 0) ) {
            $ParameterName = "Recurse"
            $ParameterAttributes = New-Object System.Management.Automation.ParameterAttribute
            $Parameter = New-Object System.Management.Automation.RuntimeDefinedParameter $ParameterName,switch,$ParameterAttributes
            $DynamicParams.Add($ParameterName,$Parameter)
            return $DynamicParams
        }
    }

    Begin { <# The begining #>

        ## Check Exclude Parameters, Wildcard is only allowed when Exclude contains One item
        If ( $null -ne $MyInvocation.BoundParameters.Exclude )
        {
            If ( $MyInvocation.BoundParameters.Exclude.count -eq 1 )
            {
                 If ( $MyInvocation.BoundParameters.Exclude -notmatch '^*?\w+\*?$' )
                {
                    Throw "Wildcard must be positionned at the end of your item..."
                }
            }
            If ( $MyInvocation.BoundParameters.Exclude.count -gt 1 )
            {
                If ( (@($MyInvocation.BoundParameters.Exclude) -notmatch '^\w+$').Count -gt 0 )
                {
                    throw "One of your Exclude item contains a wildcard... Wildcard is only allowed on one item..."
                }
            }
        }

    }
    
    Process {

        ## Depending on the Type of the Path Parameter... File or Directory, other (default)
        $PathItem = Get-Item $PSBoundParameters['Path']

        Switch ( $PathItem ) {

            { $PSItem -is [System.Io.FileInfo] } {
                Write-Verbose "Write-CuClassDiagram -> Dealing with a File..."

                ## Looking for Classes
                $Classes = Find-CUClass -Item $PSitem -Exclude $PSBoundParameters['Exclude']
                
                If ( $Null -ne $Classes ) {

                    $GraphParams = New-CUGraphParameters -InputObject $Classes -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']

                    If ( $PSBoundParameters['ExportFolder'] ) ## Export must be made in a specified folder
                    {
                        If ( $PSBoundParameters['show'] ) { ## Show Switch used
                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $PSitem.BaseName -OutputFormat $OutputFormat -Show    
                        } Else ## Show switch not used
                        {
                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $PSitem.BaseName -OutputFormat $OutputFormat
                        }
                        
                    } Else ## Export must be in the same directory
                    {
                        If ( $PSBoundParameters['show'] ) { ## Show Switch used
                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSitem.Directory -ChildPath $PSitem.BaseName -OutputFormat $OutputFormat -Show
                        } Else  ## Show Switch not used
                        {
                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSitem.Directory -ChildPath $PSitem.BaseName -OutputFormat $OutputFormat
                        }
                    }

                } ## Empty class variable, not a class file
            } ## Not a file

            { $PSItem -is [System.Io.DirectoryInfo] } {
                Write-Verbose "Write-CuClassDiagram -> Dealing with a Directory..."
                
                If ( $PSBoundParameters['Recurse'] ) {
                    Write-Verbose "Write-CuClassDiagram -> Recurse parameter used..."

                    ## If OutPutType is not specified, we must use the default value, wich is Combined
                    If ( $OutPutType -eq 'Combined' ) {
                        Write-Verbose "Write-CuClassDiagram -> OutPutType Per Directory..."
                        Foreach ( $Directory in $(Get-ChildItem -path $PSItem -Directory -Recurse) ) {
                            
                            $Classes = Find-CUClass -Item $($Directory.FullName+'\*') -Exclude $PSBoundParameters['Exclude']
                            
                            ##
                            If ( $Null -ne $Classes ) {

                                $GraphParams = New-CUGraphParameters -InputObject $Classes -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']

                                If ( $PSBoundParameters['ExportFolder'] ) {
                                    If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $Directory.Name -OutputFormat $OutputFormat -Show
                                    } Else
                                    {
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $Directory.Name -OutputFormat $OutputFormat
                                    }
                                } Else {
                                    If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $Directory.FullName -ChildPath $Directory.Name -OutputFormat $OutputFormat -Show
                                    } Else
                                    {
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $Directory.FullName -ChildPath $Directory.Name -OutputFormat $OutputFormat
                                    }    
                                }
                            } ## No Classe(s) found, Next directory please ..  ##>
                        } ## No more directories to parse
                    } ## Option Combined for OutPutType was not specified

                    If ( $OutPutType -eq 'Unique' ) {
                        Write-Verbose "Write-CuClassDiagram -> OutPutType Per File..."

                        Foreach ( $Directory in $(Get-ChildItem -path $PSItem -Directory -Recurse) ) {
                            $Classes = Find-CUClass -Item $($Directory.FullName+'\*') -Exclude $PSBoundParameters['Exclude']
                            
                            If ( $Null -ne $Classes ) {
                                
                                Foreach ( $Group in $Classes ) {
                                    
                                    $GraphParams = New-CUGraphParameters -InputObject $Group -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']

                                    If ( $PSBoundParameters['ExportFolder'] ) {
                                        If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat -Show
                                        } Else 
                                        {
                                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat
                                        }
                                    } Else {
                                        If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path (get-item $group.name).Directory -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat -Show
                                        } Else 
                                        {
                                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path (get-item $group.name).Directory -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat
                                        }
                                        
                                    }
                                }
                            } ## No Classes found
                        } ## Foreach directory
                    } ## Unique
                    
                } Else {
                    Write-Verbose "Write-CuClassDiagram -> Recurse Parameter NOT specified..."
                    $Classes = Find-CUClass -Item (""+$PSitem.FullName+"\*") -Exclude $PSBoundParameters['Exclude']
                    
                    If ( $Null -ne $Classes ) {
                        Write-Verbose "Write-CuClassDiagram -> $($Classes.Count) Class(es) were found..."

                        ## If OutPutType is not specified, we must use the default value, wich is Combined
                        If ( $OutPutType -eq  'Combined') {

                            Write-Verbose "Write-CuClassDiagram -> OutPutType Per Directory..."
                            $GraphParams = New-CUGraphParameters -InputObject $Classes -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']
                            
                            If ( $PSBoundParameters['ExportFolder'] ) {
                                If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                    New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $PSItem.Name -OutputFormat $OutputFormat -Show
                                } Else
                                {
                                    New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $PSItem.Name -OutputFormat $OutputFormat
                                }
                            } Else {
                                If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                    New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSItem.FullName -ChildPath $PSitem.Name -OutputFormat $OutputFormat -Show
                                }
                                Else
                                {
                                    New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSItem.FullName -ChildPath $PSitem.Name -OutputFormat $OutputFormat
                                }
                            }
                        }

                        If ( $OutPutType -eq 'Unique' ) {
                            Write-Verbose "Write-CuClassDiagram -> OutPutType Per File..."

                            Foreach ( $Group in $Classes ) {
                                $GraphParams = New-CUGraphParameters -InputObject $Group -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']

                                If ( $PSBoundParameters['ExportFolder'] ) {
                                    If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat -Show
                                    }
                                    Else
                                    {
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat
                                    }
                                } Else {
                                    If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path (get-item $group.name).Directory -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat -Show
                                    }
                                    Else
                                    {
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path (get-item $group.name).Directory -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat
                                    }
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