#Generated at 03/10/2019 21:20:24 by Stephane van Gulick
#Needed for 07_CUInterfaceAuthor

using namespace System.Collections.Generic
using namespace System.Reflection
Class CUClassParameter {
    [String]$Name
    [String]$Type
    hidden $Raw

    CUClassParameter([String]$Name,[String]$Type){

        $this.Name = $Name
        $This.Type = $Type

    }

    CUClassParameter([String]$Name,[String]$Type,$Raw){

        $this.Name = $Name
        $This.Type = $Type
        $this.Raw = $Raw

    }
}
Class CUClassProperty {
    [String]$ClassName
    [String]$Name
    [String]$Type
    [string]$Visibility
    Hidden $Raw

    CUClassProperty([String]$ClassName,[String]$Name,[String]$Type){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type

    }

    CUClassProperty([String]$ClassName,[String]$Name,[String]$Type,[String]$Visibility){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type
        $this.Visibility = $Visibility

    }

    CUClassProperty([String]$ClassName,[String]$Name,[String]$Type,[String]$Visibility,$Raw){

        $this.ClassName = $ClassName
        $this.Name = $Name
        $this.Type = $Type
        $this.Visibility = $Visibility
        $this.Raw = $Raw

    }
}
Class CUClassMethod {
    [String]$ClassName
    [String]$Name
    [String]$ReturnType
    [CUClassParameter[]]$Parameter
    hidden $Raw
    [Bool]$Static
    

    CUClassMethod([String]$ClassName,[String]$Name,[String]$ReturnType,[CUClassParameter[]]$Parameter){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Parameter = $Parameter
    }

    CUClassMethod([String]$ClassName,[String]$Name,[String]$ReturnType,[CUClassParameter[]]$Parameter,$Raw){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.ReturnType = $ReturnType
        $This.Parameter = $Parameter
        $This.Raw = $Raw
        
    }

    SetIsStatic([Bool]$IsStatic){
        $this.Static = $IsStatic
    }

    [Bool] IsStatic(){
        return $this.Static
    }

}
Class CUClassConstructor {
    [String]$ClassName
    [String]$Name
    [CUClassParameter[]]$Parameter
    hidden $Raw
    #hidden $Extent

    CUClassConstructor([String]$ClassName,[String]$Name,[CUClassParameter[]]$Parameter){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.Parameter = $Parameter
    }

    CUClassConstructor([String]$ClassName,[String]$Name,[CUClassParameter[]]$Parameter,$Raw){
        $this.ClassName = $ClassName
        $this.Name = $Name
        $This.Parameter = $Parameter
        $This.Raw = $Raw
        #$This.Extent = $Raw.Extent.Text
    }

}
Class ASTDocument {
    [System.Management.Automation.Language.StatementAst[]]$Classes
    [System.Management.Automation.Language.StatementAst[]]$Enums
    $Source
    $ClassName
    Hidden $Raw

    ASTDocument ([System.Management.Automation.Language.StatementAst[]]$Classes,[System.Management.Automation.Language.StatementAst[]]$Enums,$Source){
        $This.Classes = $Classes
        $This.Enums = $Enums
        $This.Source = $Source
        $This.ClassName = $Classes.Name
    }

    ASTDocument([System.Management.Automation.Language.StatementAst[]]$Classes,[System.Management.Automation.Language.StatementAst[]]$Enums,$Source,[System.Management.Automation.Language.ScriptBlockAst]$RawAST){
        $This.Classes = $Classes
        $This.Enums = $Enums
        $This.Source = $Source
        $This.ClassName = $Classes.Name
        $This.Raw = $RawAST
    }
}
Class ClassEnum {

    [String]$Name
    [String[]]$Member

    ClassEnum([String]$Name,[String[]]$Member){
        $this.Name = $Name
        $this.Member = $Member
    }
}
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

            $M = [CUClassMethod]::New($This.Name,$Method.Name, $Method.ReturnType, $Paras,$Method)
            $M.SetIsStatic($Method.IsStatic)
            
            $This.Method += $M
            $M = $null
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

class CUInterfaceAuthor
{
    hidden [List[PropertyInfo]] $_properties
    hidden [List[MethodInfo]] $_methods

    [List[Type]]$Interfaces

    CUInterfaceAuthor([string]$Name,[type]$Interface)
    {
        $this.Interfaces = [List[type]]::new()
        $this.Interfaces.Add($Interface)
        $this.Interfaces.AddRange($Interface.GetInterfaces())

        $this._properties = [List[PropertyInfo]]::new()
        $this._methods = [List[MethodInfo]]::new()

        foreach($iface in $this.Interfaces){
            $this._properties.AddRange($iface.GetProperties())
            $this._methods.AddRange($iface.GetMethods())
        }
    }

    [string]
    GetPropertySection()
    {
        $sb = [System.Text.StringBuilder]::new()
        foreach($property in $this._properties){
            $sb = $sb.AppendFormat('  [{0}]${1}', $property.PropertyType, $property.Name).AppendLine()
        }

        return $sb.ToString()
    }

    [string]
    GetMethodSection()
    {
        $sb = [System.Text.StringBuilder]::new()
        foreach($method in $this._methods |? Name -notmatch '^(g|s)et_'){
            $sb = $sb.AppendFormat("  [{0}]{1}  {2}({3}){1}  {{{1}    throw '{2} not implemented '{1}  }}", $method.ReturnType, [Environment]::NewLine, $method.Name, ($method.GetParameters().ForEach({'[{0}]${1}' -f $_.ParameterType,$_.Name}) -join ', ')).AppendLine().AppendLine()
        }

        return $sb.ToString()
    }
}

Enum PesterType {
    It
    Describe
    Context
}
Class PesterItBlock{
    [String]$Name
    [String]$Value
    [PesterType]$Type
    [String]$Content
    [HashTable]$TestCases
    [Bool]$Pending = $false
    [Bool]$Skipped = $False

    PesterITBlock([String]$Name,[String]$Value,[PesterType]$Type,[String]$Content,[HashTable]$TestCases){
        $this.Name = $Name
        $this.Value = $Value
        $this.Type = $Type
        $this.Content = $Content
        $This.TestCases = $TestCases
    }

    SetPending([Bool]$IsPending){
        $this.Pending = $IsPending
    }

    [Bool] IsPending(){
        return $This.Pending
    }

    SetSkipped([Bool]$IsSkipped){
        $this.Pending = $IsSkipped
    }

    [Bool] IsSkipped(){
        return $This.Skipped
    }

}
Class PesterDescribeBlock {
    [String]$Name
    [PesterItBlock[]]$ItBlocks
    [PesterType]$Type
    [String]$Fixture
    [String[]]$Tags

    PesterDescribeBlock([String]$Name,[PesterItBlock[]]$ItBlocks,[PesterType]$Type,[String]$Fixture,[String[]]$Tags){
        $this.Name = $Name
        $this.ItBlocks = $ItBlocks
        $this.Type = $Type
        $this.Fixture = $Fixture
        $This.Tags = $Tags
    }
}

