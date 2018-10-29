function Get-CULoadedClass {
    [CmdletBinding()]
    param (
        [String[]]$ClassName = '*'
    )
    
    BEGIN {
    }
    
    PROCESS {
        
        Foreach ( $Name in $ClassName ) {
            #write-host $name
            [Array]$LoadedClasses = [AppDomain]::CurrentDomain.GetAssemblies() |
                Where-Object { $_.GetCustomAttributes($false) |
                Where-Object { $_ -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute]} } |
                ForEach-Object { 
                    $_.GetTypes() |
                    Where-Object IsPublic | Where-Object { $_.Name -like $Name } |
                    Select-Object @{l = 'Path'; e = {($_.Module.ScopeName.Replace([char]0x29F9, '\').replace([char]0x589, ':')) -replace '^\\', ''}}
            }

            Foreach ( $Class in $LoadedClasses ) {
                Get-CURaw -Path $Class.Path
            }

        }
    }
    
    END {
    }
}