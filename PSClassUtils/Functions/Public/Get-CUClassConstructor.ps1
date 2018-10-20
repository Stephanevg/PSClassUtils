Function Get-CUClassConstructor {
    <#
    .SYNOPSIS
        This function returns all existing constructors of a specific powershell class.
    .DESCRIPTION
        The Powershell Class must be loaded in memory for this function to work.
    .EXAMPLE
         Get-CUClassConstructor -ClassName woop

        Name ReturnType Properties
        ---- ---------- ----------
        woop woop
        woop woop       {String, Number}
    .INPUTS
        String
    .OUTPUTS
        ClassConstructor
    .NOTES   
        Author: Stéphane van Gulick
        Version: 0.7.2
        www.powershellDistrict.com
        Report bugs or submit feature requests here:
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding(DefaultParameterSetName="LoadedInMemory")]
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

        $Constructors = invoke-expression "[$($ClassName)].GetConstructors()"
    
        Foreach ($Constructor in $Constructors) {
            
            $Parameters = $Constructor.GetParameters()
            If ($Parameters) {
                [ClassProperty[]]$Params = @()
                foreach ($Parameter in $Parameters) {
    
                    $Params += [ClassProperty]::New($Parameter.Name, $Parameter.ParameterType)
    
                }
            }
            [ClassConstructor]::New($ClassName, $ClassName, $Params)
             
        }
    }
    else {

        
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
        }else{
            $ASTClassDocument = $ASTClasses
        }
        
        if ($ASTClassDocument) {
        
            $ExecutableCode = $ASTClassDocument.FindAll( {$args[0] -is [System.Management.Automation.Language.FunctionMemberAst]}, $true)
            $Constructors = $null
            $Constructors = $ExecutableCode | ? {$_.IsConstructor -eq $true}
        
            If ($Constructors) {
        
                Foreach ($Constructor in $Constructors) {
                    if ($Raw) {
                        $Constructor
                        
                    }
                    else {
        
                        if ($ConstructorName) {
                            if ($ConstructorName -eq $Constructor.Name) {
                                $Found = $true
                            }
                            else {
                                continue
                            }
                        }
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
                        [ClassConstructor]::New($Constructor.Name, $Constructor.ReturnType, $Paras,$Constructor)
                        if ($Found) {
                            break
                        }
                    }
                }
            }
            Else {
                Write-verbose "No Constructors found in $($ClassName) in $($Path.FullName)"
            }
        
        }
        else {
            write-verbose "Class $($ClassName) not found in $($Path.FullName)"
        }
    }


}