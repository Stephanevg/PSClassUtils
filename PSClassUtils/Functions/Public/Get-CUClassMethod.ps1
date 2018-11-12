Function Get-CUClassMethod {
    <#
    .SYNOPSIS
        This function returns all existing constructors of a specific powershell class.
    .DESCRIPTION
        This function returns all existing constructors of a specific powershell class. You can pipe the result of get-cuclass. Or you can specify a file to get all the constructors present in this specified file.
    .PARAMETER ClassName
        Specify the name of the class.
    .PARAMETER MethodName
        Specify the name of a specific Method
    .PARAMETER Path
        The path of a file containing PowerShell Classes. Accept values from the pipeline.
    .PARAMETER Raw
        The raw switch will display the raw content of the Class.
    .PARAMETER InputObject
        An object, or array of object of type CuClass
    .EXAMPLE
        PS C:\> Get-CUClassMethod
        Return all the methods of the classes loaded in the current PSSession.

    .EXAMPLE
        PS C:\> Get-CUClassMethod -ClassName woop
        ClassName Name    Parameter
        --------- ----    ---------
        woop    woop
        woop    woop       {String, Number}
        Return methods for the woop Class.

    .EXAMPLE
        PS C:\> Get-CUClassMethod -Path .\Woop.psm1
        ClassName Name    Parameter
        --------- ----    ---------
        woop    woop
        woop    woop       {String, Number}
        Return methods for the woop Class present in the woop.psm1 file.

    .EXAMPLE
        PS C:\PSClassUtils> Gci -recurse | Get-CUClassMethod -ClassName CuClass
        ClassName Name    Parameter
        --------- ----    ---------
        CUClass   CUClass {RawAST}
        CUClass   CUClass {Name, Property, Constructor, Method}
        CUClass   CUClass {Name, Property, Constructor, Method...}
        Return methods for the CUclass Class present somewhere in the c:\psclassutils folder.
    .INPUTS
        String
    .OUTPUTS
        CUClassMethod
    .NOTES   
        Author: Stéphane van Gulick
        Version: 0.7.1
        www.powershellDistrict.com
        Report bugs or submit feature requests here:
        https://github.com/Stephanevg/PowerShellClassUtils
    #>
    [cmdletBinding(DefaultParameterSetName="All")]
    [OutputType([CUClassMethod[]])]
    Param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$MethodName='*',

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
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($Class.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $Class.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                        }
                    } Else {
                        If ( $null -ne $Class.Method ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($Class.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $Class.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                        }
                    }
                }
            }

            ## System.io.FileInfo as Input
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
                        
                        $x=Get-CuClass @ClassParams
                        If ( $null -ne $x.Method ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($x.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $x.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                            
                        }
                    }
                }
            }

            ## System.io.FileInfo or Path Not Specified
            Default {
                $ClassParams = @{}

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }
                
                Foreach( $x in (Get-CuClass @ClassParams) ){
                    If ( $x.Method.count -ne 0 ) {
                        If ( $PSBoundParameters['Raw'] ) {
                                
                            ($x.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                        } Else {
                            $x.GetCUClassMethod() | Where-Object Name -like $MethodName
                        }
                    }
                }
                
                
            }
        }

    }

    END {}

}