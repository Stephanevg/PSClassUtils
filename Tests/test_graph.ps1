
$inputobject = Get-ADDomainController -Filter * | group -Property site

$b = Get-ADReplicationSiteLink -Filter *
$b = $b | select @{l='sites';e={$_.SitesIncluded.ForEach({$_.split(',')[0].replace('CN=','')})}}

$Graph = Graph -ScriptBlock {
    foreach($obj in $inputObject){
        $CurrName = (split-Path -leaf $obj.Name).ToUpper()
        subgraph $CurrName.Replace('-','') -Attributes @{label=($CurrName)} -ScriptBlock {
            Foreach( $Class in $obj.Group ) {

                $RecordName = $Class.HostName

                Record -Name $RecordName {
                    Row -label "IP: $($Class.IPv4Address)"  -Name "Row_IP"
                    Row -label "OS: $($Class.OperatingSystem)"  -Name "Row_OS"
                }#End Record
            }#end foreach Class
        }#End SubGraph

        
        foreach ( $x in $($b | Where-Object sites -contains $CurrName) ) {
            If ( $x.sites.count -gt 1) {
                Write-Host "OK"
                $x.sites | ForEach-Object{
                    write-host $_
                    if ( $_ -ne $CurrName ) {
                       edge -From $($CurrName.Replace('-','')) -To (($_).ToUpper().replace('-',''))
                    }
                }
            }
        }
    }
} -Attributes @{compound='true'}

$Graph


$graph = Graph -ScriptBlock {
    ForEach ( $site in $([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites) ) {
        node $site.name
        Foreach ( $subnet in $site.subnets) {
            node $subnet.name
            edge -From $site.name -To $subnet.name
        }
    }
} -Attributes @{labelloc='c'}
