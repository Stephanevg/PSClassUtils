
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
        Author: Stéphane van Gulick
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

                If (!($Method.ReturnType) -or $Method.ReturnType -eq '[void]') {
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
                If (!($Method.ReturnType) -or $Method.ReturnType -eq '[void]') {
                    [void]$sb.AppendLine("$MethodCall" + '| Should -Be $null')
                }
                else {
                    
                    [void]$sb.AppendLine("($MethodCall).GetType().Name | Should -Be $ReturnType")
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
