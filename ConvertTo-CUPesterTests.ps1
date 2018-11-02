
$ASTDocument = Get-CUAst -Path D:\Repository\Modules\Class.Helper.ConfigMgr\Class.Helper.ConfigMgr.psm1
$PesterTest = $null
Function Get-MethodSignature {
    [CmdletBinding()]
    Param(
        $Method
    )

    $Method.Parameters.Extent.Text
}

Foreach ($Class in $ASTDocument.Classes){


    $Constructors = $Class.members | ? {$_.IsConstructor -eq $true}
    #$AllMembers = @()
    $Methods = $Class.members | ? {$_.IsConstructor -eq $false}

    #Optional Context blocks

    #Creating Describe Block

    $PesterTest +=@"
    using module D:\Repository\Scripts\CM0-OPR-PackageManagement\Class.PackageManagement\Class.PackageManagement.psd1
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"

    Describe "Testing: [$($Class.Name)]"{
    
"@ 

    #Creating itBlocks

    Foreach($Constructor in $Constructors){

        #Constructors


        #$Constructor
        $Parstr = ""
        $SignatureRaw = ""
        foreach ($p in $Constructor.Parameters) {
            $Parstr = $Parstr + $p.Name + ","
            $SignatureRaw = $SignatureRaw + $p.Extent.Text + ","
        }

    }


    Foreach ($Method in $Methods){


        
            $Parstr = ""
            $SignatureRaw = ""
            foreach ($p in $Method.Parameters) {
                $Parstr = $Parstr + $p.Name + ","
                $SignatureRaw = $SignatureRaw + $p.Extent.Text + ","
            }
            $Parstr = $Parstr.trim(",")
            $SignatureRaw = $SignatureRaw.trim(",")

            
            $MethodCall =""
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
            if($Method.IsStatic){

                $MethodCall = $MethodCallBody.Replace("]","]::") + $MethodCallEnd
            }else{
                $MethodCall = '$Instance.' + $($Method.Name) + $MethodCallEnd
            }
        
            if ($Method.IsHidden) {
              
                $visibility = "#Hidden Method"
                
            }else{

                $visibility = "#Public Method"
            }

            $ItBlockHeader ="#Set Parameter values here:"
            foreach ($parameter in $Method.Parameters.Name) {

                $ItBlockHeader += @"
    
                $parameter = ""
"@
            }



            $PesterTest += @"


            $($visibility)
            It '[$($Class.Name)] -->$($ReturnType) $($Method.Name) $($Signature) should Not Throw' {
                
                $ItBlockHeader

                #Instanciation



                #Test Values
                
                {$MethodCall} | Should Not Throw
                
            }

            $($visibility)
            It '[$($Class.Name)] -->$($ReturnType) $($Method.Name) $($Signature) should return type $($ReturnType)' {
                
                $ItBlockHeader

                #Instanciation



                #Test Values
                
                ($MethodCall).GEtType().FullName | should be $ReturnType
            }
    
"@
            



    }

    #Closing Describe Block
        $PesterTest += @"
    
    }#EndDescribeBlock

"@
$PesterTest > "$Home\ConfigMgr.Tests\$($Class.Name).Tests.ps1" 
$PesterTest = ""
}#End Foreach Class


