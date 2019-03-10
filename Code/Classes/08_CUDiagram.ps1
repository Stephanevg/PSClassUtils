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

            $this.Graph = "GRAPH HERE"
        }Else{
            throw "Add classes or Enums"
        }
    }

    CreateDiagram(){
        If(!($this.Graph)){
            Throw "Create a graph first using CreateGraph"
        }
    }

}