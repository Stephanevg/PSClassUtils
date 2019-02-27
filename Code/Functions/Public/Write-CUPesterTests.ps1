
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
    [cmdletBinding()]
    Param(


        $Path = "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\DevCode\woop.psm1",
        $ExportFolderPath,
        $AddParameterLessConstructor = $true,
        $Combine
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


    $sb = [System.Text.StringBuilder]::new()
    $CombineCount = 0
    Foreach ($File in $AllFiles) {
        Write-verbose "[PSClassUtils][Write-CUPesterTests] Generating tests for $($File.Name)"
        $Header = ""
        if ($File.Name.EndsWith(".psm1")) {
            $Header = "using module $($File.Name)"
            
            
            #if($Combine){
            #    If($CombineCount -eq 0){

            #        $Header = "using module $($File.Name)"
            #    }
            #}
        }
        else {
            $Header = ". $($File.Name)"
        }
        

        #Optional Context blocks

        #Creating Describe Block
        
        [void]$sb.AppendLine($Header)
        

        Foreach ($Class in $File.Group) {
            Write-verbose "[PSClassUtils][Write-CUPesterTests][$($Class.Name)] Starting tests Generating process for class --> [$($Class.Name)]"
            Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)][Constructors] Generating 'Describe' block for Constructors"
            $StartDescribeBlock = "Describe '[$($Class.Name)]-[Constructors]'{"  

            [void]$sb.AppendLine($StartDescribeBlock)    

            
            
            If(!($Class.Constructor)){
                Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)][Constructors] No overloaded Constructor to process"
                
            }else{
                #Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)][Constructors]"
                Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)][Constructors] Generating 'IT' blocks"
            }
            #Creating itBlocks

            If($AddParameterLessConstructor){
                Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)] --> [$($Class.Name)]::New() "
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("It '[$($Class.Name)]-[Constructor] - Parameterless - should Not Throw' {")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("# -- Arrange")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("# -- Act")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("# -- Assert")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("{[$($Class.Name)]::New()} | Should not throw")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("} #End of it block")
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("")
            }else{
                Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)] Parameterless constructor ignored"
            }

            Foreach ($Constructor in $Class.Constructor) {

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
                    
                    $CallEnd = "()"
                    
                }
                Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)] --> [$($Class.Name)]::new$($Signature)"
                $ItBlock = "It '[$($Class.Name)]-[Constructor]$($Signature) should Not Throw' {"
                [void]$sb.AppendLine($ItBlock)
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("# -- Arrange")

                foreach ($p in $Constructor.Parameter) {
                    [void]$sb.AppendLine("")
                    [void]$sb.AppendLine('$' + $p.Name + "=" + "''")
                    [void]$sb.AppendLine("") 
                    
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
            }



            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("}# end of Describe block")
            #$sb.ToString() > "C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSClassUtils\DevCode\$($ExportFilename)" 
        }


        Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)][Methods]"
        [void]$sb.AppendLine("Describe '[$($Class.Name)]-[Methods]'{")
        [void]$sb.AppendLine("")

        Foreach ($Method in $class.Method) {


            
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
            
            if ($Method.IsHidden) {
                
                $visibility = "#Hidden Method"
                    
            }
            else {

                $visibility = "#Public Method"
            }

            
            
            
            Write-Verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)] --> $($Method.Name)$($Signature)"
            [void]$sb.AppendLine($visibility)
            [void]$sb.AppendLine("It '[$($Class.Name)] --> $($Method.Name)$($Signature) : $($Method.ReturnType) - should Not Throw' {")
            [void]$sb.AppendLine("")
            
            [void]$sb.AppendLine("# -- Arrange")
            [void]$sb.AppendLine("")

            foreach ($parameter in $Method.Parameter) {
                If($parameter.Type){
                     
                    [void]$sb.AppendLine($parameter.Type + "$" + $parameter.Name + " = ''")

                }else{
                    [void]$sb.AppendLine("$" + $parameter.Name + " = ''")
                }
                [void]$sb.AppendLine("")
            
            }

            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("# -- Act")
            if(!($Method.IsStatic())){
                
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine('$' + "Instance = [$($Class.Name)]::New()")
            }
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("# -- Assert")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("{$MethodCall} | Should Not Throw")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("} #End It Block")
            [void]$sb.AppendLine("")


            [void]$sb.AppendLine($visibility)

            If($Method.ReturnType -eq '[void]' -or $Null -eq $Method.ReturnType){
                [void]$sb.AppendLine("It '[$($Class.Name)] --> $($Method.Name)$($Signature) Should not return anything (voided)' {")
            }else{
                $ReturnType = $Method.ReturnType.Replace("[","").Replace("]","")
                [void]$sb.AppendLine("It '[$($Class.Name)] --> $($Method.Name)$($Signature) should return type [$($ReturnType)]' {")
            }

            [void]$sb.AppendLine("")
            
            [void]$sb.AppendLine("# -- Arrange")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("# -- Act")
            [void]$sb.AppendLine("")

            
            if(!($Method.IsStatic())){
                
                [void]$sb.AppendLine('$' + "Instance = [$($Class.Name)]::New()")
            }
            
            [void]$sb.AppendLine("# -- Assert")
            [void]$sb.AppendLine("")
            If($Method.ReturnType -eq '[void]' -or $Null -eq $Method.ReturnType){
                [void]$sb.AppendLine("$MethodCall" + '| should be $null')
            }else{
                
                [void]$sb.AppendLine("($MethodCall).GetType().Name | should be $ReturnType")
            }

            
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("} #End It Block")
            [void]$sb.AppendLine("")
            
        }

        If(!($Class.Method)){
            Write-verbose "[PSClassUtils][Write-CUPesterTests]--> [$($Class.Name)] --> No Methods to process"
            
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
        write-verbose "[PSClassUtils][Write-CUPesterTests]--> [Export] -->Exporting tests file to: $($ExportFullPath)"
        $sb.ToString() > $ExportFullPath



    }#End Foreach Class


}
