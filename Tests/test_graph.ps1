$Graph = Graph {
    foreach($obj in $inputObject){
        $CurrName = split-Path -leaf $obj.Name
        subgraph -Attributes @{label=($CurrName)} -ScriptBlock {
                Foreach( $Class in $obj.Group ) {

                    $RecordName = $Class.Name
                    $Constructors = $Class.Constructor
                    $Methods = $Class.Method
                    $Properties = $Class.Property

                    Record -Name $RecordName {
                        If ($Properties) {

                            Foreach ($pro in $Properties) {

                                if ($pro.Visibility -eq "Hidden") {
                                    $visibility = "-"
                                } Else {
                                    $visibility = "+"
                                }
                                
                                $n = "$($visibility) [$($pro.Type)] `$$($pro.Name)"
                                if ($n) {
                                    Row -label "$($n)"  -Name "Row_$($pro.Name)"
                                }
                                else {
                                    $pro.name
                                }
            
                            }

                        }

                        Row "-----Constructors-----"  -Name "Row_Separator_Constructors"
                        #Constructors
                        If ( $Constructors ) {
                            foreach ($con in $Constructors) {
                                
                                $RowName = "$($con.Name)"
                                
                                If ( $con.Parameter ) {
                                    foreach ($c in $con.Parameter) {
                                        $Parstr = $Parstr + $C.Type + '$' + $c.Name + ","
                                    }
                                    
                                    $Parstr = $Parstr.trim(",")
                                }

                                If ($Parstr) {
                                    $RowName = $RowName + "(" + $Parstr + ")"
                                } Else {
                                    $RowName = $RowName + "()"
                                }
    
                                Row $RowName -Name "Row_$($con.Name)"
                                
                            }
                        } Else {
                            
                        }
                        
                        #Methods Raw
                        Row "-----Methods-----"  -Name "Row_Separator_Methods"
                        
                        If ( $Methods ) {
                            Write-Host $Methods.Count
                            $i=0
                            Foreach ($mem in $Methods) {

                                $visibility = "+"
                                $Parstr = ""

                                If ( $mem.Parameter ) {
                                    ForEach ( $p in $mem.Parameter ) {
                                        $Parstr = $Parstr +  $p.Type + '$' + $p.Name + ","
                                    }
                                
                                    $Parstr = $Parstr.trim(",")
                                }
                                
                                $RowName = "$($mem.Name)"
                                

                                If ( $Parstr ) {
                                    $RowName = $RowName + "(" + $Parstr + ")"
                                } Else {
                                    $RowName = $RowName + "()"
                                }
        
                                If ( $mem.IsHidden ) {
                                    $visibility = "-"
                                }

                                $RowName = $visibility + $RowName
                                #$i++
                                #write-host $i + ' - ' + $RowName
                                Row $RowName -Name "Row_$($mem.Name)"
                            }
                        }
                
                    }#End Record
                }#end foreach Class

            }#End SubGraph
        
        ## InHeritance
        Foreach ($class in ($Obj.Group | where-Object IsInherited)){
            $Parent = $Class.ParentClassName
            $Child = $Class.Name
            edge -From $Parent -To $Child
        }
    }
}