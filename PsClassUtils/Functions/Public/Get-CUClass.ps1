function Get-CUClass{
    <#
    .SYNOPSIS
        This function returns all currently loaded powershell classes, and can examine classes found in ps1 or psm1 files.
    .DESCRIPTION
        This function returns all currently loaded powershell classes, and can examine classes found in ps1 or psm1 files.
    .EXAMPLE
        PS C:\> Get-CUClass

        Classes            Enums Source                                                                                 ClassName
        -------            ----- ------                                                                                 ---------
        {ClassProperty}          C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\01_ClassProperty.ps1    ClassProperty
        {ClassMethod}            C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\02_ClassMethod.ps1      ClassMethod
        {ClassConstructor}       C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\03_ClassConstructor.ps1 ClassConstructor
        {ASTDocument}            C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\04_ASTDocument.ps1      ASTDocument
        {ClassEnum}              C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\05_ClassEnum.ps1        ClassEnum
        
        This wil display all powerhsell classes loaded in memory

    .EXAMPLE
        PS C:\> Get-CUClass -Path .\Classes\Private\01_ClassProperty.ps1

        Classes         Enums Source                                                                              ClassName
        -------         ----- ------                                                                              ---------
        {ClassProperty}       C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\01_ClassProperty.ps1 ClassProperty

        This will display all the classes present in the 01_ClassProperty.ps1 file
    
    .EXAMPLE
        PS C:\> Get-ChildItem -Recurse | Get-CUClass

        Classes            Enums Source                                                                                             ClassName
        -------            ----- ------                                                                                             ---------
                                C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\PSClassUtils.psm1
        {ClassProperty}         C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\01_ClassProperty.ps1                ClassProperty
        {ClassMethod}           C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\02_ClassMethod.ps1                  ClassMethod
        {ClassConstructor}      C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\03_ClassConstructor.ps1             ClassConstructor
        {ASTDocument}           C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\04_ASTDocument.ps1                  ASTDocument
        {ClassEnum}             C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Classes\Private\05_ClassEnum.ps1                    ClassEnum
                                C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Functions\Private\ConvertTo-TitleCase.ps1
                                C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Functions\Private\Get-CUAST.ps1
                                C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Functions\Private\Out-CUPSGraph.ps1
                                C:\Users\Lx\GitPerso\PSClassUtils\PsClassUtils\Functions\Public\Get-CUClass.ps1
        ...

        This will display all the classes (if present), in all ps1 and psm1 files under c:\

    .INPUTS
        Name parameter accepts a powershell class name (if already loaded in memory).
        Path parameter accept a path in the form of a relative or absolute path of a ps1 or psm1 file.
    .OUTPUTS
        The function output ASTDocument objects. 
    .NOTES   
        Author: Tobias Weltner
        Version: ??
        Source --> http://community.idera.com/powershell/powertips/b/tips/posts/finding-powershell-classes

        Modification: LxLeChat
        For the PSClassUtils Module: https://github.com/Stephanevg/PSClassUtils
        Thanks to @NicolasBn for his help with DefaultParameterSetName and the debug off the weird encoded characters returned
    #>
    [CmdletBinding(DefaultParameterSetName="Normal")]
    Param(
      [Parameter(ParameterSetName="Normal",Mandatory=$False,ValueFromPipeline=$False)]
      $Name = '*',
      [Alias("FullName")]
      [Parameter(ParameterSetName="Path",Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [System.IO.FileInfo[]]$Path
    )
    BEGIN{}

    PROCESS{

        If ($Null -eq $PSBoundParameters['Path']) {

            $LoadedClasses = [AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object { $_.GetCustomAttributes($false) |
            Where-Object { $_ -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute]} } |
            ForEach-Object { 
                $_.GetTypes() |
                Where-Object IsPublic | Where-Object { $_.Name -like $Name } |
                Select-Object @{l='Path';e={($_.Module.ScopeName.Replace([char]0x29F9,'\').replace([char]0x589,':')) -replace '^\\',''}}
            }
            
            Foreach ( $Class in $LoadedClasses ) {
                Get-CUAst -Path $Class.Path
            }
            
        } Else {

            Foreach ( $P in $Path ) {

                If ( $MyInvocation.PipelinePosition -eq 1 ) {
                    $P = Get-Item (resolve-path $P).Path
                }

                If ( $P.Extension -in '.ps1','.psm1') {
                    Get-CUAst -Path $P.FullName
                }
            }

        }
    }

    END{}  
  }
  