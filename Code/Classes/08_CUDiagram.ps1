
enum GraphOutputFormat{
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

Class CUClassGraphOptions {
    [Object]$InputObject #Should be [CUClass[]] and / or [CUEnum[]]
    [bool]$IgnoreCase
    [Bool]$ShowComposition
    [Bool]$Show
    [Bool]$PassThru
    [GraphOutputFormat]$OutputFormat

    CUClassGraphOptions(){

    }

    [CUClassGraphOptions] SetInputObject([Object]$InputObject){
        $this.Object = $InputObject
        return $this
    }


    [CUClassGraphOptions] SetShowComposition(){
        $this.ShowComposition = $true
        return $this
    }

    [CUClassGraphOptions] SetIgnoreCase(){
        $this.IgnoreCase = $true
        return $this
    }

    [CUClassGraphOptions] SetShow(){
        $this.Show = $true
        return $this
    }

    [CUClassGraphOptions] SetPassThru(){
        $this.PassThru = $true
        return $this
    }

    [CUClassGraphOptions] SetOutputFormat([GraphOutputFormat]$OutputFormat){
        $this.OutputFormat = $OutputFormat
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

Class CUDiagram {
    $GraphVizDocument
    [Object[]]$Objects
    [CUClassGraphOptions]$Options

    CUDiagram(){

    }

    CUDiagram([CUClassGraphOptions]$Options){
        $this.SetOptions($Options)
    }

    CuDiagram([Object[]]$Objects){
        $this.Objects += $Objects
        
    }

    CUDiagram([Object[]]$Objects,[CUClassGraphOptions]$Options){
        $this.Objects += $Objects
        $this.SetOptions($Options)
    }

    AddObjects([Object[]]$Objects){
        $Allowed = @('CUClass','ClassEnum')
        foreach($obj in $Objects){
            if($obj.GetType().Name -in $Allowed){
                $This.Objects += $obj
            }else{
                Throw "$($obj.GetType()) Is not an allowed type."
            }
        }
    }

    
    <#
    AddClass([CUClass[]]$Class){
        $this.Objects += $Class
    }

    AddEnum([ClassEnum[]]$Enum){
       $this.Objects += $Enum
    }
    #>


    CreateGraphVizDocument(){
        #actions for creating graph
        If($this.Objects){
            $o = $this.Options.GetParameterHashTable()
            $Pars = @{}
            $Pars.InputObject = $this.Objects
            $Pars.IgnoreCase = $o.IgnoreCase
            $Pars.ShowCOmposition = $o.showComposition
            $Pars.ErrorAction = "Stop"
            
            try{
                
                $this.GraphVizDocument = Out-CUPSGraph @Pars 
            }Catch{
                Throw "Failed to create raw graph: $($_)"
            }
            IF(!($this.GraphVizDocument)){
                Throw "Generated graph is empty. Did you point to a document that contains classes / enums?"
            }
        }Else{
            throw "Add classes or Enums"
        }
    }
    
    CreateDiagram(){
        If(!($this.GraphVizDocument)){
            Throw "Create a graphViz document first using CreateGraph"
        }else{
            $o = $this.Options.GetParameterHashTable()
            $ParsExport = @{}
            $ParsExport.ShowGraph = $o.show
            
            $ParsExport.OutputFormat = $o.OutputFormat
            $this.GraphVizDocument | export-PSGraph @ParsExport
            If( $o.PassThru){
                
            }
            
        }
    }

    [CUClassGraphOptions] GetOptions(){
        Return $This.Options
    }

    SetOptions([CUClassGraphOptions]$Options){
        $This.Options = $Options
    }

}



