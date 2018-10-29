Class CUClass {
    [String]$Name
    [ClassProperty[]]$Property
    [ClassConstructor[]]$Constructor
    [ClassMethod[]]$Method
    Hidden $Raw
    Hidden $Ast

    CUClass($RawAST){
        $this.Raw = $RawAST
        $this.Ast = $this.Raw.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
        $This.SetPropertiesFromRawAST($this.Raw)
    }

    CUClass ($Name,$Property,$Constructor,$Method){
        $This.Name = $Name
        $This.Property = $Property
        $This.Constructor = $Constructor
        $This.Method = $Method
    }
    CUClass ($Name,$Property,$Constructor,$Method,$RawAST){
        $This.Name = $Name
        $This.Property = $Property
        $This.Constructor = $Constructor
        $This.Method = $Method
        $This.Raw = $RawAST
    }

    [void] SetPropertiesFromRawAST($RawAST){
        $this.Name = $RawAST.Name
        ## remplacer par: SetConstructorsFromRawAST !!!! c est ça que je trouve chelouuUUuu!
        #$this.Constructor = Get-CUClassConstructor -ClassName $this.Name -InputObject $RawAST
        $this.Method = Get-CUClassMethod -InputObject $RawAST -ClassName $this.Name # ?
        #En faite, au sein de la class, CUClass, comme c'est la base de toutes les class (un peu comme l'anneau unique) Il vaut mieux ne pas la rendre dépendante d'autres cmdlets
        # J'ai eu ça une fois sur un module xunitxml quq javais ecris. Et finalement, j'avais une dependance circulaire. Apres, pour loader les classes ct chaud, car tu dois les loader dans l'ordre
        #Et si elle dependent l'une de l'autre, c'est caca.
        #C#a#r si on laisse Get-CUClassMEthod ici, ben Get-CUClassMEthod elle fais quoi? $obj = Get-CUClass -ClassName; $obj.Method , tu te rapelles?
        #Dependence circulaire ! 
        ##mais oui c'est exactement ça qui me turlupinait!
        #lol, on a ecris bien plus de commentaires que de code finalement :D

        # t enocore la? dsl ma ptite pleure c galère !
        $this.Property = Get-CUClassProperty -InputObject $RawAST -ClassName $this.Name
        $this.SetConstructorsFromRawAST()

    }

    #du coup j'ai fait ça 
    [void] SetConstructorsFromRawAST(){
        $Constructors = $null
        $Constructors = $this.Ast | ? {$_.IsConstructor -eq $true}
        foreach ( $Constructor in $Constructors){
            $Parameters = $null
            $Parameters = $Constructor.Parameters
            [ClassProperty[]]$Paras = @()
            If ($Parameters) {
                
                foreach ($Parameter in $Parameters) {
                    $Type = $null
                    # couldn't find another place where the returntype was located. 
                    # If you know a better place, please update this! I'll pay you beer.
                    $Type = $Parameter.Extent.Text.Split("$")[0] 
                    $Paras += [ClassProperty]::New($Parameter.Name.VariablePath.UserPath, $Type)
        
                }

            }
            #[ClassConstructor]::New($Constructor.Name, $Constructor.ReturnType, $Paras,$Constructor)
            $This.Constructor += [ClassConstructor]::New($Constructor.Name, $Constructor.ReturnType, $Paras,$Constructor)
        }
    }

    [void] SetMethodFromRawAST(){
##du coup regarde
    }

    [void] SetPropertyFromRawAST(){

    }

    [ClassMethod[]]GetCuClassMethod(){

        return $this.Method
    }

    [ClassMethod[]]GetCuClassMethod([]){

        return $this.Method
    }

    #>
    #Mais c'est exactement ce que je pensais aussi. Je te l'a meme ecris lol
    #Just avant ta gamere
    <#
        MAi oui effectivement, cela fais bcp plus de sense comme ça
        
    #>
    #lol! j'ai rien pigé!
}