Function Get-AST {
    <#
    .EXAMPLE
    
$Arr = Get-AST -Path "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\04\JeffHicks_StarShipModule.ps1","C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\05\BenGelens_CWindowsContainer.ps1"

$r = gc "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\05\BenGelens_CWindowsContainer.ps1"

#Get-AST -InputObject $r

$r | Get-AST

"C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\04\JeffHicks_StarShipModule.ps1","C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\Examples\04\JeffHicks_StarShipModule.ps1" | get-ast
    #>
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory         = $False,
            ValueFromPipeline = $false)
        ]
        [String[]]
        $InputObject,

    [parameter(
            Mandatory         = $False,
            ValueFromPipeline = $true
    )]
    [Alias('FullName')]
    [System.IO.FileInfo[]]$Path
    )
    
    begin {

        function sortast {
            [CmdletBinding()]
            PAram(

                $RawAST,
                $Source
            )

            $Type = $AST.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
            [System.Management.Automation.Language.StatementAst[]] $Enums = @()
            $Enums = $type | ? {$_.IsEnum -eq $true}
            [System.Management.Automation.Language.StatementAst[]] $Classes = @()
            $Classes = $type | ? {$_.IsClass -eq $true}
            
            return [ASTDocument]::New($Classes,$Enums,$Source)

        }

    }
    
    process {


        if($Path){
            foreach($p in $PAth){

                [System.IO.FileInfo]$File = (Resolve-Path -Path $p).Path
                $AST = [System.Management.Automation.Language.Parser]::ParseFile($p.FullName, [ref]$null, [ref]$Null)

                sortast -RawAST $AST -Source $File.BaseName
            }
        }else{
        
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($InputObject, [ref]$null, [ref]$Null)
                sortast -RawAST $AST -Source "Pipeline"
        
        }

        


    }
    
    end {
    }
}
