Function Out-CUPSGraph {
    <#
    .SYNOPSIS
        Generates the graph output. It requires input from Get-CUAST (input of type ASTDOcument)
    .DESCRIPTION
        This function is based on psgraph, which wih is a module to generate diagrams using GraphViz. If psgraph is not present, it will throw.
    .EXAMPLE
        
        
    .INPUTS
        Pipeline input from a ASTDocument Object
    .OUTPUTS
        Output (if any)


    .PARAMETER InputObject
    This parameter expects an array of ASTDocument. (Can be generated using Get-CUAST).


    .PARAMETER IgnoreCase

    If there is a difference in the casesensitivity of the a parent class, and it's child class, drawing the inheritence might not work as expected.
    Forcing the case sensitivy to be everywhere the same when creating the objects in PSGraph resolves this issue (See issue here -> https://github.com/KevinMarquette/PSGraph/issues/68 )
    Using -IgnoreCase will force all class names to be set to 'TitleCase', reglardless of the case sensitivity they had before.

    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
        [ASTDocument[]]$inputObject,


        [Parameter(Mandatory = $False)]
        [Switch]
        $IgnoreCase


    )
    
    begin {
        $AllGraphs = @()
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

            foreach($obj in $inputObject){

                subgraph -Attributes @{label=($Obj.Source)} -ScriptBlock {
                    Foreach ($Class in $Obj.Classes) {
        
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
                        Foreach($Class in $inputObject.Classes){
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

        $AlLGraphs += $Graph
    }
    
    end {

        Return $AlLGraphs
    
    }
}