Class PesterScript {
    [System.IO.FileInfo]$path
    [PesterDescribeBlock[]]$DescribeBlocks

    PesterScript([System.Io.FileInfo]$Path){
        $this.Path = $Path
        $This.DescribeBlocks = Get-CUPesterDescribeBlock -Path $This.path.FullName
    }
}
Function ConvertTo-titleCase {
    [CmdletBinding()]
    Param(
        [String]$String
    )

    $TextInfo = (Get-Culture).TextInfo
    return $TextInfo.ToTitleCase($string)
}
function Find-CUClass {
    <#
    .SYNOPSIS
        Helper function to find classes, based on a path, Wraps Get-CuClass, return a Microsoft.PowerShell.Commands.GroupInfo object
    .DESCRIPTION
        Helper function to find classes, based on a path, Wraps Get-CuClass, return a Microsoft.PowerShell.Commands.GroupInfo object
    .NOTES
        Private function for PSClassUtils, used in Write-CUClassDiagram
    #>

    Param (
        $Item,
        $Exclude
    )

    If ( $Exclude ) {
        Write-Verbose "Find-CUClass -> Exclude Parameter Specified... $($Exclude.count) items to filter..."

        If ( $Exclude.Count -eq 1 ) {
            Get-ChildItem -path $item -Include '*.ps1', '*.psm1' | Get-CUCLass | Where-Object Name -NotLike $Exclude |  Group-Object -Property Path
        }

        If ( $Exclude.Count -gt 1 ) {
            Get-ChildItem -path $item -Include '*.ps1', '*.psm1' | Get-CUCLass | Where-Object Name -NotIn $Exclude |  Group-Object -Property Path
        }

    } Else {
        Write-Verbose "Find-CUClass -> Exclude Parameter NOT Specified..."
        Get-ChildItem -path $item -Include '*.ps1', '*.psm1' | Get-CUCLass | Group-Object -Property Path
    }
}
Function Get-CUAst {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True,ValueFromPipeline = $true)]
        [Alias('FullName')]
        [System.IO.FileInfo[]]$Path
    )
    
    begin {}
    
    process {
        foreach($p in $Path){

            Write-Verbose "Current file $p"
            If ( $P.Extension -in '.ps1','.psm1') {
                Write-Verbose "Current file $p is a PS1 or PSM1 file..."
                $Raw = [System.Management.Automation.Language.Parser]::ParseFile($p.FullName, [ref]$null, [ref]$Null)
                $AST = $Raw.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)

                ## If AST Count -gt 1 we need to retourn each one of them separatly
                Switch ($AST.count) {
                    
                    { $AST.count -eq 1 } {
                        Write-Verbose "Current file $p contains 1 AST..."
                        $AST
                    }

                    { $AST.count -gt 1 } {
                        Write-Verbose "Current file $p contains $($ast.count) AST..."
                        Foreach ( $x in $AST ) {
                            $x
                        }
                    }

                    Default {
                        Write-Verbose "Current file $p contains $($ast.count) AST..."
                    }
                }
            } Else {
                Write-Verbose "Current file $p is not a PS1 or PSM1 file..."
            }
        }
    }
    
    end {
    }
}

function New-CUGraphExport {
    <#
    .SYNOPSIS
        Helper function to generate a Graph export file, wraps Export-PSGraph.
    .DESCRIPTION
        Helper function to generate a Graph export file , wraps Export-PSGraph.
    .NOTES
        Private function for PSClassUtils, used in Write-CUClassDiagram
    #>

    param (
        $Graph,
        $PassThru,
        $Path,
        $ChildPath,
        $OutPutFormat,
        [Switch]$Show
    )
    
    $ExportParams = @{
        ShowGraph = $Show
        OutPutFormat = $OutPutFormat
        DestinationPath = Join-Path -Path $Path -ChildPath ($ChildPath+'.'+$OutPutFormat)
    }
    
    If ( $PassThru ) {
        $Graph
        $null = $Graph | Export-PSGraph @ExportParams
    } Else {
        $Graph | Export-PSGraph @ExportParams
    }

}
function New-CUGraphParameters {
    <#
    .SYNOPSIS
        Helper function to generate a Graph, wrap Out-CUPSGraph.
    .DESCRIPTION
        Helper function to generate a Graph, wrap Out-CUPSGraph.
    .NOTES
        Private function for PSClassUtils, used in Write-CUClassDiagram
    #>

    Param (
        $inputobject,
        $ignorecase,
        $showcomposition
    )

    $GraphParams = @{
        InputObject = $inputobject
    }

    If ( $ignorecase ) { $GraphParams.Add('IgnoreCase',$ignorecase) }
    If ( $showcomposition ) { $GraphParams.Add('ShowComposition',$showcomposition) }

    Out-CUPSGraph @GraphParams
    
}
Function Out-CUPSGraph {
    <#
    .SYNOPSIS
        Generates the graph output. It requires input from Get-CUAST (input of type ASTDOcument)
    .DESCRIPTION
        This function is based on psgraph, which wih is a module to generate diagrams using GraphViz. If psgraph is not present, it will throw.
    .EXAMPLE
        
        
    .INPUTS
        Pipeline input from a ASTDocument Object
    .OUTPUTS
        Output (if any)


    .PARAMETER InputObject
    This parameter expects an array of ASTDocument. (Can be generated using Get-CUAST).


    .PARAMETER IgnoreCase

    If there is a difference in the casesensitivity of the a parent class, and it's child class, drawing the inheritence might not work as expected.
    Forcing the case sensitivy to be everywhere the same when creating the objects in PSGraph resolves this issue (See issue here -> https://github.com/KevinMarquette/PSGraph/issues/68 )
    Using -IgnoreCase will force all class names to be set to 'TitleCase', reglardless of the case sensitivity they had before.

    .NOTES
        version: 1.1
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
        [Object[]]$inputObject,


        [Parameter(Mandatory = $False)]
        [Switch]
        $IgnoreCase,

        $ShowComposition


    )
    
    begin {
        Write-Verbose "Out-CUPSGraph -> BEGIN BLOCK..."
        $AllGraphs = @()
        if(!(Get-Module -Name PSGraph)){
            #Module is not loaded
            if(!(get-module -listavailable -name psgraph )){
                #Module is not present
                throw "The module PSGraph is a prerequisite for this function to work. Please Install PSGraph first (You can use Install-CUDiagramPrerequisites to install them.)"
            }else{
                Import-Module psgraph -Force
            }
        }
    }
    
    process {
        Write-Verbose "Out-CUPSGraph -> PROCESS BLOCK..."
        [System.Collections.ArrayList]$AllClasses = @()
        #$Graph = Graph -Attributes @{splines='ortho'} -ScriptBlock {
        $Graph = Graph -ScriptBlock {
            foreach($obj in $inputObject){
                $CurrName = split-Path -leaf $obj.Name
                subgraph -Attributes @{label=($CurrName)} -ScriptBlock {
                        Foreach( $Class in $obj.Group ) {

                            If($IgnoreCase){
                                $RecordName = ConvertTo-TitleCase -String $Class.Name
                            }else{

                                $RecordName = $Class.Name
                            }
                            #Adding className for futur use to identify composition

                            $null = $AllClasses.Add($RecordName) # It needs to set to null to avoid to have 'numbers' as random points in the graph
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
                                            write-verbose "[Property][Row]Label:$($n) - Name: Row_$($pro.Name)"
                                            Row -label "$($n)"  -Name "Row_$($pro.Name)"
                                        }
                                        else {
                                            #$pro.name
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
                                    #Write-Host $Methods.Count
                                    #$i=0
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
                                        
                                        If($mem.IsStatic()){
                                            
                                            $RowName = "{0} {1} {2}" -f $visibility,"static",$RowName
                                        }else{
                                            $RowName = "{0} {1}" -f $visibility,$RowName
                                            
                                        }

                                        Row $RowName -Name "Row_$($mem.Name)"

                                    }
                                }
                        
                            }#End Record
                        }#end foreach Class
        
                    }#End SubGraph
                
                ## InHeritance
                Foreach ($class in ($Obj.Group | where-Object IsInherited)){
                    If($IgnoreCase){
                        $Parent = ConvertTo-TitleCase -String $Class.ParentClassName
                        $Child = ConvertTo-TitleCase -String $Class.Name
                    }else{

                        $Parent = $Class.ParentClassName
                        $Child = $Class.Name
                    }
                    edge -From $Parent -To $Child -Attributes @{arrowhead="empty"}
                }

                ##Composition

                if($ShowComposition){
                    Write-Verbose "Out-CUPSGraph -> ShowCoposition"
                    #foreach class.Property.Type if in list of customClasses, then it is composition
                    ## replace brackets when property type is an array of type
                    Foreach($ClassProperty in $obj.group.property){
                        #if( $AllClasses -contains $ClassProperty.type ){
                        if( $AllClasses -contains ($ClassProperty.type -replace '\[\]','') ){    
                            write-verbose "Out-CUPSGraph -> Composition relationship found:"
                            #CompositionFound
                            Write-Verbose "Out-CUPSGraph -> Composition: $($ClassProperty.Name):Row_$($ClassProperty.Name) to $($ClassProperty.Type)"
                            edge -From ($ClassProperty.type -replace '\[\]','') -To "$($ClassProperty.className):Row_$($ClassProperty.Name -replace '\[\]','')" -Attributes @{arrowhead='diamond'}
                        }
                    }
                }
            }
        
        }

        $AlLGraphs += $Graph
    }
    
    end {
        Write-Verbose "Out-CUPSGraph -> END BLOCK..."
        Write-Verbose "Out-CUPSGraph -> END BLOCK: return graphs..."
        Return $AlLGraphs
        
    
    }
}
function Get-CUClass {
    <#
    .SYNOPSIS
        This function returns all classes, loaded in memory or present in a ps1 or psm1 file.
    .DESCRIPTION
        By default, the function will return all loaded classes in the current PSSession.
        You can specify a file path to explore the classes present in a ps1 or psm1 file.
    .PARAMETER ClassName
        Specify the name of the class.
    .PARAMETER Path
        The path of a file containing PowerShell Classes. Accept values from the pipeline.
    .PARAMETER Raw
        The raw switch will display the raw content of the Class.
    .EXAMPLE
        PS C:\> Get-CUClass
        Return all classes alreay loaded in current PSSession.
    .EXAMPLE
        PS C:\> Get-CUClass -ClassName CUClass
        Return the particuluar CUCLass.
    .EXAMPLE
        PS C:\> Get-CUClass -Path .\test.psm1,.\test2.psm1
        Return all classes present in the test.psm1 and test2.psm1 file.
    .EXAMPLE
        PS C:\> Get-CUClass -Path .\test.psm1 -ClassName test
        Return test class present in the test.psm1 file.
    .EXAMPLE
        PS C:\PSClassUtils> Get-ChildItem -recurse | Get-CUClass
        Return all classes, recursively, present in the C:\PSClassUtils Folder.
    .INPUTS
        Accepts type [System.IO.FileInfo]
    .OUTPUTS
        Return type [CuClass]
    .NOTES
        Author: StÃ©phane van Gulick
        Participate & contribute --> https://github.com/Stephanevg/PSClassUtils
    #>


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        $ClassName,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path,
        
        [Parameter(Mandatory = $False)]
        [Switch]$Raw = $False
    )

    BEGIN {
    }

    PROCESS {
        
        If ( ($Null -eq $PSBoundParameters['Path']) -And ($PSVersionTable.PSEdition -eq 'Core' ) ) {
            Throw 'This feature is not supported on PSCore, due to missing DotNet libraries. Please use -Path instead...'
        }

        $ClassParams = @{}

        If ( $Null -ne $PSBoundParameters['ClassName'] ) {
            $ClassParams.ClassName = $PSBoundParameters['ClassName']
        }

        If ( $Null -ne $PSBoundParameters['Path'] ) {

            Foreach ( $Path in $PSBoundParameters['Path'] ) {

                If ( $Path.Extension -in '.ps1', '.psm1') {
                    If ($PSCmdlet.MyInvocation.ExpectingInput) {
                        $ClassParams.Path = $Path.FullName
                    } Else {
                        $ClassParams.Path = (Get-Item (Resolve-Path $Path).Path).FullName
                    }
            
                    $Ast = Get-CUAst -Path $ClassParams.Path
                    Foreach ( $x in $Ast ) {
                        If(!($x.IsEnum)){

                            If ( $PSBoundParameters['ClassName'] ) {
                                If ( $x.name -eq $PSBoundParameters['ClassName'] ) {
                                    If ( $PSBoundParameters['Raw'] ) {
                                        ([CUClass]::New($x)).Raw
                                    } Else {
                                        [CUClass]::New($x)
                                    }
                                }
                            } Else {
                                If ( $PSBoundParameters['Raw'] ) {
                                    ([CUClass]::New($x)).Raw
                                } Else {
                                    [CUClass]::New($x)
                                }
                            }
                        }
                    }

                }
            }

        } Else {
            
            Foreach ( $x in (Get-CULoadedClass @ClassParams ) ) {

                If ( $PSBoundParameters['ClassName'] ) {
                    If ( $x.name -eq $PSBoundParameters['ClassName'] ) {
                        If ( $PSBoundParameters['Raw'] ) {
                            ([CUClass]::New($x)).Raw
                        } Else {
                            [CUClass]::New($x)
                        }
                    }
                } Else {
                    If ( $PSBoundParameters['Raw'] ) {
                        ([CUClass]::New($x)).Raw
                    } Else {
                        [CUClass]::New($x)
                    }
                }
                
            } 
        }
    }

    END {}  
}
  
