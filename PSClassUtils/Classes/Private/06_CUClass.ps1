Class CUClass {
    [String]$Name
    [CUClassProperty[]]$Property
    [CUClassConstructor[]]$Constructor
    [CUClassMethod[]]$Method
    [Bool]$IsInherited = $False
    [String]$ParentClassName
    [System.IO.FileInfo]$Path
    Hidden $Raw
    #Hidden $Ast

    CUClass($AST){

        #$this.Raw = $RawAST
        $this.Raw = $AST
        $This.SetPropertiesFromAST()

    }

    CUClass ($Name,$Property,$Constructor,$Method){

        $This.Name = $Name
        $This.Property = $Property
        $This.Constructor = $Constructor
        $This.Method = $Method

    }

    CUClass ($Name,$Property,$Constructor,$Method,$AST){

        $This.Name = $Name
        $This.Property = $Property
        $This.Constructor = $Constructor
        $This.Method = $Method
        $This.Raw = $AST

    }
    

    ## Set Name, and call Other Set
    [void] SetPropertiesFromAST(){

        $This.Name = $This.Raw.Name
        $This.Path = [System.IO.FileInfo]::new($This.Raw.Extent.File)
        $This.SetConstructorFromAST()
        $This.SetPropertyFromAST()
        $This.SetMethodFromAST()
        
        ## Inheritence Check
        If ( $This.Raw.BaseTypes ) {
            $This.IsInherited = $True
            $This.ParentClassName = $This.Raw.BaseTypes.TypeName.Name
        }

    }

    ## Find Constructors for the current Class
    [void] SetConstructorFromAST(){
        
        $Constructors = $null
        $Constructors = $This.Raw.Members | Where-Object {$_.IsConstructor -eq $True}

        Foreach ( $Constructor in $Constructors ) {

            $Parameters = $null
            $Parameters = $Constructor.Parameters
            [CUClassParameter[]]$Paras = @()

            If ( $Parameters ) {
                
                Foreach ( $Parameter in $Parameters ) {

                    $Type = $null
                    # couldn't find another place where the returntype was located. 
                    # If you know a better place, please update this! I'll pay you beer.
                    $Type = $Parameter.Extent.Text.Split("$")[0] 
                    $Paras += [CUClassParameter]::New($Parameter.Name.VariablePath.UserPath, $Type)
        
                }

            }

            $This.Constructor += [CUClassConstructor]::New($This.name,$Constructor.Name, $Paras,$Constructor)
        }

    }

    ## Find Methods for the current Class
    [void] SetMethodFromAST(){

        $Methods = $null
        $Methods = $This.Raw.Members | Where-Object {$_.IsConstructor -eq $False}

        Foreach ( $Method in $Methods ) {

            $Parameters = $null
            $Parameters = $Method.Parameters
            [CUClassParameter[]]$Paras = @()

            If ( $Parameters ) {
                
                Foreach ( $Parameter in $Parameters ) {

                    $Type = $null
                    # couldn't find another place where the returntype was located. 
                    # If you know a better place, please update this! I'll pay you beer.
                    $Type = $Parameter.Extent.Text.Split("$")[0] 
                    $Paras += [CUClassParameter]::New($Parameter.Name.VariablePath.UserPath, $Type)
        
                }

            }

            $This.Method += [CUClassMethod]::New($This.Name,$Method.Name, $Method.ReturnType, $Paras,$Method)
        }

    }

    ## Find Properties for the current Class
    [void] SetPropertyFromAST(){

        $Properties = $This.Raw.Members | Where-Object {$_ -is [System.Management.Automation.Language.PropertyMemberAst]} 

        If ($Properties) {
        
            Foreach ( $Pro in $Properties ) {
                
                If ( $Pro.IsHidden ) {
                    $Visibility = "Hidden"
                } Else {
                    $visibility = "public"
                }
            
                $This.Property += [CUClassProperty]::New($This.Name,$pro.Name, $pro.PropertyType.TypeName.Name, $Visibility,$Pro)
            }
        }

    }

    ## Return the content of Constructor
    [CUClassConstructor[]]GetCUClassConstructor(){

        return $This.Constructor
        
    }

    ## Return the content of Method
    [CUClassMethod[]]GetCUClassMethod(){

        return $This.Method

    }

    ## Return the content of Property
    [CUClassProperty[]]GetCUClassProperty(){

        return $This.Property

    }

}