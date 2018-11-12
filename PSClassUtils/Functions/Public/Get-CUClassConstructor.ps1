Function Get-CUClassConstructor {
    <#
    .SYNOPSIS
        This function returns all existing constructors of a specific powershell class.
    .DESCRIPTION
        This function returns all existing constructors of a specific powershell class. You can pipe the result of get-cuclass. Or you can specify a file to get all the constructors present in this specified file.
    .PARAMETER ClassName
        Specify the name of the class.
    .PARAMETER Path
        The path of a file containing PowerShell Classes. Accept values from the pipeline.
    .PARAMETER Raw
        The raw switch will display the raw content of the Class.
    .PARAMETER InputObject
        An object, or array of object of type CuClass
    .EXAMPLE
        PS C:\> Get-CUClassConstructor
        Return all the constructors of the classes loaded in the current PSSession.

    .EXAMPLE
        PS C:\> Get-CUClassConstructor -ClassName woop
        ClassName Name    Parameter
        --------- ----    ---------
        woop    woop
        woop    woop       {String, Number}
        Return constructors for the woop Class.

    .EXAMPLE
        PS C:\> Get-CUClassConstructor -Path .\Woop.psm1
        ClassName Name    Parameter
        --------- ----    ---------
        woop    woop
        woop    woop       {String, Number}
        Return constructors for the woop Class present in the woop.psm1 file.

    .EXAMPLE
        PS C:\PSClassUtils> Gci -recurse | Get-CUClassConstructor -ClassName CuClass
        ClassName Name    Parameter
        --------- ----    ---------
        CUClass   CUClass {RawAST}
        CUClass   CUClass {Name, Property, Constructor, Method}
        CUClass   CUClass {Name, Property, Constructor, Method...}
        Return constructors for the CUclass Class present somewhere in the c:\psclassutils folder.
    .INPUTS
        String
    .OUTPUTS
        ClassConstructor
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