Function Get-CUClassConstructor {
    <#
    .SYNOPSIS
        Returns all constructors from a specific class
    .DESCRIPTION
        Long description
    .EXAMPLE
        Get-CUClassConstructor -ClassName MYclass  ClassParameter -Path C:\File.ps1
        
    .EXAMPLE

        Returns class constructor via the pipeline of type System.IO.FileInfo

        Get-Item C:\Files\FileWithClass.ps1 | Get-CUClassConstructor -ClassName ClassParameter
        

    .INPUTS
        System.IO.FileInfo, CUClass
    .OUTPUTS
        CuClassConstructor[]
    .NOTES
        General notes
    #>
    [cmdletBinding()]
    [OutputType('AsCUClassConstructor','CUClassConstructor')]
    Param(
        [Alias("FullName")]
        [Parameter(ParameterSetName = "Path", Position=1, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Mandatory=$true, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(ValueFromPipeline=$True)]
        [Object[]]$InputObject
    )

    BEGIN {}

    PROCESS {



        $ClassParams = @{}

        If($ClassName -or $PSBoundParameters['ClassName'] ){
            $ClassParams.ClassName = $ClassName
        }

        If($Path -or $PSBoundParameters['Path'] ){
            $ClassParams.Path = $Path.FullName
        }

        If($InputObject){
            $ClassParams.ClassName = $ClassName
        }

       
            $Class = Get-CuClass @ClassParams
            If($Class){

                $Class.GetCuClassConstructor()
            }
        }


    END {}

}