Function Get-CUClassConstructor {
    <#
    .SYNOPSIS
        This function returns all existing constructors of a specific powershell class.
    .DESCRIPTION
        This function returns all existing constructors of a specific powershell class. You can pipe the result of get-cuclass. Or you can specify a file to get all the constructors present in this specified file.
    .PARAMETER ClassName
        Specify the name of the class.
    .PARAMETER Path
        The path of a file containing PowerShell Classes. Accept values from the pipeline.
    .PARAMETER Raw
        The raw switch will display the raw content of the Class.
    .PARAMETER InputObject
        An object, or array of object of type CuClass
    .EXAMPLE
        PS C:\> Get-CUClassConstructor
        Return all the constructors of the classes loaded in the current PSSession.
    .EXAMPLE
        PS C:\> Get-CUClassConstructor -ClassName woop
        ClassName Name    Parameter
        --------- ----    ---------
        woop    woop
        woop    woop       {String, Number}
        Return constructors for the woop Class.
    .EXAMPLE
        PS C:\> Get-CUClassConstructor -Path .\Woop.psm1
        ClassName Name    Parameter
        --------- ----    ---------
        woop    woop
        woop    woop       {String, Number}
        Return constructors for the woop Class present in the woop.psm1 file.
    .EXAMPLE
        PS C:\PSClassUtils> Gci -recurse | Get-CUClassConstructor -ClassName CuClass
        ClassName Name    Parameter
        --------- ----    ---------
        CUClass   CUClass {RawAST}
        CUClass   CUClass {Name, Property, Constructor, Method}
        CUClass   CUClass {Name, Property, Constructor, Method...}
        Return constructors for the CUclass Class present somewhere in the c:\psclassutils folder.
    .INPUTS
        String
    .OUTPUTS
        ClassConstructor
    .NOTES   
        Author: StÃ©phane van Gulick
        Version: 0.7.1
        www.powershellDistrict.com
        Report bugs or submit feature requests here:
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding(DefaultParameterSetName="All")]
    [OutputType([CUClassMethod[]])]
    Param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set1")]
        [CUClass[]]$InputObject,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set2",ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path,

        [Switch]$Raw

    )

    BEGIN {}

    PROCESS {

        Switch ( $PSCmdlet.ParameterSetName ) {

            ## CUClass as input
            Set1 {

                $ClassParams = @{}
                
                ## ClassName was specified
                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $Class in $InputObject ) {
                    If ( $ClassParams.ClassName ) {
                        If ( $Class.Name -eq $ClassParams.ClassName ) {
                            if($Raw){
                                $Class.GetCUClassConstructor().Raw
                            }Else{

                                $Class.GetCUClassConstructor()
                            }
                        }
                    } Else {
                        If ( $null -ne $Class.Constructor ) {
                            if($Raw){
                                $Class.GetCUClassConstructor().Raw
                            }Else{

                                $Class.GetCUClassConstructor()
                            }
                        }
                    }
                }
            }

            Set2 {

                $ClassParams = @{}

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $P in $Path ) {
                   
                    If ( $P.extension -in ".ps1",".psm1" ) {

                        If ( $PSCmdlet.MyInvocation.ExpectingInput ) {
                            $ClassParams.Path = $P.FullName
                        } Else {
                            $ClassParams.Path = (Get-Item (Resolve-Path $P).Path).FullName
                        }
                        
                        $Class=Get-CuClass @ClassParams
                        If ( $null -ne $Class.Constructor ) {
                            if($Raw){
                                $Class.GetCUClassConstructor().Raw
                            }Else{

                                $Class.GetCUClassConstructor()
                            }
                            
                        }
                    }
                }
            }

            Default {
                $ClassParams = @{}

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach($Class in (Get-CuClass @ClassParams)) {
                    If ( $Class.Constructor.count -ne 0 ) {
                        If ( $Raw ) {
                            $Class.GetCUClassConstructor().Raw
                        } Else {

                            $Class.GetCUClassConstructor()
                        }
                        
                    }
                }
                
                
            }
        }

    }

    END {}

}
Function Get-CUClassMethod {
    <#
    .SYNOPSIS
        This function returns all existing constructors of a specific powershell class.
    .DESCRIPTION
        This function returns all existing constructors of a specific powershell class. You can pipe the result of get-cuclass. Or you can specify a file to get all the constructors present in this specified file.
    .PARAMETER ClassName
        Specify the name of the class.
    .PARAMETER MethodName
        Specify the name of a specific Method
    .PARAMETER Path
        The path of a file containing PowerShell Classes. Accept values from the pipeline.
    .PARAMETER Raw
        The raw switch will display the raw content of the Class.
    .PARAMETER InputObject
        An object, or array of object of type CuClass
    .EXAMPLE
        PS C:\> Get-CUClassMethod
        Return all the methods of the classes loaded in the current PSSession.
    .EXAMPLE
        PS C:\> Get-CUClassMethod -ClassName woop
        ClassName Name    Parameter
        --------- ----    ---------
        woop    woop
        woop    woop       {String, Number}
        Return methods for the woop Class.
    .EXAMPLE
        PS C:\> Get-CUClassMethod -Path .\Woop.psm1
        ClassName Name    Parameter
        --------- ----    ---------
        woop    woop
        woop    woop       {String, Number}
        Return methods for the woop Class present in the woop.psm1 file.
    .EXAMPLE
        PS C:\PSClassUtils> Gci -recurse | Get-CUClassMethod -ClassName CuClass
        ClassName Name    Parameter
        --------- ----    ---------
        CUClass   CUClass {RawAST}
        CUClass   CUClass {Name, Property, Constructor, Method}
        CUClass   CUClass {Name, Property, Constructor, Method...}
        Return methods for the CUclass Class present somewhere in the c:\psclassutils folder.
    .INPUTS
        String
    .OUTPUTS
        CUClassMethod
    .NOTES   
        Author: StÃ©phane van Gulick
        Version: 0.7.1
        www.powershellDistrict.com
        Report bugs or submit feature requests here:
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding(DefaultParameterSetName="All")]
    [OutputType([CUClassMethod[]])]
    Param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$MethodName='*',

        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set1")]
        [CUClass[]]$InputObject,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set2",ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path,

        [Switch]$Raw
        
    )

    BEGIN {}

    PROCESS {

        Switch ( $PSCmdlet.ParameterSetName ) {

            ## CUClass as input
            Set1 {

                $ClassParams = @{}
                
                ## ClassName was specified
                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $Class in $InputObject ) {
                    If ( $ClassParams.ClassName ) {
                        If ( $Class.Name -eq $ClassParams.ClassName ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($Class.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $Class.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                        }
                    } Else {
                        If ( $null -ne $Class.Method ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($Class.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $Class.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                        }
                    }
                }
            }

            ## System.io.FileInfo as Input
            Set2 {

                $ClassParams = @{}
                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $P in $Path ) {
                    
                    If ( $P.extension -in ".ps1",".psm1" ) {

                        If ($PSCmdlet.MyInvocation.ExpectingInput) {
                            $ClassParams.Path = $P.FullName
                        } Else {
                            $ClassParams.Path = (Get-Item (Resolve-Path $P).Path).FullName
                        }
                        
                        $x=Get-CuClass @ClassParams
                        If ( $null -ne $x.Method ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($x.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $x.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                            
                        }
                    }
                }
            }

            ## System.io.FileInfo or Path Not Specified
            Default {
                $ClassParams = @{}

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }
                
                Foreach( $x in (Get-CuClass @ClassParams) ){
                    If ( $x.Method.count -ne 0 ) {
                        If ( $PSBoundParameters['Raw'] ) {
                                
                            ($x.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                        } Else {
                            $x.GetCUClassMethod() | Where-Object Name -like $MethodName
                        }
                    }
                }
                
                
            }
        }

    }

    END {}

}
Function Get-CUClassProperty {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [cmdletBinding()]
    Param(
        [Alias("FullName")]
        [Parameter(ParameterSetName = "Path", Position = 1, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [System.IO.FileInfo[]]$Path,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(ValueFromPipeline=$True)]
        [ValidateScript({
            If ( !($_.GetType().Name -eq "CUClass" ) ) { Throw "InputObect Must be of type CUClass.."} Else { $True }
        })]
        [Object[]]$InputObject,

        [Switch]$Raw
    )

    BEGIN {}

    PROCESS {

        $ClassParams = @{}

        If ($ClassName -or $PSBoundParameters['ClassName'] ) {
            $ClassParams.ClassName = $ClassName
        }

        If ($Path -or $PSBoundParameters['Path'] ) {
            $ClassParams.Path = $Path.FullName
        }

        If ($InputObject) {
            $ClassParams.ClassName = $ClassName
        }

       
        $Class = Get-CuClass @ClassParams
        If ($Class) {

            If($Raw){
                $Class.GetCuClassProperty().Raw
            }else{

                $Class.GetCuClassProperty()
            }
        }

        <# If ( $MyInvocation.PipelinePosition -eq 1 ) {
            ## Not from the Pipeline
            If ( $Null -eq $PSBoundParameters['InputObject'] ) {
                Throw "Please Specify an InputObject of type CUClass"
            }
            If ( $Null -eq $PSBoundParameters['ClassName'] ) {
                $InputObject.GetCuClassProperty()
            } Else {
                Foreach ( $C in $ClassName ){
                    ($InputObject | where Name -eq $c).GetCuClassProperty()
                }
            }

        } Else {
            ## From the Pipeline
            If ( $Null -eq $PSBoundParameters['ClassName'] ) {
                $InputObject.GetCuClassProperty()
            } Else {
                Throw "-ClassName parameter must be specified on the left side of the pipeline"
            }
        }
 #>
    }

    END {}

}
function Get-CUCommands {
    <#
    .SYNOPSIS
        Returns the list of commands available in the PSclassUtils module
    .DESCRIPTION
        All public commands will be returned.
    .EXAMPLE
        Get-CUCommands

    .NOTES
        Author: StÃ©phane van Gulick
        
    #>
    [CmdletBinding()]
    param (
        
    )
    
    return Get-Command -Module PSClassUtils
}
Function Get-CUEnum{
    <#
    .SYNOPSIS
        This function returns enums existing in a document.
    .DESCRIPTION
        Returns a custom type [ClassEnum]
    .EXAMPLE
        Get-CuEnum -Path C:\plop\enum.ps1

        Returns:

        Name Member
        ---- ------
        woop {Absent, Present}

    .INPUTS
        String
    .OUTPUTS
        Classenum
    .NOTES   
        Author: StÃ©phane van Gulick
        Version: 0.2.0
        
    .LINK
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding()]
    Param(
 
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [String[]]
        $Path = (throw "Please provide a path")
    )

   begin{

   }
   Process{

        foreach($p in $Path){

            $AST = Get-cuast -Path $p | ? {$_.IsEnum -eq $True}
     
            foreach($enum in $AST){
                [ClassEnum]::New($enum.Name,$enum.members.Name)
            }
        }
       

   }
   End{

   }
}



