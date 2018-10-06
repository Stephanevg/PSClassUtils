Function get-test {
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

    .EXAMPLE

    Write-CUClassDiagram -FolderPath "C:\Modules\PSClassUtils\Classes\Private\" -Show

    Will generate a diagram of all the private classes available in the FolderPath specified, and immediatley how the diagram.

    .NOTES
        Author: Stéphane van Gulick
        Version: 0.8.2
        www: www.powershellDistrict.com
        Report bugs or ask for feature requests here:
        https://github.com/Stephanevg/Write-CUClassDiagram
    #>
    Param(
        [Alias("Name")]
        [Parameter(Mandatory=$true,ParameterSetName='File',ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [String[]]$Path,

        [Parameter(Mandatory=$False)]
        [Switch]
        $Recurse,

        [Parameter(Mandatory = $False)]
        [Switch]$Show,

        [Parameter(Mandatory=$False)]
        [System.IO.DirectoryInfo]
        $ExportFolder,

        [Parameter(Mandatory = $False)]
        [Switch]
        $PassThru,

        [Parameter(Mandatory = $False)]
        [Switch]
        $IgnoreCase,

        [ValidateSet('jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot')]
        [string]
        $OutputFormat = 'png'
    )

    Begin {
    
        $ScriptFactory = {
            $AST = Get-CUAst -Path $Item
            $GraphParams = @{}
            $GraphParams.InputObject = $AST
            if( $IgnoreCase ){ $GraphParams.IgnoreCase = $true }
            $Graph =  Out-CUPSGraph @GraphParams

            If( $PSBoundParameters['Show'] ){
                    $Graph | Export-PSGraph -DestinationPath ($Item.FullName -replace "$($item.Extension)",".$($PSBoundParameters['OutputFormat'])") -OutputFormat $PSBoundParameters['OutputFormat'] -ShowGraph | Out-Null
                } Else {
                    $Graph | Export-PSGraph -DestinationPath ($Item.FullName -replace "$($item.Extension)",".$($PSBoundParameters['OutputFormat'])") -OutputFormat $PSBoundParameters['OutputFormat']  | Out-Null
                }

            If ( $PSBoundParameters['PassThru'] ) {
                $Graph
            }
        }

    }

    Process{

        ## Setting default OutPutFormat
        If ( $null -eq $PSBoundParameters['OutPutFormat'] ) { $PSBoundParameters['OutPutFormat'] = "png" }
        
        ## Pipeline incoming
        If ( $MyInvocation.PipelinePosition -ne 1 ) {
            ## Recurse Param prohibited: better use -recurse on the left side of the pipeline
            If ($PSBoundParameters['Recurse']) { Throw "Recruse can not be used when pipeline, use Get-ChildItem -Recurse"}
            ## Make sure current file extension is either .ps1 or .psm1
            If ( $PsItem.Extension -in ('.ps1','.psm1')){
                ## Fetch current item fullname
                $Item = get-item $PSitem.fullName
                $ScriptFactory.Invoke()
            }

        } ElseIf ( $MyInvocation.PipelinePosition -eq 1) {
        ## Normal use
            ## Recurse Param was used
            If ( $PSBoundParameters['Recurse'] ) {
                ## Make sure the path specified is a directory
                If ( (Get-Item -Path $Path).GetType().Name -eq "DirectoryInfo" ){
                    ## Catching other parameters to pass to the recurse
                    $RecurseParam = @{}
                    If ( $PSBoundParameters['ExportFolder'] ) { $RecurseParam.add("ExportFolder",$PSBoundParameters['ExportFolder']) }
                    If ( $PSBoundParameters['OutputFormat'] ) { $RecurseParam.add("OutputFormat",$PSBoundParameters['OutputFormat']) }
                    If ( $PSBoundParameters['IgnoreCase'] ) { $RecurseParam.add("IgnoreCase",$PSBoundParameters['IgnoreCase']) }
                    If ( $PSBoundParameters['PassThru']) {$RecurseParam.add("PassThru",$PSBoundParameters['PassThru']) }
                    If ( $PSBoundParameters['Show']) {$RecurseParam.add("Show",$PSBoundParameters['Show'])}

                    ## Do Recurse
                    Get-ChildItem -Path $Path -Recurse | get-test @RecurseParam

                } Else {
                    ## Path is a file, so we cannot recurse on that
                    Throw "No recurse on a file..."
                }
            } Else {
            ## Recurse Param is not used
                $Item = get-item $Path
                ## Make sure current file extension is either .ps1 or .psm1
                If ( $Item.Extension -in ('.ps1','.psm1')){
                    $ScriptFactory.Invoke()

                } Else {
                    ## Current file extension is either .ps1 or .psm1
                    Throw "Not a ps1 nor a psm1 file..."
                }
            }
        }
    }

    End{}
}