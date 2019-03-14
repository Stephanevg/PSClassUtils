
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
    [System.IO.DirectoryInfo]$OutputFolderPath
    [String]$FileName
    [GraphOutputFormat]$OutputFormat
    [String]$Exclude
    [String]$Only
    [Bool]$Recurse

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

    [Void] SetOutputFolderPath([String]$Path){
        If(test-Path $Path){
            $Item = get-Item $Path

            Switch($Item.GetType().FullName){
                'system.io.DirectoryInfo' {
                    $this.OutputFolderPath = $Item.FullName
                    If(!($this.FileName)){
                        $this.ApplyFileName($Item.BaseName)
                    }else{

                        $this.ApplyFileName($this.FileName)
                    }
                    ;Break}
                'system.io.FileInfo' {
                    $this.OutputFolderPath = $Item.Directory.FullName
                    $this.ApplyFileName($Item.BaseName)
                    ;Break
                }
            }
        }
        
    }

    [Void]ApplyFileName([String]$FileName){
        $this.FileName = $FileName + "." + $This.OutputFormat
    }

    [CUClassGraphOptions] SetOutputFolderPath([System.IO.DirectoryInfo]$OutputFolderPath){
        $this.OutputFolderPath = $OutputFolderPath
        return $this
    }

    [CUClassGraphOptions] SetFileName([String]$FileName){
        $this.FileName = $FileName
        return $this
    }

    [CUClassGraphOptions] SetExclude([String]$Exclude){
        $this.Exclude = $Exclude
        return $this
    }

    [CUClassGraphOptions] SetRecurse(){
        $this.Recurse = $True
        return $this
    }

    [CUClassGraphOptions] SetOnly([String]$Only){
        $this.Only = $Only
        return $this
    }

    [String]GetFullExportPath(){
        return "{0}\{1}" -f $this.OutputFolderPath,$this.FileName
    }

}

Class CUDiagram {
    [String]$Path
    [Object[]]$Objects
    [CUClassGraphOptions]$Options
    hidden $GraphVizDocument
    [String[]]$String

    CUDiagram(){

    }
    CUDiagram([String]$Path){
        if(test-Path $Path){
            $this.Path = $Path
            $this.GetClassObjects()
            $this.Options = [CUClassGraphOptions]::New() #I know this is bad. But It seems the right thing to do. For now...
        }else{
            throw "$($Path) not found. Please provide a path that exists."
        }
    }
    CUDiagram([CUClassGraphOptions]$Options){
        $this.SetOptions($Options)
        $this.Options.SetOutputFolderPath()
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
            $this.Options.SetOutputFolderPath($this.Path)
            $o = $this.Options.GetParameterHashTable()
            $ParsExport = @{}
            if($o.Show){

                $ParsExport.ShowGraph = $o.show
            }
            If($o.OutputFolderPath){

                $ParsExport.DestinationPath = $this.Options.GetFullExportPath()
            }

            If($O.OutputFormat){

                $ParsExport.OutputFormat = $o.OutputFormat
            }
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

    [Void]GetClassObjects(){
        If($this.Path){
            $item = Get-Item $this.Path
            Switch($item.GEtType().FullName){

                ("System.IO.FileInfo"){
                    $this.Objects = Get-CUClass -path $item.FullName
                    ;Break
                }
                ("System.IO.DirectoryInfo"){
                    $h = @{}
                    if($this.Options.Recurse){
                        $h.recurse = $true
                    }
                    $h.path = $Item.FullName
                    $this.Objects = Get-ChildItem -path @h | Get-CUClass
                    ;Break
                } 
            }

            If($this.Options.Only){
                $this.Objects = $this.Objects | ? {$_.Name -in $Only}
            }elseif($this.Options.Exclude){
                $this.Objects = $this.Objects | ? {$_.Name -NotIn $Exclude}
            }
        }
    }
}