function Get-CULoadedClass {
    <#
    .SYNOPSIS
        Return all loaded classes in the current PSSession
    .DESCRIPTION
        Return all loaded classes in the current PSSession
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        String
    .OUTPUTS
        ASTDocument
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [String[]]$ClassName = '*'
    )
    
    BEGIN {
    }
    
    PROCESS {
        
        Foreach ( $Name in $ClassName ) {
            
            [Array]$LoadedClasses = [AppDomain]::CurrentDomain.GetAssemblies() |
                Where-Object { $_.GetCustomAttributes($false) |
                Where-Object { $_ -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute]} } |
                ForEach-Object { 
                    $_.GetTypes() |
                    Where-Object IsPublic | Where-Object { $_.Name -like $Name } |
                    Select-Object @{l = 'Path'; e = {($_.Module.ScopeName.Replace([char]0x29F9, '\').replace([char]0x589, ':')) -replace '^\\', ''}}
            }

            Foreach ( $Class in ($LoadedClasses | Select-Object -Property Path -Unique) ) {
                #Get-CURaw -Path $Class.Path
                Get-CUAst -Path $Class.Path
            }

        }
    }
    
    END {
    }
}
function Get-CURaw {
    <#
    .SYNOPSIS
        Return the raw content of a ps1 or psm1 file as a AST scriptblock type.
    .DESCRIPTION
        Return the raw content of a ps1 or psm1 file as a AST scriptblock type.
    .EXAMPLE
        PS C:\PSClassUtils> Get-CURaw -Path .\Classes\Private\01_ClassProperty.ps1
        Attributes         : {}
        UsingStatements    : {}
        ParamBlock         :
        BeginBlock         :
        ProcessBlock       :
        EndBlock           : Class ClassProperty {
                                [String]$Name
                                [String]$Type

                                ClassProperty([String]$Name,[String]$Type){

                                    $this.Name = $Name
                                    $This.Type = $Type

                                }
                            }
        DynamicParamBlock  :
        ScriptRequirements :
        Extent             : Class ClassProperty {
                                [String]$Name
                                [String]$Type

                                ClassProperty([String]$Name,[String]$Type){

                                    $this.Name = $Name
                                    $This.Type = $Type

                                }
                            }
        Parent             :

        The cmdlet return an AST type representing the content of the 01_ClassProperty.ps1 file
    .INPUTS
        Path of a ps1 or psm1 file
    .OUTPUTS
       ScriptBlockAST
    .NOTES
        Ref: https://mikefrobbins.com/2018/09/28/learning-about-the-powershell-abstract-syntax-tree-ast/ for implementing -raw AST
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(ParameterSetName="Path",Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path
    )
    
    BEGIN{}
    
    PROCESS{

        Foreach ( $P in $Path ) {
            
            If ( $MyInvocation.PipelinePosition -eq 1 ) {
                $P = Get-Item (resolve-path $P).Path
            }

            If ( $P.Extension -in '.ps1','.psm1') {
                #[scriptblock]::Create( $(Get-Content -Path $P.FullName -Raw) ).Ast
                [System.Management.Automation.Language.Parser]::ParseFile($p.FullName, [ref]$null, [ref]$Null)
            }

        }

    }
    
    END{}
}
function Install-CUDiagramPrerequisites {
    <#
    .SYNOPSIS
        This function installs the prerequisites for PSClassUtils.
    .DESCRIPTION   
        Installation of PSGraph
    .EXAMPLE
        Install-CUDiagramPrerequisites
    .EXAMPLE
        Install-CUDiagramPrerequisites -proxy "10.10.10.10" -Scope CurrentUser
    .NOTES   
        Author: Stephanevg
        Version: 2.0
    #>

    [CmdletBinding()]
    param (
        [String]$Proxy,
        [ValidateSet("AllUsers","CurrentUser")][String]$Scope = "AllUsers"       
    )
    
    if(!(Get-Module -Name PSGraph)){
        #Module is not loaded
        if(!(get-module -listavailable -name psgraph )){
            if($proxy){
                write-verbose "Install PSGraph"
                Install-Module psgraph -Verbose -proxy $proxy -Scope $Scope
                Import-Module psgraph -Force
            }else{
                write-verbose "Install PSGraph"
                Install-Module psgraph -Verbose -scope $Scope
                Import-Module psgraph -Force
            }
        }else{
            Import-Module psgraph -Force -Scope $Scope
        }

        Install-GraphViz
    }
}
function Test-IsCustomType {

# Test-PowershellDynamicClass Psobject

# Test-PowershellDynamicClass MyClass

# extrait et adaptÃ© de  https://github.com/PowerShell/PowerShell-Tests

 

 

Param (

   [ValidateNotNullOrEmpty()]

   [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]

  [type] $Type

)

 

Process {

   $attrs = @($Type.Assembly.GetCustomAttributes($true))

     $result = @($attrs | Where { $_  -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute] })

     return ($result.Count -eq 1)

}

}

function Write-CUClassDiagram {
      <#
    .SYNOPSIS
        This script allows to document automatically existing script(s)/module(s) containing classes by generating the corresponding UML Diagram.
    .DESCRIPTION
        Automatically generate a UML diagram of scripts/Modules that contain powershell classes.
    .PARAMETER Path
        The path that contains the classes that need to be documented. 
        The path parameter should point to either a .ps1, .psm1 file, or a directory containing either/both of those file types.
    .PARAMETER ExportFolder
        This optional parameter, allows to specifiy an alternative export folder. By default, the diagram is created in the same folder as the source file.
    .PARAMETER OutPutFormat
        Using the parameter OutputFormat, it is possible change the default output format (.png) to one of the following ones:
        'jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot'
    .PARAMETER OutPutType
        OutPutType is a Set of 2 variables: Combined, Unique
        Combined, all files present in a directory are drawn in the same graph.
        Unique, all files present in a directory are drawn in their own graph.
    .PARAMETER Show
        Open's the generated diagram immediatly
    .PARAMETER IgnoreCase
        By default, Class names MUST be case identical to have the Write-CUClassDiagram cmdlet generate the correct inheritence tree.
        When the switch -IgnoreCase is specified, All class names will be converted to 'Titlecase' to force the case, and ensure the inheritence is correctly drawed in the Class Diagram.
    .PARAMETER PassThru
        When specified, the raw Graph in GraphViz format will be returned back in String format.
    .PARAMETER Recurse
        Dynamic Parameter, available only if the Path Parameter is a Directory containing other directories. If the parameter is used, all subfolders will be parsed.

    .EXAMPLE
        #Generate a UML diagram of the classes located in MyClass.Ps1
        # The diagram will be automatically created in the same folder as the file that contains the classes (C:\Classes).
        Write-CUClassDiagram.ps1 -File C:\Classes\MyClass.ps1
    .EXAMPLE
        #Various output formats are available using the parameter "OutPutFormat"
        Write-CUClassDiagram.ps1 -File C:\Classes\Logging.psm1 -ExportFolder C:\admin\ -OutputFormat gif
        Directory: C:\admin
        Mode                LastWriteTime         Length Name
        ----                -------------         ------ ----
        -a----       12.06.2018     07:47          58293 Logging.gif
    .EXAMPLE
        Write-CUClassDiagram -Path "C:\Modules\PSClassUtils\Classes\Private\" -Show
        Will generate a diagram of all the private classes available in the Path specified, and immediatley show the diagram.
    .NOTES
        Author: Stephanevg / LxLeChat
        www: https://github.com/Stephanevg  https://github.com/LxLeChat
        Report bugs or ask for feature requests here:
        https://github.com/Stephanevg/PsClassUtils
    .LINK
        https://github.com/Stephanevg/PsClassUtils
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(Mandatory=$True)]
        [String]$Path,

        [Parameter(Mandatory=$False)]
        [ValidateSet('Unique','Combined')]
        $OutPutType = 'Combined',

        [Parameter(Mandatory=$False)]
        [ValidateSet('jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot')]
        [string]$OutputFormat = 'png',

        [Parameter(Mandatory=$False)]
        [ValidateScript({ Test-Path $_ })]
        [String]$ExportFolder,

        [Parameter(Mandatory=$False)]
        [Switch]$IgnoreCase,

        [Parameter(Mandatory=$False)]
        [Switch]$ShowComposition,

        [Parameter(Mandatory=$False)]
        [Switch]$Show,

        [Parameter(Mandatory = $false)]
        [Switch]
        $PassThru,

        [Parameter(Mandatory = $False)]
        [String[]]$Exclude

    )

    ## Recurse Parameter should be present only when Path Parameter is a directory, and has child directories
    ## Otherwise Recurse Parameter is Useless
    DynamicParam{
        $DynamicParams=New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $PathItem = get-item $PSBoundParameters['Path']

        If ( ($PathItem -is [System.Io.DirectoryInfo]) -and ((Get-ChildItem -Path $PathItem -Directory).Count -gt 0) ) {
            $ParameterName = "Recurse"
            $ParameterAttributes = New-Object System.Management.Automation.ParameterAttribute
            $Parameter = New-Object System.Management.Automation.RuntimeDefinedParameter $ParameterName,switch,$ParameterAttributes
            $DynamicParams.Add($ParameterName,$Parameter)
            return $DynamicParams
        }
    }

    Begin { <# The begining #>

        ## Check Exclude Parameters, Wildcard is only allowed when Exclude contains One item
        If ( $null -ne $MyInvocation.BoundParameters.Exclude )
        {
            If ( $MyInvocation.BoundParameters.Exclude.count -eq 1 )
            {
                 If ( $MyInvocation.BoundParameters.Exclude -notmatch '^*?\w+\*?$' )
                {
                    Throw "Wildcard must be positionned at the end of your item..."
                }
            }
            If ( $MyInvocation.BoundParameters.Exclude.count -gt 1 )
            {
                If ( (@($MyInvocation.BoundParameters.Exclude) -notmatch '^\w+$').Count -gt 0 )
                {
                    throw "One of your Exclude item contains a wildcard... Wildcard is only allowed on one item..."
                }
            }
        }

    }
    
    Process {

        ## Depending on the Type of the Path Parameter... File or Directory, other (default)
        $PathItem = Get-Item $PSBoundParameters['Path']

        Switch ( $PathItem ) {

            { $PSItem -is [System.Io.FileInfo] } {
                Write-Verbose "Write-CuClassDiagram -> Dealing with a File..."

                ## Looking for Classes
                $Classes = Find-CUClass -Item $PSitem -Exclude $PSBoundParameters['Exclude']
                
                If ( $Null -ne $Classes ) {

                    $GraphParams = New-CUGraphParameters -InputObject $Classes -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']

                    If ( $PSBoundParameters['ExportFolder'] ) ## Export must be made in a specified folder
                    {
                        If ( $PSBoundParameters['show'] ) { ## Show Switch used
                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $PSitem.BaseName -OutputFormat $OutputFormat -Show    
                        } Else ## Show switch not used
                        {
                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $PSitem.BaseName -OutputFormat $OutputFormat
                        }
                        
                    } Else ## Export must be in the same directory
                    {
                        If ( $PSBoundParameters['show'] ) { ## Show Switch used
                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSitem.Directory -ChildPath $PSitem.BaseName -OutputFormat $OutputFormat -Show
                        } Else  ## Show Switch not used
                        {
                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSitem.Directory -ChildPath $PSitem.BaseName -OutputFormat $OutputFormat
                        }
                    }

                } ## Empty class variable, not a class file
            } ## Not a file

            { $PSItem -is [System.Io.DirectoryInfo] } {
                Write-Verbose "Write-CuClassDiagram -> Dealing with a Directory..."
                
                If ( $PSBoundParameters['Recurse'] ) {
                    Write-Verbose "Write-CuClassDiagram -> Recurse parameter used..."

                    ## If OutPutType is not specified, we must use the default value, wich is Combined
                    If ( $OutPutType -eq 'Combined' ) {
                        Write-Verbose "Write-CuClassDiagram -> OutPutType Per Directory..."
                        Foreach ( $Directory in $(Get-ChildItem -path $PSItem -Directory -Recurse) ) {
                            
                            $Classes = Find-CUClass -Item $($Directory.FullName+'\*') -Exclude $PSBoundParameters['Exclude']
                            
                            ##
                            If ( $Null -ne $Classes ) {

                                $GraphParams = New-CUGraphParameters -InputObject $Classes -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']

                                If ( $PSBoundParameters['ExportFolder'] ) {
                                    If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $Directory.Name -OutputFormat $OutputFormat -Show
                                    } Else
                                    {
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $Directory.Name -OutputFormat $OutputFormat
                                    }
                                } Else {
                                    If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $Directory.FullName -ChildPath $Directory.Name -OutputFormat $OutputFormat -Show
                                    } Else
                                    {
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $Directory.FullName -ChildPath $Directory.Name -OutputFormat $OutputFormat
                                    }    
                                }
                            } ## No Classe(s) found, Next directory please ..  ##>
                        } ## No more directories to parse
                    } ## Option Combined for OutPutType was not specified

                    If ( $OutPutType -eq 'Unique' ) {
                        Write-Verbose "Write-CuClassDiagram -> OutPutType Per File..."

                        Foreach ( $Directory in $(Get-ChildItem -path $PSItem -Directory -Recurse) ) {
                            $Classes = Find-CUClass -Item $($Directory.FullName+'\*') -Exclude $PSBoundParameters['Exclude']
                            
                            If ( $Null -ne $Classes ) {
                                
                                Foreach ( $Group in $Classes ) {
                                    
                                    $GraphParams = New-CUGraphParameters -InputObject $Group -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']

                                    If ( $PSBoundParameters['ExportFolder'] ) {
                                        If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat -Show
                                        } Else 
                                        {
                                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat
                                        }
                                    } Else {
                                        If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path (get-item $group.name).Directory -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat -Show
                                        } Else 
                                        {
                                            New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path (get-item $group.name).Directory -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat
                                        }
                                        
                                    }
                                }
                            } ## No Classes found
                        } ## Foreach directory
                    } ## Unique
                    
                } Else {
                    Write-Verbose "Write-CuClassDiagram -> Recurse Parameter NOT specified..."
                    $Classes = Find-CUClass -Item (""+$PSitem.FullName+"\*") -Exclude $PSBoundParameters['Exclude']
                    
                    If ( $Null -ne $Classes ) {
                        Write-Verbose "Write-CuClassDiagram -> $($Classes.Count) Class(es) were found..."

                        ## If OutPutType is not specified, we must use the default value, wich is Combined
                        If ( $OutPutType -eq  'Combined') {

                            Write-Verbose "Write-CuClassDiagram -> OutPutType Per Directory..."
                            $GraphParams = New-CUGraphParameters -InputObject $Classes -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']
                            
                            If ( $PSBoundParameters['ExportFolder'] ) {
                                If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                    New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $PSItem.Name -OutputFormat $OutputFormat -Show
                                } Else
                                {
                                    New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath $PSItem.Name -OutputFormat $OutputFormat
                                }
                            } Else {
                                If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                    New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSItem.FullName -ChildPath $PSitem.Name -OutputFormat $OutputFormat -Show
                                }
                                Else
                                {
                                    New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSItem.FullName -ChildPath $PSitem.Name -OutputFormat $OutputFormat
                                }
                            }
                        }

                        If ( $OutPutType -eq 'Unique' ) {
                            Write-Verbose "Write-CuClassDiagram -> OutPutType Per File..."

                            Foreach ( $Group in $Classes ) {
                                $GraphParams = New-CUGraphParameters -InputObject $Group -IgnoreCase $PSBoundParameters['IgnoreCase'] -ShowComposition $PSBoundParameters['ShowComposition']

                                If ( $PSBoundParameters['ExportFolder'] ) {
                                    If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat -Show
                                    }
                                    Else
                                    {
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path $PSBoundParameters['ExportFolder'] -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat
                                    }
                                } Else {
                                    If ( $PSBoundParameters['show'] ) { ## Show Switch used
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path (get-item $group.name).Directory -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat -Show
                                    }
                                    Else
                                    {
                                        New-CUGraphExport -Graph $GraphParams -PassThru $PSBoundParameters['PassThru'] -Path (get-item $group.name).Directory -ChildPath (get-item $group.name).BaseName -OutputFormat $OutputFormat
                                    }
                                }
                            }
                        }

                    } ## No Classes found
                } ## Not a directory nor a file
            } ## Not a directory .. it's something else ... !

            Default {
                Throw 'Path Parameter must be a file or a directory...'
            }
            ## Bye bye
        }
    }
    
    End { <# The end #> }
}
function Write-CUInterfaceImplementation
{
    param(
        [string]$Name,
        [type]$InterfaceType
    )

    if(-not [System.CodeDom.Compiler.CodeGenerator]::IsValidLanguageIndependentIdentifier($Name)){
        throw "'$Name' is not a valid type name"
        return
    }

    if(-not $InterfaceType.IsInterface){
        throw "'$InterfaceType' is not an interface"
    }

    try{
        $author = [CUInterfaceAuthor]::new($Name, $InterfaceType)

        $sb = [System.Text.StringBuilder]::new()
        $sb = $sb.AppendFormat("class {0} : {1}", $Name, $InterfaceType).AppendLine()
        $sb = $sb.AppendLine('{')
        $sb = $sb.AppendLine($author.GetPropertySection())
        $sb = $sb.Append($author.GetMethodSection())
        $sb = $sb.AppendLine('}')

        return $sb.ToString()
    }
    finally{
        $null = $sb.Clear()
    }
}

