Function Get-CUClassConstructor {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [cmdletBinding(DefaultParameterSetName="All")]
    [OutputType([CUClassMethod[]])]
    Param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set1")]
        [CUClass[]]$InputObject,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set2",ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path,

        [Switch]$Raw

    )

    BEGIN {}

    PROCESS {

        Switch ( $PSCmdlet.ParameterSetName ) {

            ## CUClass as input
            Set1 {

                $ClassParams = @{}
                
                ## ClassName was specified
                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $Class in $InputObject ) {
                    If ( $ClassParams.ClassName ) {
                        If ( $Class.Name -eq $ClassParams.ClassName ) {
                            if($Raw){
                                $Class.GetCUClassConstructor().Raw
                            }Else{

                                $Class.GetCUClassConstructor()
                            }
                        }
                    } Else {
                        If ( $null -ne $Class.Constructor ) {
                            if($Raw){
                                $Class.GetCUClassConstructor().Raw
                            }Else{

                                $Class.GetCUClassConstructor()
                            }
                        }
                    }
                }
            }

            Set2 {

                $ClassParams = @{}

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $P in $Path ) {
                   
                    If ( $P.extension -in ".ps1",".psm1" ) {

                        If ($PSCmdlet.MyInvocation.ExpectingInput) {
                            $ClassParams.Path = $P.FullName
                        } Else {
                            $ClassParams.Path = (Get-Item (Resolve-Path $P).Path).FullName
                        }
                        
                        $Class=Get-CuClass @ClassParams
                        If ( $null -ne $Class.Constructor ) {
                            if($Raw){
                                $Class.GetCUClassConstructor().Raw
                            }Else{

                                $Class.GetCUClassConstructor()
                            }
                            
                        }
                    }
                }
            }

            Default {
                $ClassParams = @{}

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach($Class in (Get-CuClass @ClassParams)){
                    If ( $Class.Constructor.count -ne 0 ) {
                        if($Raw){
                            $Class.GetCUClassConstructor().Raw
                        }Else{

                            $Class.GetCUClassConstructor()
                        }
                        
                    }
                }
                
                
            }
        }

    }

    END {}

}