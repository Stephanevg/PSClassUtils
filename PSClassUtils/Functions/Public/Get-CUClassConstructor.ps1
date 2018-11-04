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
<<<<<<< HEAD
    [cmdletBinding(DefaultParameterSetName="All")]
=======
    [cmdletBinding()]
    [OutputType('AsCUClassConstructor','CUClassConstructor')]
>>>>>>> upstream/Feature_Get-CUClassV2
    Param(
        [Alias("FullName")]
        [Parameter(ParameterSetName = "Path", Position=1, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Mandatory=$true, ValueFromPipeline=$False)]
        [String[]]$ClassName,

<<<<<<< HEAD
        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set1")]
        [CUClass[]]$InputObject,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set2",ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path
=======
        [Parameter(ValueFromPipeline=$True)]
        [Object[]]$InputObject
>>>>>>> upstream/Feature_Get-CUClassV2
    )

    BEGIN {}

    PROCESS {

<<<<<<< HEAD
        If ( $MyInvocation.PipelinePosition -eq 1 ) {
            
            $ClassParams = @{}

            If ( $null -ne $PSBoundParameters['Path'] ) {
                Foreach ( $Path in $PSBoundParameters['Path'] ) {
                    $Path = Get-Item (resolve-path $Path).Path
                    $ClassParams.Path = $Path.FullName
                }
            }

            If ( $null -ne $PSBoundParameters['ClassName'] ) {
                $ClassParams.ClassName = $PSBoundParameters['ClassName']
            }

            $x = Get-CuClass @ClassParams
            If ( $Null -ne $x ) {
                $x.GetCuClassConstructor()
            }


        } Else {

            Switch ($PSCmdlet.ParameterSetName) {

                "Set1" {

                    $ClassFilter = If( $PSBoundParameters['ClassName'] ) { $PSBoundParameters['ClassName'] } Else { "*" }
                    Foreach ( $Class in $InputObject ) {
                        If ( $Class.Name -like $ClassFilter ){
                            $Class.GetCuClassConstructor()
                        }
                    }
                    
                }

                "Set2" {

                    $ClassParams = @{}
                    If( $PSBoundParameters['ClassName'] ) { 
                        $ClassParams.ClassName = $PSBoundParameters['ClassName']
                    }

                    Foreach ( $P in $Path ) {
                        
                        If ( $P.Extension -in '.ps1', '.psm1') {
                            $ClassParams.Path = $P.FullName
                            ## On recupere la classe, Si c'est un ps1 ou psm1 qui ne contient pas de classes alors x est null
                            $x = Get-CuClass @ClassParams
                            If ( $Null -ne $x) {
                                $x.GetCuClassConstructor()
                            }
                        }

                    }

                }

=======


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
>>>>>>> upstream/Feature_Get-CUClassV2
            }

        }


    END {}

}