Function Write-CUPesterTest {
    <#
    .SYNOPSIS
        Generates Pester tests automatically for PowerShell Classes
    .DESCRIPTION
        Creates a Describe block for the class constructors, and for the Class Methods.
        Each of the describe block will contain child 'it' blocks which contains the corresponding tests.

        For each Method and Constructor the following tests will be created:
        1) test to ensure that the command doesn't throw
        2) for methods, it will first create an instance (using a parameterless constructor by default), then check if the return type is of the right type (for voided methods, it will check that nothing is returned.)
        3) For Static Methods, it will check it will Check that when it is called, it doens't throws an error, and validated the return type is correct. (For voided methods it will check that nothing is returned.)

    .PARAMETER Path

    The Path parameter is mandatory.
    Must point to *.ps1 or *.psm1 file.
    The files must contain powershell classes.

    .PARAMETER ModulefolderPath

    Use this parameter to generate tests for a complete module.
    Specifiy the Root of a module folder. 

    .PARAMETER AddInModuleScope

    If you have a case, where you want to write pester tests for a individual file that contains classes, but you know that it is actually part of a module.
    And if using -ModuleFolderPath is not an option for you, then AddinModuleScope is what you need.

    This parameter will add a 'using module' and the InModuleScope to your tests. see example
  
    Write-CUPesterTest -Path C:\plop.ps1 -AddInModuleScope "Woop"

    Will generate

    Using Module Woop

    InModuleScope -ModuleName "Woop" -Scriptblock {
        #Pester tests for specific classes
    }

    .EXAMPLE
        # The File C:\plop.ps1 MUST contain at least one class.
        write-CupesterTest -Path C:\plop.ps1

        #Generates a C:\plop.Tests.Ps1 file with pester tests in it.
    .EXAMPLE
        write-CupesterTest -Path C:\plop.ps1 -Verbose

        VERBOSE: [PSClassUtils][write-CupesterTest] Generating tests for C:\Plop.ps1
        VERBOSE: [PSClassUtils][write-CupesterTest][Woop] Starting tests Generating process for class --> [Woop]
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop][Constructors] Generating 'Describe' block for Constructors
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop][Constructors] Generating 'IT' blocks
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop] --> [Woop]::new()
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop] --> [Woop]::new([String]String,[int]Number)
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop][Methods]
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop] --> DoSomething()
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop] --> TrickyMethod($Salutations,$IsthatTrue)
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop] --> VoidedMethod()
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Woop] --> MyStaticMethod()
        VERBOSE: [PSClassUtils][write-CupesterTest]--> [Export] -->Exporting tests file to: Microsoft.PowerShell.Core\FileSystem::C:\Plop.Tests.Ps1

    .EXAMPLE
       write-CupesterTest -Path C:\plop.ps1 -IgnoreParameterLessConstructor

       #This example will return create all the tests, except for the parameterLess constructor (which can be usefull for inheritence / 'interface' situations.)
    
    .EXAMPLE

        write-CupesterTest -ModuleFolderPath "C:\Program files\WindowsPowershell\Modules\plop\"
    
    .INPUTS
        File containing Classes. Or folder containing files that contain classes.
    .OUTPUTS
        Void
        Or
        When Passthru is specified
            [Directory.IO.FileInfo] 
    .NOTES
        Author: StÃ©phane van Gulick
        Version: 1.0.0
    .LINK
        https://github.com/Stephanevg/PsClassUtils
    #>
    [cmdletBinding()]
    Param(

        [parameter(ParameterSetName="Path")]
        [String]$Path, #= (Throw "Path is mandatory. Please specifiy a Path to a .ps1 a .psm1 file or a folder containing one or more of these file types."),

        [parameter(ParameterSetName="__AllParameterSets")]
        [System.IO.DirectoryInfo]$ExportFolderPath,

        [parameter(ParameterSetName="ModuleFolder")]
        [System.IO.directoryInfo]$ModuleFolderPath,

        [parameter(ParameterSetName="__AllParameterSets")]
        [Switch]$IgnoreParameterLessConstructor,

        [parameter(ParameterSetName="__AllParameterSets")]
        [Switch]$Combine,

        [parameter(ParameterSetName="__AllParameterSets")]
        [Switch]$Passthru,

        [parameter(ParameterSetName="Path")]
        [String]$AddInModuleScope
    )

    If($ModuleFolderPath){
        $Classes = gci $ModuleFolderPath.FullName -Recurse | Get-CUClass
    }Else{

        $PathObject = Get-Item $Path
        if ($PathObject -is [System.IO.DirectoryInfo]) {
            $Classes = gci $PathObject | Get-CUClass
        }
        elseif ($PathObject -is [System.IO.FileInfo]) {
            $Classes = Get-CUClass -Path $PathObject.FullName
        }
    }




    $AllFiles = $Classes | Group-Object -Property Path
    $PesterTest = $null


    $sb = [System.Text.StringBuilder]::new()
    $CombineCount = 0
    Foreach ($File in $AllFiles) {
        Write-verbose "[PSClassUtils][write-CupesterTest] Generating tests for $($File.Name)"
        $Header = ""
        $IsModule = $False
        if ($ModuleFolderPath -Or $File.Name.EndsWith(".psm1")) {
            
            $IsModule = $True

        }
        else {
            
            $IsModule = $False
        }

        If($IsModule){
            If ($CombineCount -eq 0) {

                If(!($ModuleFolderPath)){

                    $F = Get-Item $File.Name
                    $ModuleName = $F.BaseName
                    [void]$sb.AppendLine("using module $($File.Name)")
                }else{
                    
                    $ModuleName = $ModuleFolderPath.BaseName
                    [void]$sb.AppendLine("using module $($ModuleFolderPath.FullName)")
                }
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("InModuleScope -ModuleName $($ModuleName) -ScriptBlock {")
                [void]$sb.AppendLine("")
            }
        }Else{
            If($AddInModuleScope){
                [void]$sb.AppendLine("using module $($AddInModuleScope)")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("InModuleScope -ModuleName $($AddInModuleScope) -ScriptBlock {")
                [void]$sb.AppendLine("")
            }else{

                [void]$sb.AppendLine(". $($File.Name)")
            }
        }
        
        #Context blocks (TBD)

        #Creating Describe Block for

    
        Foreach ($Class in $File.Group) {
            Write-verbose "[PSClassUtils][write-CupesterTest][$($Class.Name)] Starting tests Generating process for class --> [$($Class.Name)]"
            Write-verbose "[PSClassUtils][write-CupesterTest]--> [$($Class.Name)][Constructors] Generating 'Describe' block for Constructors"
            $StartDescribeBlock = "Describe '[$($Class.Name)]-[Constructors]'{"  

            [void]$sb.AppendLine($StartDescribeBlock)    

            
            
            If (!($Class.Constructor)) {

                Write-verbose "[PSClassUtils][write-CupesterTest]--> [$($Class.Name)][Constructors] No overloaded Constructor to process"
            }
            else {
                
                Write-verbose "[PSClassUtils][write-CupesterTest]--> [$($Class.Name)][Constructors] Generating 'IT' blocks"

                #Creating itBlocks
    
                Foreach ($Constructor in $Class.Constructor) {
                    $ConstructorIsParameterLess = $False
                    #Constructors
                    #$Constructor
                    $Parstr = ""
                    $SignatureRaw = ""
                    foreach ($p in $Constructor.Parameter) {
                        $Parstr = $Parstr + '$' + $p.Name + ","
                        $SignatureRaw = $SignatureRaw + $p.Type + $p.Name + ","
                    }
                    $Signature = "(" + $SignatureRaw.Trim(",") + ")"
                    $Parstr = $Parstr.trim(",")
                    
                    if ($Parstr) {
                        $CallEnd = "(" + $Parstr + ")"
                    }
                    else {
                        $ConstructorIsParameterLess = $true
                        $CallEnd = "()"
                        If($IgnoreParameterLessConstructor){
                            Write-verbose "[PSClassUtils][write-CupesterTest]--> [$($Class.Name)] `$IgnoreParameterLessConstructor detected! Parameterless constructor has been ignored"
                            Continue
                        }
                        
                    }
                    Write-verbose "[PSClassUtils][write-CupesterTest]--> [$($Class.Name)] --> [$($Class.Name)]::new$($Signature)"
                    
                    If($ConstructorIsParameterLess){
                        $ItBlock = "It '[$($Class.Name)]-[Constructor] - Parameterless should Not Throw' {"
                    }Else{
    
                        $ItBlock = "It '[$($Class.Name)]-[Constructor]$($Signature) should Not Throw' {"
                    }
                    [void]$sb.AppendLine("")
                    [void]$sb.AppendLine($ItBlock)
                    [void]$sb.AppendLine("")
                    [void]$sb.AppendLine("# -- Arrange")
    
                    [void]$sb.AppendLine("")
                    if(!($ConstructorIsParameterLess)){
    
                        foreach ($p in $Constructor.Parameter) {
                            [void]$sb.AppendLine("")
                            [void]$sb.AppendLine($p.Type + '$' + $p.Name + "=" + "''")
                            [void]$sb.AppendLine("") 
                            
                        }
                    }
    
                    [void]$sb.AppendLine("# -- Act")
                    [void]$sb.AppendLine("")
    
                    [void]$sb.AppendLine("# -- Assert")
                    [void]$sb.AppendLine("")
                    $ConstructorCallBody = "{[$($Class.Name)]::New" + "$($CallEnd)}"
                    [void]$sb.Append($ConstructorCallBody)
    
                    
                    $TestToExecute = " | Should Not Throw "
                    [void]$sb.AppendLine($TestToExecute)
                    [void]$sb.AppendLine("")
                    [void]$sb.AppendLine("}# end of it block") 
                    [void]$sb.AppendLine("")
                } #Foreach Constructor
            }

            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("}# end of Describe block")
           
        }


        #Create Describe block for Methods
        If (!($Class.Method)) {
            Write-verbose "[PSClassUtils][write-CupesterTest]--> [$($Class.Name)] --> No Methods to process"
            
        }else{

            Write-verbose "[PSClassUtils][write-CupesterTest]--> [$($Class.Name)][Methods]"
            [void]$sb.AppendLine("Describe '[$($Class.Name)]-[Methods]'{")
            [void]$sb.AppendLine("")

            Foreach ($Method in $class.Method) {


                $MethodIsParameterLess = $False
                $Parstr = ""
                $SignatureRaw = ""
                foreach ($p in $Method.Parameter) {
                    $Parstr = $Parstr + $p.Name + ","
                    $SignatureRaw = $SignatureRaw + '$' + $p.Name + ","
                }
                $Parstr = $Parstr.trim(",")
                $SignatureRaw = $SignatureRaw.trim(",")

                    
                $MethodCall = ""
                $MethodCallBody = "[$($Class.Name)]$($Method.Name)"
                $MethodCallEnd = ""
                if ($Parstr) {
                    $MethodCallEnd = "(" + $SignatureRaw + ")"
                }
                else {
                    $MethodIsParameterLess = $True
                    $MethodCallEnd += "()"

                }
                $REturnType = $Method.ReturnType.Extent.Text
                $Signature = "($SignatureRaw)"
                if ($Method.IsStatic()) {

                    $MethodCall = $MethodCallBody.Replace("]", "]::") + $MethodCallEnd
                }
                else {
                    $MethodCall = '$Instance.' + $($Method.Name) + $MethodCallEnd
                }
                $MethodCallEnd = ""
                if ($Method.IsHidden) {
                    
                    $visibility = "#Hidden Method"
                        
                }
                else {

                    $visibility = "#Public Method"
                }

                
                
                
                Write-Verbose "[PSClassUtils][write-CupesterTest]--> [$($Class.Name)] --> $($Method.Name)$($Signature)"
                [void]$sb.AppendLine($visibility)
                [void]$sb.AppendLine("It '[$($Class.Name)] --> $($Method.Name)$($Signature) : $($Method.ReturnType) - should Not Throw' {")
                [void]$sb.AppendLine("")
                
                [void]$sb.AppendLine("# -- Arrange")
                [void]$sb.AppendLine("")

                If(!($MethodIsParameterLess)){

                    foreach ($parameter in $Method.Parameter) {
                        If ($parameter.Type) {
                                
                            [void]$sb.AppendLine($parameter.Type + "$" + $parameter.Name + " = ''")
                            
                        }
                        else {
                            [void]$sb.AppendLine("$" + $parameter.Name + " = ''")
                        }
                        [void]$sb.AppendLine("")
                    
                    }
                }Else{

                }


                
                [void]$sb.AppendLine("# -- Act")
                [void]$sb.AppendLine("")
                if (!($Method.IsStatic())) {
                    
                    
                    [void]$sb.AppendLine('$' + "Instance = [$($Class.Name)]::New()")
                    [void]$sb.AppendLine("")
                }else{
                    
                }
                [void]$sb.AppendLine("# -- Assert")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("{$MethodCall} | Should Not Throw")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("} #End It Block")
                [void]$sb.AppendLine("")


                [void]$sb.AppendLine($visibility)

                If ($Method.ReturnType -eq '[void]' -or $Null -eq $Method.ReturnType) {
                    [void]$sb.AppendLine("It '[$($Class.Name)] --> $($Method.Name)$($Signature) Should not return anything (voided)' {")
                }
                else {
                    $ReturnType = $Method.ReturnType.Replace("[", "").Replace("]", "")
                    if($Method.ReturnType -match '^\[.*\[\]\]$'){
                        #Return type is an array
                        $REturnType = $ReturnType + "[]"
                    }

                    [void]$sb.AppendLine("It '[$($Class.Name)] --> $($Method.Name)$($Signature) : $($Method.ReturnType) - should return type [$($ReturnType)]' {")
                }

                [void]$sb.AppendLine("")
                
                [void]$sb.AppendLine("# -- Arrange")

                If(!($MethodIsParameterLess)){

                    foreach ($parameter in $Method.Parameter) {
                        If ($parameter.Type) {
                                
                            [void]$sb.AppendLine($parameter.Type + "$" + $parameter.Name + " = ''")
                            
                        }
                        else {
                            [void]$sb.AppendLine("$" + $parameter.Name + " = ''")
                        }
                        [void]$sb.AppendLine("")
                    
                    }
                }Else{
                    [void]$sb.AppendLine("")
                }

                
                [void]$sb.AppendLine("# -- Act")
                [void]$sb.AppendLine("")

                
                if (!($Method.IsStatic())) {
                    
                    [void]$sb.AppendLine('$' + "Instance = [$($Class.Name)]::New()")
                }
                
                [void]$sb.AppendLine("# -- Assert")
                [void]$sb.AppendLine("")
                If ($Method.ReturnType -eq '[void]' -or $Null -eq $Method.ReturnType) {
                    [void]$sb.AppendLine("$MethodCall" + '| should be $null')
                }
                else {
                    
                    [void]$sb.AppendLine("($MethodCall).GetType().Name | should be $ReturnType")
                }

                
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("} #End It Block")
                [void]$sb.AppendLine("")
                
            } # end Foreach Method

            #Closing Describe Block
            [void]$sb.AppendLine("}#EndDescribeBlock")
        }


        If($IsModule -or $AddInModuleScope){
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("}#End InModuleScope")
            [void]$sb.AppendLine("")
        }
        $Item = Get-Item $File.Name
        $ExportFilename = $Item.Name.Replace($Item.Extension, ".Tests.Ps1")
        if ($ExportFolderPath) {
            
            $ExportFullPath = Join-Path $ExportFolderPath -ChildPath $ExportFilename
        }
        else {
            $ExportFullPath = Join-Path $Item.PSParentPath -ChildPath $ExportFilename 
        }

        $TestfileName = $File
        write-verbose "[PSClassUtils][write-CupesterTest]--> [Export] -->Exporting tests file to: $($ExportFullPath)"
        
        $sb.ToString() | out-file -FilePath $ExportFullPath -Encoding utf8

        If($Passthru){
            Get-Item $ExportFullPath
        }

        $Null = $Sb.Clear()


    }#End Foreach File


}
