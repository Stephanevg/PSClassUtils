function Get-CULoadedClass {
    <#
    .SYNOPSIS
        Return all loaded classes in the current PSSession
    .DESCRIPTION
        Return all loaded classes in the current PSSession
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        String
    .OUTPUTS
        ASTDocument
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [String[]]$ClassName = '*'
    )
    
    BEGIN {
    }
    
    PROCESS {
        
        Foreach ( $Name in $ClassName ) {
            
            [Array]$LoadedClasses = [AppDomain]::CurrentDomain.GetAssemblies() |
                Where-Object { $_.GetCustomAttributes($false) |
                Where-Object { $_ -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute]} } |
                ForEach-Object { 
                    $_.GetTypes() |
                    Where-Object IsPublic | Where-Object { $_.Name -like $Name } |
                    Select-Object @{l = 'Path'; e = {($_.Module.ScopeName.Replace([char]0x29F9, '\').replace([char]0x589, ':')) -replace '^\\', ''}}
            }

            Foreach ( $Class in ($LoadedClasses | Select-Object -Property Path -Unique) ) {
                Get-CURaw -Path $Class.Path
            }

        }
    }
    
    END {
    }
}