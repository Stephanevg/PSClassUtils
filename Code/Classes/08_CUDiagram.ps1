

Class CUDiagram {
    [String]$Graph
    [CUClass[]]$Class
    [CUEnum[]]$Enum

    CUDiagram(){

    }

    CuDiagram([CUClass[]]$Class){
        $this.addClass($Class)
        $this.Enum = $Enum
    }

    CuDiagram([CUClass[]]$Class,[CUEnum[]]$Enum){
        $this.AddClass($Class)
        $this.AddEnum($Enum)
    }

    AddClass([CUClass[]]$Class){
        $this.AddClass($Class){

        }
    }

    AddEnum([CUEnum[]]$Enum){
        $this.Enum = $Enum
    }


    CreateGraph(){
        #actions for creating graph
        If($this.Class -or $this.Enum){
            $Pars = @{}
            $Pars.InputObject = ""
            $Pars.IgnoreCase = ""
            $Pars.ShowCOmposition = ""
            $Pars.IgnoreCase = ""
            
            try{

                $this.Graph = Out-CUGraph @$Pars -ErrorAction -Stop
            }Catch{
                Throw "Failed to create raw graph: $($_)"
            }
            IF(!($this.Path)){
                Throw "Generated graph is empty. Did you point to a document that contains classes / enums?"
            }
        }Else{
            throw "Add classes or Enums"
        }
    }
    
    CreateDiagram(){
        If(!($this.Graph)){
            Throw "Create a graph first using CreateGraph"
        }else{
            $ParsExport = @{}
            $ParsExport.Show = ""
            $ParsExport.PassThru = ""
            $ParsExport.OutputFormat = ""
            $this.Graph | export-PSGraph @ParsExport
            
        }
    }

}
#>
Enum GraphOutputFormat{
    jpg
    png
    gif
    imap
    cmapx
    jp2
    pdf
    plain
    dot
}

Class ClassGraphOptions {
    [Object]$InputObject #Show be [CUClass[]] and / or [CUEnum[]]
    [bool]$IgnoreCase
    [Bool]$ShowComposition
    [Bool]$Show
    [Bool]$PassThru
    [GraphOutputFormat]$Format

    ClassGraphOptions(){

    }

    [ClassGraphOptions] SetInputObject([Object]$InputObject){
        $this.Object = $InputObject
        return $this
    }


    [ClassGraphOptions] SetShowComposition(){
        $this.ShowComposition = $true
        return $this
    }

    [ClassGraphOptions] SetIgnoreCase(){
        $this.IgnoreCase = $true
        return $this
    }

    [ClassGraphOptions] SetShow(){
        $this.Show = $true
        return $this
    }

    [ClassGraphOptions] SetPassThru(){
        $this.PassThru = $true
        return $this
    }

    [ClassGraphOptions] SetOutputFormat([GraphOutputFormat]$Format){
        $this.Format = $Format
        return $this
    }

    [HashTable] GetParameterHashTable(){
        
        $Options = $this.psobject.Members | ? {$_.MemberType -eq 'Property'} | select Name,Value
        $Hash = @{}
        Foreach($opt in $options){
            $Hash.$($opt.Name) = $opt.Value
        }

        return $Hash
    }
}

