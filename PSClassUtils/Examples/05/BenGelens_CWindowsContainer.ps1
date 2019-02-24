enum Ensure {
    Absent
    Present
}

enum ContainerType {
    Default
    HyperV
}

enum AccessMode {
    ReadWrite
    ReadOnly
}

[DscResource()]
class cWindowsContainer {
    [DscProperty(Key)]
    [String] $Name

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Mandatory)]
    [String] $ContainerImageName

    [DscProperty()]
    [String] $ContainerImagePublisher

    [DscProperty()]
    [String] $ContainerImageVersion

    [DscProperty()]
    [String] $SwitchName

    [DscProperty()]
    [String] $StartUpScript

    [DscProperty(NotConfigurable)]
    [String] $IPAddress

    [DscProperty(NotConfigurable)]
    [String] $ContainerId

    [DscProperty()]
    [String] $ContainerComputerName

    [DscProperty()]
    [String] $SourcePath

    [DscProperty()]
    [String] $DestinationPath

    [DscProperty()]
    [AccessMode] $AccessMode = 'ReadOnly'

    [DscProperty()]
    [ContainerType] $ContainerType = [ContainerType]::Default

    [void] Set () {
        try {
            if ($this.Ensure -eq [Ensure]::Present) {
                Write-Verbose -Message 'Starting creation of new Container'

                #region start build New-Container parameters
                $ContainerNewParams = [System.Collections.Hashtable]::new()
                $ContainerNewParams.Add('Name',$this.Name)
                $ContainerNewParams.Add('RuntimeType',$this.ContainerType)
                if ($null -ne $this.ContainerComputerName) {
                    $ContainerNewParams.Add('ContainerComputerName',$this.ContainerComputerName)
                }
                #endregion start build New-Container parameters

                #region ContainerImage
                $ContainerImageParams = [System.Collections.Hashtable]::new()
                $ContainerImageParams.Add('Name',$this.ContainerImageName)
                if ($null -ne $this.ContainerImagePublisher) {
                    $ContainerImageParams.Add('Publisher',$this.ContainerImagePublisher)
                }
                if ($null -ne $this.ContainerImageVersion) {
                    $ContainerImageParams.Add('Version',$this.ContainerImageVersion)
                }
                Write-Verbose -Message "Searching for image: $($ContainerImageParams | Out-String)"
                if ($null -eq ($Image = Get-ContainerImage @ContainerImageParams)) {
                    Write-Error -Message "ContainerImage with properties $($ContainerImageParams | Out-String) was not found" -ErrorAction Stop
                } else {
                    $ContainerNewParams.Add('ContainerImage',$Image)
                }
                #endregion ContainerImage

                #region Switch
                Write-Verbose -Message "Searching for specified switch: $($this.SwitchName)"
                if ($this.SwitchName -and ($null -ne (Get-VMSwitch -Name $this.SwitchName))) {
                    Write-Verbose -Message 'Switch was found and will be bound'
                    $ContainerNewParams.Add('SwitchName',$this.SwitchName)
                } elseif ($this.SwitchName -and ($null -eq (Get-VMSwitch -Name $this.SwitchName))) {
                    Write-Error -Message "Switch with name $($this.SwitchName) was not found" -ErrorAction Stop
                }
                #endregion Switch

                #region Create Container
                Write-Verbose -Message "Creating Container: $($ContainerNewParams | Out-String)"
                $Container = New-Container @ContainerNewParams
                #endregion Create Container

                #region add SharedFolder
                Write-Verbose -Message "Validating if a SharedFolder is needed"
                if ($this.SourcePath) {
                    if ((Test-Path $this.SourcePath) -and ($this.DestinationPath -ne "")) {
                        Write-Verbose -Message "Mapping $($this.sourcePath) to $($this.DestinationPath)"
                        $SharedFolderNewParams = [System.Collections.Hashtable]::new()
                        $SharedFolderNewParams.Add('ContainerName',$this.Name)
                        $SharedFolderNewParams.Add('SourcePath',$this.SourcePath)
                        $SharedFolderNewParams.Add('DestinationPath',$this.DestinationPath)
                        $SharedFolderNewParams.Add('AccessMode',$this.AccessMode)
                        Add-ContainerSharedFolder @SharedFolderNewParams
                    } else {
                        Write-Error -Message "$($this.SourcePath) isn't available or missing destination path in configuration"
                    }
                } else {
                    Write-Verbose -Message "No SharedFolder needed"
                }

                #region start Container
                Write-Verbose -Message "Starting Container $($this.Name)"
                $Container | Start-Container
                #endregion start container

                #region run startup script
                if ($null -ne $this.StartUpScript) {
                    Write-Verbose -Message 'Startup Script specified, passing script to InvokeScript method'
                    [void] $this.InvokeScript(([scriptblock]::Create($this.StartUpScript)),$Container.ContainerId)
                }
                #endregion run startup script
            } else {
                Write-Verbose -Message 'Removing Container'
                Get-Container -Name $this.Name | Stop-Container -Passthru | Remove-Container -Force

            }
        } catch {
            Write-Error -ErrorRecord $_ -ErrorAction Stop
        }
    }

    [bool] Test () {
        if ((Get-Container -Name $this.Name -ErrorAction SilentlyContinue) -and ($this.Ensure -eq [Ensure]::Present)) {
            $value = $true
            $SharedFolder = Get-ContainerSharedFolder -ContainerName $this.Name -ErrorAction SilentlyContinue
            if (($SharedFolder.SourcePath -eq $this.SourcePath) -and ($SharedFolder.DestinationPath -eq $this.DestinationPath) -and ($SharedFolder.AccessMode -eq $this.AccessMode)) {
                $Value = $true
            } else {
                $Value = $false
            }
            return $value
        } else {
            return $false
        }
    }

    [String] InvokeScript ([String] $Script, [String] $ContainerId) {
        $Output = Invoke-Command -ContainerId $ContainerId -RunAsAdministrator -ScriptBlock ([scriptblock]::Create($Script)) -ErrorAction Stop
        return $Output
    }

    [cWindowsContainer] Get () {
        $Configuration = [System.Collections.Hashtable]::new()
        $Configuration.Add('Name',$this.Name)
        $Configuration.Add('ContainerComputerName',$this.ContainerComputerName)
        $Configuration.Add('ContainerImageName',$this.ContainerImageName)
        $Configuration.Add('ContainerImagePublisher',$this.ContainerImagePublisher)
        $Configuration.Add('ContainerImageVersion',$this.ContainerImageVersion)
        $Configuration.Add('SwitchName',$this.SwitchName)
        $Configuration.Add('StartUpScript',$this.StartUpScript)
        $Configuration.Add('ContainerType',$this.ContainerType)
        if (($this.Ensure -eq [Ensure]::Present) -and ($this.Test())) {
            Write-Verbose -Message 'Acquiring ContainerId'
            $Configuration.Add('ContainerId',(Get-Container -Name $this.Name).ContainerId)
            $Configuration.Add('Ensure','Present')
            Write-Verbose -Message 'Acquiring IPAddress'
            if ($null -ne $this.SwitchName) {
                $Configuration.Add('IPAddress',$this.InvokeScript('(Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Manual).IPAddress',$Configuration.ContainerId))
            }
            if ($this.SourcePath) {
                $SharedFolder = Get-ContainerSharedFolder -ContainerName $this.Name
                $Configuration.Add('SourcePath',$SharedFolder.SourcePath)
                $Configuration.Add('DestinationPath',$SharedFolder.DestinationPath)
                $Configuration.Add('AccessMode',$SharedFolder.AccessMode)
            }
        } else {
            $Configuration.Add('Ensure','Absent')
        }
        return $Configuration
    }
}