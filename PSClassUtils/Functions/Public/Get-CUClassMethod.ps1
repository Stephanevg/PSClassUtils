Function Get-CUClassMethod {
    <#
    .SYNOPSIS
        This function returns all existing methods of a specific powershell class.
    .DESCRIPTION
        The Powershell Class must be loaded in memory for this function to work.
    
    .PARAMETER Path

    The -Path parameter allows to specifiy a file (only), which will be searched for powershell Class Methods.
    If none are found, nothing is returned.

    .PARAMETER Raw

    This will reutnr the raw AST object 

    .EXAMPLE

    Get-CUClassMethod -ClassName wap

    Name          ReturnType Properties
    ----          ---------- ----------
    DoChildthing  void
    DoChildthing2 void       {Prop1, Prop2}
    DoChildthing3 string     {Prop1, Prop2, Prop3}
    DoChildthing4 bool       {Prop1, Prop2, Prop3}
    DoSomething   string     {Prop1, Prop2, Prop3}

    .EXAMPLE

    Get-CUClassMethod -ClassName "TestStats" -Path "C:\MyClasses\006_TestStats.ps1"

    Name                    ReturnType   Properties
    ----                    ----------   ----------
    GetFailedTestCases      [TestCase[]] {TestSuite, time}
    GetSuccessfullTestCases [TestCase[]] {TestSuite}

    .INPUTS
        String
    .OUTPUTS
        ClassMethod
    .NOTES   
        Author: Stéphane van Gulick
        Version: 0.7.1
        www.powershellDistrict.com
        Report bugs or submit feature requests here:
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]$ClassName,

        [Parameter(ParameterSetName = "file", ValueFromPipelineByPropertyName = $True)]
        [ValidateScript({

            test-Path $_
        }
        )]
        [Alias("FullName")]
        [System.IO.FileInfo]
        $Path,

        [Switch]$Raw
    )
    
    if ($PSCmdlet.ParameterSetName -ne "file") {

        $Methods = invoke-expression "[$($ClassName)].GetMethods()" | where-object {($_.IsHideBySig) -eq $false}
   
        Foreach ($Method in $Methods) {
            $Parameters = $Method.GetParameters()
            If ($Parameters) {
                [ClassProperty[]]$Params = @()
                foreach ($Parameter in $Parameters) {
   
                    $Params += [ClassProperty]::New($Parameter.Name, $Parameter.ParameterType)
   
                }
            }
            [ClassMethod]::New($Method.Name, $Method.ReturnType, $Params)
        }
    }Else{

        $RawGlobalAST = [System.Management.Automation.Language.Parser]::ParseFile($Path.FullName, [ref]$null, [ref]$Null)
        $ASTClasses = $RawGlobalAST.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
        
        if($ClassName){
            foreach($ASTClass in $ASTClasses){
                if($ASTClass.Name -eq $ClassName){
                    $ASTClassDocument = $ASTClass
                    break
                }
            }
        }

        if($ASTClassDocument){

            $ExecutableCode = $ASTClassDocument.FindAll( {$args[0] -is [System.Management.Automation.Language.FunctionMemberAst]}, $true)
            $Methods = $ExecutableCode | ? {$_.IsConstructor -eq $false}

            If($Methods){

                Foreach ($Method in $Methods) {
                    if($Raw){
                        $Method
                    
                    }else{

                        if($MethodName){
                            if($MethodName -eq $Method.Name){
                                $Found = $true
                            }else{
                                continue
                            }
                        }
                        $Parameters = $Method.Parameters
                        If ($Parameters) {
                            [ClassProperty[]]$Params = @()
                            foreach ($Parameter in $Parameters) {
                                $Type = $null
                                # couldn't find another place where the returntype was located. 
                                # If you know a better place, please update this! I'll pay you beer.
                                $Type = $Parameter.Extent.Text.Split("$")[0] 
                                $Params += [ClassProperty]::New($Parameter.Name.VariablePath.UserPath, $Type)
               
                            }
                        }
                        [ClassMethod]::New($Method.Name, $Method.ReturnType, $Params)
                        if($Found){
                            break
                        }
                    }
                }
            }Else{
                Write-verbose "No Methods found in $($ClassName) in $($Path.FullName)"
            }

        }else{
            write-verbose "Class $($ClassName) not found in $($Path.FullName)"
        }

        
    }

}