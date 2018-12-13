S
Function Write-CUPesterTests {
    <#
    .SYNOPSIS
        Generates automatically Pester tests 
    .DESCRIPTION
        Pester tests generation from ps1 or psm1 files.
    .EXAMPLE
        Write-CUPesterTests -Path C:\plop.ps1

        #Generates a C:\plop.Tests.Ps1 file with pester tests in it.
    .EXAMPLE
        Write-CUPesterTests -Path C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\DevCode\CompositionTest.ps1
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
Param(


    $Path = "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\DevCode\woop.psm1",
    $ExportFolderPath,
    $AddParameterLessConstructor = $true
)

$PathObject = Get-Item $Path
if ($PathObject -is [System.IO.DirectoryInfo]) {
    $Classes = gci $PathObject | Get-CUClass
}
elseif ($PathObject -is [System.IO.FileInfo]) {
    $Classes = Get-CUClass -Path $PathObject.FullName
}




$AllFiles = $Classes | Group-Object -Property Path
$PesterTest = $null
Function Get-MethodSignature {
    [CmdletBinding()]
    Param(
        $Method
    )

    $Method.Parameters.Extent.Text
}

$sb = [System.Text.StringBuilder]::new()

Foreach ($File in $AllFiles) {
    $Header = ""
    if ($File.Name.EndsWith(".psm1")) {
        $Header = "using module $($File.Name)"
    }
    else {
        $Header = ". $($File.Name)"
    }
    

    #Optional Context blocks

    #Creating Describe Block
    
    [void]$sb.AppendLine($Header)
    

    Foreach ($Class in $File.Group) {


        $StartDescribeBlock = "Describe '[$($Class.Name)]-[Constructors]'{"  

        [void]$sb.AppendLine($StartDescribeBlock)    

        Write-verbose "Generating IT blocks"

        #Creating itBlocks

        If($AddParameterLessConstructor){
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("It '[$($Class.Name)]-[Constructor] - Parameterless - should Not Throw' {")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("{[$($Class.Name)]::New()} | Should not throw")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("} #End of it block")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("")
        }

        Write-verbose " Constructors"
        Foreach ($Constructor in $Class.Constructor) {

            #Constructors
            Write-verbose " Constructors"
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

                $CallEnd = "()"

            }
            $ItBlock = "It '[$($Class.Name)]-[Constructor]$($Signature) should Not Throw' {"
            [void]$sb.AppendLine($ItBlock)
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("#Instanciation:")

            foreach ($p in $Constructor.Parameter) {
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine('$' + $p.Name + "=" + "''")
                [void]$sb.AppendLine("") 
                
            }

            [void]$sb.AppendLine("#Constructor Call:")
            [void]$sb.AppendLine("")
            $ConstructorCallBody = "{[$($Class.Name)]::New" + "$($CallEnd)}"
            [void]$sb.Append($ConstructorCallBody)
            $TestToExecute = " | Should Not Throw "
            [void]$sb.AppendLine($TestToExecute)
            [void]$sb.AppendLine("}# end of it block") 
            [void]$sb.AppendLine("")
        }

        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("}# end of Describe block")
        #$sb.ToString() > "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\DevCode\$($ExportFilename)" 
    }



    [void]$sb.AppendLine("Describe '[$($Class.Name)]-[Methods]'{")
    [void]$sb.AppendLine("")
    Foreach ($Method in $class.Method) {


        
        $Parstr = ""
        $SignatureRaw = ""
        foreach ($p in $Method.Parameters) {
            $Parstr = $Parstr + $p.Name + ","
            $SignatureRaw = $SignatureRaw + $p.Extent.Text + ","
        }
        $Parstr = $Parstr.trim(",")
        $SignatureRaw = $SignatureRaw.trim(",")

            
        $MethodCall = ""
        $MethodCallBody = "[$($Class.Name)]$($Method.Name)"
        $MethodCallEnd = ""
        if ($Parstr) {
            $MethodCallEnd = "(" + $Parstr + ")"
        }
        else {

            $MethodCallEnd += "()"

        }
        $REturnType = $Method.ReturnType.Extent.Text
        $Signature = "($SignatureRaw)"
        if ($Method.IsStatic) {

            $MethodCall = $MethodCallBody.Replace("]", "]::") + $MethodCallEnd
        }
        else {
            $MethodCall = '$Instance.' + $($Method.Name) + $MethodCallEnd
        }
        
        if ($Method.IsHidden) {
              
            $visibility = "#Hidden Method"
                
        }
        else {

            $visibility = "#Public Method"
        }

        
        [void]$sb.AppendLine("")
        foreach ($parameter in $Method.Parameters.Name) {
            [void]$sb.AppendLine($parameter)
            [void]$sb.AppendLine("")
           
        }


        [void]$sb.AppendLine($visibility)
        [void]$sb.AppendLine("It '[$($Class.Name)] -->$($ReturnType) $($Method.Name) $($Signature) should Not Throw' {")
        [void]$sb.AppendLine("")
        
        [void]$sb.AppendLine("#Arrange")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("#Act")
        if(!($Method.IsStatic)){
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("#Instantiate your class here")
            [void]$sb.AppendLine('$' + "Instance = [$($Class.Name)]::New()")
        }
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("#Assert")
        [void]$sb.AppendLine("{$MethodCall} | Should Not Throw")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("} #End It Block")
        [void]$sb.AppendLine("")


        [void]$sb.AppendLine($visibility)
        [void]$sb.AppendLine("It '[$($Class.Name)] -->$($ReturnType) $($Method.Name) $($Signature) should return type $($ReturnType)' {")
        [void]$sb.AppendLine("")
        
        [void]$sb.AppendLine("#Arrange")
        [void]$sb.AppendLine("# Add parameter values here")

        [void]$sb.AppendLine("")
        
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("#Act")

        [void]$sb.AppendLine("#Instantiate your class here")
        
        if(!($Method.IsStatic)){
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("#Instantiate your class here")
            [void]$sb.AppendLine('$' + "Instance = [$($Class.Name)]::New()")
        }
        [void]$sb.AppendLine("#Test Values")
        [void]$sb.AppendLine("($MethodCall).GetType().FullName | should be $ReturnType")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("} #End It Block")
        [void]$sb.AppendLine("")

    }

    #Closing Describe Block
    [void]$sb.AppendLine("}#EndDescribeBlock")

    $Item = Get-Item $File.Name
    $ExportFilename = $Item.Name.Replace($Item.Extension,".Tests.Ps1")
    if($ExportFolderPath){

        $ExportFullPath = Join-Path $ExportFolder -ChildPath $ExportFilename
    }else{
        $ExportFullPath = Join-Path $Item.PSParentPath -ChildPath $ExportFilename 
    }

    $TestfileName = $File
    $sb.ToString() > $ExportFullPath



}#End Foreach Class


}

