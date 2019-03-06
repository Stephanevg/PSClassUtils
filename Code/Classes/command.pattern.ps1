Class ICommand {

    Execute(){

    }
}

Class GraphCommand : ICommand {
    [System.Collections.Generic.List[GraphCommandParam]]$Parameters = @()
    
    GraphCommand(){}


    [GraphCommandParam[]]GetCommandParam(){

        return $this.Parameters

    }

    [GraphCommandParam]GetCommandParam([String]$Name){

        return $this.Parameters.Find($Name)

    }

    [void]AddCommandParam([GraphCommandParam]$Parameter){
        $this.Parameters.Add($Parameter)
    }

    [void]RemoveCommandParam([GraphCommandParam]$Parameter){
        $this.Parameters.Remove($Parameter)
    }

    Execute(){
        $Hash = @{}

        foreach($para in $this.Parameters){
            $Hash.$($para.Name) = $para.value
        }

        Write-CUClassDiagram @Hash
    }
}


Class GraphCommandParam {
    [String]$Name
    [object]$Value
    [Bool]$IsSwitch

    GraphCommandParam(){}
    GraphCommandParam([String]$Name,[Bool]$IsSwitch){
        $This.Name = $Name
        $this.IsSwitch = $IsSwitch
    }
    GraphCommandParam([String]$Name,[Object]$Value){
        $this.Name = $Name
        $This.Value = $Value
        $this.IsSwitch = $False
    }
    GraphCommandParam([String]$Name,[Object]$Value,[Bool]$IsSwitch){
        $this.Name = $Name
        $This.Value = $Value
        $this.IsSwitch = $IsSwitch
    }

    [Bool]GetIsSwitch(){
        return $this.IsSwitch
    }

    [String] ToString(){
        IF($Null -eq $this.Name){
            throw "Name cannot be empty."
        }

        If($This.GetIsSwitch()){

            return "-{0}" -f, $this.Name
        }Else{
            return "-{0} {1}" -f $this.Name, $this.Value
        }

    }
}

Class GraphParamExportFolder: GraphCommandParam {
    GraphParamExportFolder([Object]$Value) : Base("ExportFolder",$Value,$False){}
}

Class GraphParamShow : GraphCommandParam {
    GraphParamShow() : Base("Show",$True){}
}

Class GraphParamPath: GraphCommandParam {
    GraphParamPath([String]$Path) : Base("Path",$Path){}
}
<#

    List of GraphParamXXX to create

    [String] Path
    [String] OutputType [ValidateSet('Unique','Combined')]
    [String] ExportFolder
    [String] OutputFormat [ValidateSet('jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot')]
    [Swtich] Show -> Done
    [Switch] IgnoreCase
    [Switch] Passthru
    [String] Recurse
    [String[]] $Exclude
#>


$e = [GraphCommand]::New()
$e.AddCommandParam([GraphParamPath]::New("C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Code\Classes"))
$e.AddCommandParam([GraphParamShow]::New())
$e.Execute()

