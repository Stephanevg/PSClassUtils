Function Write-CUOutput {
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

$e = Write-CUOutput -Object (get-ast -path "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\04\JeffHicks_StarShipModule.ps1") -Show
