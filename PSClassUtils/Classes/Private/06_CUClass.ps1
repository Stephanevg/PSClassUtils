Class CUClass {
    [String]$Name
    [CUClassProperty[]]$Property
    [ClassConstructor[]]$Constructor
    [CUClassMethod[]]$Method
    [Bool]$IsInherited = $False
    [String]$ParentClassName
    [System.IO.FileInfo]$Path
    Hidden $Raw
    Hidden $Ast

    CUClass($RawAST){

        $this.Raw = $RawAST
        $this.Ast = $this.Raw.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
        $This.SetPropertiesFromRawAST()

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
    

    ## Set Name, and call Other Set
    [void] SetPropertiesFromRawAST(){

        $This.Name = $This.Ast.Name
        $This.Path = [System.IO.FileInfo]::new($This.Raw.Extent.File)
        $This.SetConstructorFromAST()
        $This.SetPropertyFromAST()
        $This.SetMethodFromAST()
        
        ## Inheritence Check
        If ( !($null -eq $This.Ast.BaseTypes) ) {
            $This.IsInherited = $True
            $This.ParentClassName = $This.Ast.BaseTypes.TypeName.Name
        }

    }

    ## Find Constructors for the current Class
    [void] SetConstructorFromAST(){
        
        $Constructors = $null
        $Constructors = $This.Ast.Members | Where-Object {$_.IsConstructor -eq $True}

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

            $This.Constructor += [ClassConstructor]::New($This.name,$Constructor.Name, $Paras,$Constructor)
        }

    }

    ## Find Methods for the current Class
    [void] SetMethodFromAST(){

        $Methods = $null
        $Methods = $This.Ast.Members | Where-Object {$_.IsConstructor -eq $False}

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

        $Properties = $This.Ast.Members | Where-Object {$_ -is [System.Management.Automation.Language.PropertyMemberAst]} 

        If ($Properties) {
        
            Foreach ( $Pro in $Properties ) {
                
                If ( $Pro.IsHidden ) {
                    $Visibility = "Hidden"
                } Else {
                    $visibility = "public"
                }
            
                #$This.Property += [CUClassProperty]::New($This.Name,$pro.Name, $pro.PropertyType.TypeName.Name, $Visibility,$Pro)
                $This.Property += [CUClassProperty]::New($This.Name,$pro.Name, $pro.PropertyType.TypeName.Name, $Visibility)
            }
        }

    }

    ## Return the content of Constructor
    [ClassConstructor[]]GetCuClassConstructor(){

        return $This.Constructor
        
    }

    ## Return the content of Method
    [CUClassMethod[]]GetCuCUClassMethod(){

        return $This.Method

    }

    ## Return the content of Property
    [CUClassProperty[]]GetCuCUClassProperty(){

        return $This.Property

    }

}