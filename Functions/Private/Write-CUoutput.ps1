Function Write-CUOutput {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        $e = Write-CUOutput -Object (get-ast -path "C:\Scripts\JeffHicks_StarShipModule.ps1") -Show
        Will generate a diagram with the classes and their inheritance relation ships.
        The parameter -Show will display the generated image immediatly.
        
    .INPUTS
        Path to the ps1 / psm1 file that contains the set of classes / Enums to document in the diagram.
    .OUTPUTS
        Output (if any)


    .PARAMETER Object
    This parameter expects an array of ASTDocument. (Can be generated using Get-AST).

    .PARAMETER ExportFolder

    Points to an alternante folder where to export the report.

    .PARAMETER OutPutFormat

    specifiy in which format the document should be created.

    Current accepted values are the following ones:

    'jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot'

    Default is "png"

    .PARAMETER Show

    Will display the diagram right after it has been generated.

    .PARAMETER Passthru

    When specified, it will return the raw PSGraph string that is generated (This can be usefull to troubleshoot PSgraph related errors.)

    .PARAMETER IgnoreCase

    If there is a difference in the case of the a parent class, and it's child class, drawing the inheritence might not work as expected.
    Foring the case when creating the objects in PSGraph resolves this issue (See issue here -> https://github.com/KevinMarquette/PSGraph/issues/68 )
    Using -IgnoreCase will force all class names to be set to 'TitleCase'.

    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ASTDocument[]]$Object,


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
    
    begin {
        if(!(Get-Module -Name PSGraph)){
            #Module is not loaded
            if(!(get-module -listavailable -name psgraph )){
                #Module is not present
                throw "The module PSGraph is a prerequisite for this function to work. Please Install PSGraph first (You can use Install-CUDiagramPrerequisites to install them.)"
            }else{
                Import-Module psgraph -Force
            }
        }
    }
    
    process {


        $Graph = Graph {

            subgraph -Attributes @{label=($object.Source)} -ScriptBlock {
                Foreach ($Class in $Object.Classes) {
    
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
            
        }#End Graph

    }
    
    end {

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
}