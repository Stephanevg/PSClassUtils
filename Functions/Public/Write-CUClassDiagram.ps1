Function Write-CUClassDiagram {
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

            ## Building FullExportPath
            If ( $PSBoundParameters['ExportFolder'] ) {
                ## Export inside the ExportFolder
                $FullExportPath = "{0}\{1}" -f $($PSBoundParameters['ExportFolder'] -replace '\$',''),($Item.Name -replace "$($item.Extension)",".$($PSBoundParameters['OutputFormat'])")
            } Else {
                ## Export inside the directory of the class
                $FullExportPath = "{0}" -f ($Item.FullName -replace "$($item.Extension)",".$($PSBoundParameters['OutputFormat'])")
            }

            If( $PSBoundParameters['Show'] ){
                ## Export
                $Graph | Export-PSGraph -DestinationPath $FullExportPath -OutputFormat $PSBoundParameters['OutputFormat'] -ShowGraph | Out-Null
            } Else {
                ## Export + Show
                $Graph | Export-PSGraph -DestinationPath $FullExportPath -OutputFormat $PSBoundParameters['OutputFormat']  | Out-Null
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
                $Item = Get-Item $PSitem.fullName
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
                    Get-ChildItem -Path $Path -Recurse | Write-CUClassDiagram @RecurseParam

                } Else {
                    ## Path is a file, so we cannot recurse on that
                    Throw "No recurse on a file..."
                }
            } Else {
            ## Recurse Param is not used
                $Item = Get-Item $Path
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