Function Get-CUClassProperty {
    <#
    .SYNOPSIS
        This function returns all existing properties of a specific powershell class.
    .DESCRIPTION
        The Powershell Class must be loaded in memory for this function to work.
    .EXAMPLE
        Get-CUClassProperty -ClassName wap

        Name   Type
        ----   ----
        prop3  String
        String String
        number Int32

    .INPUTS
        String
    .OUTPUTS
        ClassMethod
    .NOTES   
        Author: Stéphane van Gulick
        Version: 0.7.2
        www.powershellDistrict.com
        Report bugs or submit feature requests here:
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding(DefaultParameterSetName = "LoadedInMemory")]
    Param(
        [Parameter(Mandatory = $true)]
        [String]$ClassName,

        [Parameter(ParameterSetName = "file", ValueFromPipelineByPropertyName = $True)]
        [ValidateScript( {

                test-Path $_
            }
        )]
        [Alias("FullName")]
        [System.IO.FileInfo]
        $Path,

        [Parameter(ParameterSetName = "ast", ValueFromPipelineByPropertyName = $False)]
        [System.Management.Automation.Language.StatementAst[]]
        $InputObject,

        [Switch]$Raw

    )

    if ($PSCmdlet.ParameterSetName -ne "file" -and $PSCmdlet.ParameterSetName -ne "ast") {

        $Properties = invoke-expression "[$($ClassName)].GetProperties()"
        if ($Properties) {

            Foreach ($Property in $Properties) {
    
                [ClassProperty]::New($Property.Name, $Property.PropertyType.Name)
    
            }
        }
    }
    Else {


        if ($InputObject) {
        
            $RawGlobalAST = [System.Management.Automation.Language.Parser]::ParseInput($InputObject, [ref]$null, [ref]$Null)
        }
        else {
        
            $RawGlobalAST = [System.Management.Automation.Language.Parser]::ParseFile($Path.FullName, [ref]$null, [ref]$Null)
        }
        $ASTClasses = $RawGlobalAST.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
           
        if ($ClassName) {
            foreach ($ASTClass in $ASTClasses) {
                if ($ASTClass.Name -eq $ClassName) {
                    $ASTClassDocument = $ASTClass
                    break
                }
            }
        }
        
        $Properties = $ASTClassDocument.members | ? {$_ -is [System.Management.Automation.Language.PropertyMemberAst]} 

        if ($Properties) {
        
            Foreach ($pro in $Properties) {
                
                if ($pro.IsHidden) {
                    $visibility = "Hidden"
                }
                else {
                    $visibility = "public"
                }
            
                [ClassProperty]::New($pro.Name, $pro.PropertyType.TypeName.Name, $visibility,$pro)

            

            }
        }
    }
}



