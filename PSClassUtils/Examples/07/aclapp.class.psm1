Class DirectoryADGroups {

    [String]$FolderName
    [String]$Owner
    [string]$GroupeRead
    [string]$GroupeWrite
    [string]$GroupeOwner
    [string]$GroupeTransverse = $null
    [string]$FirstLevelParent = $null
    [string]$SecondLevelParent = $null
    [string]$FirstLevelParentTransverseGroup = $null
    [string]$SecondLevelParentTransverseGroup = $null
    [Nullable[boolean]]$DoGroupsExistsInAD
    [Hashtable]$GroupeSids = @{}
    [String]$Prefix = $null
    [ValidatePattern("[1-3]")][int] $Depth
    [Log]$Log = $null
    hidden [String]$OUSource = "OU=test,DC=contoso,DC=net"

    ## Constructeur niveau 1
    DirectoryADGroups ([String]$FolderName, [int]$Depth, [String]$Owner, [String]$Prefix) {
        
        $this.FolderName    = $FolderName.ToUpper()
        $this.Prefix        = $Prefix.ToUpper()

        $this.GroupeRead       = $this.Prefix+'-'+$this.FolderName+'-L'
        $this.GroupeWrite      = $this.Prefix+'-'+$this.FolderName+'-M'
        $this.GroupeOwner      = $this.Prefix+'-'+$this.FolderName+'-O'
        $this.GroupeTransverse = $this.Prefix+'-'+$this.FolderName+'-T'

        $this.Depth = $Depth
        $this.Owner = $Owner

    }

    ## Constructeur niveau 2
    DirectoryADGroups ([String]$FolderName, [String]$DirectParentName, [int]$Depth, [String]$Owner, [String]$Prefix) {

        $this.FolderName        = $FolderName.ToUpper()
        $this.Prefix            = $Prefix.ToUpper()
        $this.FirstLevelParent  = $DirectParentName.ToUpper()

        $this.GroupeRead       = $this.Prefix+'-'+$this.FirstLevelParent+'-'+$this.FolderName+'-L'
        $this.GroupeWrite      = $this.Prefix+'-'+$this.FirstLevelParent+'-'+$this.FolderName+'-M'
        $this.GroupeOwner      = $this.Prefix+'-'+$this.FirstLevelParent+'-'+$this.FolderName+'-O'
        $this.GroupeTransverse = $this.Prefix+'-'+$this.FirstLevelParent+'-'+$this.FolderName+'-T'
        $this.FirstLevelParentTransverseGroup = $this.Prefix+'-'+$this.FirstLevelParent+'-T'

        $this.Depth = $Depth
        $this.Owner = $Owner

    }

    ## Constructeur niveau 3
    DirectoryADGroups ([String]$FolderName, [String]$UpperParentName, [String]$DirectParentName, [int]$Depth, [String]$Owner, [String]$Prefix) {

        $this.FolderName        = $FolderName.ToUpper()
        $this.Prefix            = $this.Prefix.ToUpper()
        $this.FirstLevelParent  = $UpperParentName.ToUpper()
        $this.SecondLevelParent = $DirectParentName.ToUpper()

        $this.GroupeRead                        = $this.Prefix+'-'+$this.FirstLevelParent+'-'+$this.SecondLevelParent+'-'+$this.FolderName+'-L'
        $this.GroupeWrite                       = $this.Prefix+'-'+$this.FirstLevelParent+'-'+$this.SecondLevelParent+'-'+$this.FolderName+'-M'
        $this.GroupeOwner                       = $this.Prefix+'-'+$this.FirstLevelParent+'-'+$this.SecondLevelParent+'-'+$this.FolderName+'-O'
        $this.FirstLevelParentTransverseGroup   = $this.Prefix+'-'+$this.FirstLevelParent+'-T'
        $this.SecondLevelParentTransverseGroup  = $this.Prefix+'-'+$this.FirstLevelParent+'-'+$this.SecondLevelParent+'-T'

        $this.Depth = $Depth
        $this.Owner = $Owner

    }

    [Bool]CheckADGroups () {
        If ( $this.Depth -in 1..2 ) {
            [array]$a = $this.GroupeRead,$this.GroupeWrite,$this.GroupeOwner,$this.GroupeTransverse | Get-ADGroup -ErrorAction SilentlyContinue
        } Else {
            [array]$a = $this.GroupeRead,$this.GroupeWrite,$this.GroupeOwner | Get-ADGroup -ErrorAction SilentlyContinue
        }

        If ( $a.count -eq 0 ) {
            $this.DoGroupsExistsInAD = $False
            If ( $this.Log ) { $this.Log.WriteMessage("Les groupes a crees n existent pas dans l'AD -> SUCCESS",$true) }
            return $True
        } Else {
            If ( $this.Log ) { $this.Log.WriteMessage("Certains groupes a crees existent dans l'AD -> FAILURE",$true) ; $this.Log.WriteMessage('-------------------------',$false)  }
            $this.DoGroupsExistsInAD = $True
            return $False
        }
    }

    ## creation des groupes dans l'AD
    [Bool]CreateADGroups () {
        Try {

            New-ADGroup -Name $This.GroupeOwner -SamAccountName $This.GroupeOwner -GroupCategory Security -GroupScope Global -DisplayName $This.GroupeOwner -Path $This.OUSource -ErrorAction Stop
            New-ADGroup -Name $This.GroupeWrite -SamAccountName $This.GroupeWrite -GroupCategory Security -GroupScope Global -DisplayName $This.GroupeWrite -Path $This.OUSource -ErrorAction Stop
            New-ADGroup -Name $This.GroupeRead -SamAccountName $This.GroupeRead -GroupCategory Security -GroupScope Global -DisplayName $This.GroupeRead -Path $This.OUSource -ErrorAction Stop

            If ( $this.Log ) { $this.Log.WriteMessage("Creation des groupes O/R/W: "+($This.GroupeRead -replace '-R$','')+" -> SUCCESS",$true) }

            If ($this.depth -in 1..2) {

                New-ADGroup -Name $This.GroupeTransverse -SamAccountName $This.GroupeTransverse -GroupCategory Security -GroupScope Global -DisplayName $This.GroupeTransverse -Path $This.OUSource -Description "Members of this groups have a list access to the following folder $($this.GroupeTransverse)" -ErrorAction stop
                
                If ( $this.Log ) { $this.Log.WriteMessage("Creation du groupe T: "+$This.GroupeTransverse+" -> SUCCESS",$true) }

                If ($this.Depth -eq 2) {
                    
                    Add-ADGroupMember -Identity $this.FirstLevelParentTransverseGroup -Members $This.GroupeTransverse,$This.GroupeRead,$This.GroupeWrite -ErrorAction Stop
                    If ( $this.Log ) { $this.Log.WriteMessage("Ajout des groupes R/W/T dans le groupe parent : "+$This.FirstLevelParentTransverseGroup+" -> SUCCESS",$true) }

                }
                
            } Else {

                If ($this.depth -eq 3) {

                    Add-ADGroupMember -Identity $this.SecondLevelParentTransverseGroup -Members $This.GroupeRead,$This.GroupeWrite -ErrorAction Stop
                    If ( $this.Log ) { $this.Log.WriteMessage("Ajout des groupes R/W dans le groupe parent : "+$This.SecondLevelParentTransverseGroup+" -> SUCCESS",$true) }

                }
            }

            Return $True

        } Catch {
            
            If ( $this.Log ) { $this.Log.WriteMessage("Problemes rencontrer lors des creations/imbrications des groupes -> FAILURE",$true) ; $this.Log.WriteMessage('-------------------------',$false)  }
            Return $False

        }
    }

    ## Methode de recuperation des SID des groupes afin d'eviter tout probleme de replication AD, lors du positionnement des ACL
    [Void]GetGroupsSIDs (){

        $this.GroupeSids.Add('Read',$(New-Object System.Security.Principal.SecurityIdentifier $((Get-ADGroup -Identity $this.GroupeRead -ErrorAction Stop).Sid.Value)))
        $this.GroupeSids.Add('Modify',$(New-Object System.Security.Principal.SecurityIdentifier $((Get-ADGroup -Identity $this.GroupeWrite -ErrorAction Stop).Sid.Value)))

        If ( $this.Depth -in 1..2) {
            $this.GroupeSids.Add('List',$(New-Object System.Security.Principal.SecurityIdentifier $((Get-ADGroup -Identity $this.GroupeTransverse -ErrorAction Stop).Sid.Value)))
        }
    }

    ## Methode qui positionne le owner dans le groupe -O
    [Bool]SetOwnerMembership () {
        Try{

            Add-ADGroupMember -Identity $This.GroupeOwner -Members $This.Owner -ErrorAction Stop

            If ( $this.Log ) { $this.Log.WriteMessage("Ajout du compte "+$This.Owner+" dans le groupe O: "+$This.GroupeOwner+" -> SUCCESS",$true) ; $this.Log.WriteMessage('-------------------------',$false)  }
            Return $True

        } Catch {

            If ( $this.Log ) { $this.Log.WriteMessage("Ajout du compte "+$This.Owner+" dans le groupe O: "+$This.GroupeOwner+" -> FAILURE",$true) ; $this.Log.WriteMessage('-------------------------',$false)  }
            Return $False
        }
    }

    ## Methode qui remplit le champ description des groupes
    [Void]SetDescription ([String]$String){
        
        Get-ADGroup $this.GroupeOwner | Set-ADGroup -Description "Groupe de Gestion pour le repertoire $String"
        Get-ADGroup $this.GroupeRead  | Set-ADGroup -Description "Groupe en Lecture sur le repertoire $String"
        Get-ADGroup $this.GroupeWrite | Set-ADGroup -Description "Groupe en Modification sur le repertoire $String"

        If ( $this.Depth -in 1..2 ) {
            Get-ADGroup $this.GroupeTransverse | Set-ADGroup -Description "Groupe pour Traverser le repretoire $String"
        }
    }

    ## Methode tout en un
    [PSObject]OneForAll(){

        If ( $this.Log ) { $this.Log.WriteMessage("Class DirectoryADGroups, Method OneForAll",$true) }

        If ( $This.CheckADGroups() ) {
            If ( $This.CreateADGroups() ) {
                If ( $This.SetOwnerMembership() ) {
                    $This.GetGroupsSIDs()
                    Return New-Object -TypeName psobject -Property @{Result=$True;ActionType="OverAll Result";Message="Creating groups "+($This.GroupeRead -replace '-L$','')+" O/L/M (T), and setting owner in group "+$this.GroupeOwner+" SUCCEDED";Log=$This.Log.LogPath}
                } Else {
                    Return New-Object -TypeName psobject -Property @{Result=$False;ActionType="Setting Owner";Message="Setting "+$this.Owner+" in group "+$this.GroupeOwner+" O/L/M (T) FAILED, Check Logs...";Log=$This.Log.LogPath}
                }
            } Else {
                Return New-Object -TypeName psobject -Property @{Result=$False;ActionType="Group(s) Creation";Message="Creating Groups "+($This.GroupeRead -replace '-L$','')+" O/L/M (T) FAILED, Check ADDS and Logs...";Log=$This.Log.LogPath}
            }
        } Else {
            Return New-Object -TypeName psobject -Property @{Result=$False;ActionType="Testing Group(s) Presence";Message="Some groups "+($This.GroupeRead -replace '-L$','')+" O/L/M (T) already exists in ADDS, Check ADDS...";Log=$This.Log.LogPath}
        }
    }

}

Class DirectoryCreation {
    [String]$DirectoryName
    [String]$DirectoryPath
    [String]$DirectoryFullPath
    [DirectoryADGroups]$DirectoryGroups
    hidden [Log]$Log = $null

    ## Constructeur de description du repertoire a cree
    DirectoryCreation ([DirectoryADGroups]$GroupsObject, [String]$DirectoryPath){

        $this.DirectoryGroups = $GroupsObject
        Switch ($this.DirectoryGroups.Depth) {
            1  { $this.DirectoryPath = ($DirectoryPath -replace '\\$','').ToUpper() }
            2  { $this.DirectoryPath = ($DirectoryPath -replace '\\$','').ToUpper() + '\'+ $this.DirectoryGroups.FirstLevelParent }
            3  { $this.DirectoryPath = ($DirectoryPath -replace '\\$','').ToUpper() + '\' +$this.DirectoryGroups.FirstLevelParent + '\' + $this.DirectoryGroups.SecondLevelParent }
        }
        #$this.DirectoryPath = ($DirectoryPath -replace '\\$','').ToUpper()
        $this.DirectoryName =  $this.DirectoryGroups.FolderName
        $this.DirectoryFullPath = $this.DirectoryPath +'\'+$this.DirectoryName

    }

    ## Methode pour construire le repertoire, retour un booleen de succes ou failure
    [Bool] SetDirectory () {

        Try {

            New-Item -Path $this.DirectoryFullPath -ItemType Directory -ErrorAction Stop

            If ( $this.Log ) { $this.Log.WriteMessage('Creation du repertoire: '+$this.DirectoryFullPath+' -> SUCCESS',$true) }
            Return $True

        } Catch {

            If ( $this.Log ) { $this.Log.WriteMessage('Creation du repertoire: '+$this.DirectoryFullPath+' -> FAILURE',$true) ; $this.Log.WriteMessage('-------------------------',$false)  }
            Return $False

        }
    }

    ## Methode pour positionner les bon groupes sur le repertoire
    [Bool] SetAcl () {

        Try {

            $acl = Get-ACL -Path $this.DirectoryFullPath -ErrorAction Stop
            $acl.SetAccessRuleProtection($true,$True)  ## desactive l'h�ritage et copie l'acl courante
            $acl | Set-Acl -ErrorAction Stop

            If ( $this.Log ) { $this.Log.WriteMessage('Desactivation de l heritage sur: '+$this.DirectoryFullPath+' -> SUCCESS',$true) }

        } Catch {

            If ( $this.Log ) { $this.Log.WriteMessage('Desactivation de l heritage sur: '+$this.DirectoryFullPath+' -> FAILURE',$true) ; $this.Log.WriteMessage('-------------------------',$false)  }
            Return $False
        }

        Try{

            ## Recuperation de l acl du repertoire
            $acl = Get-ACL -Path $this.DirectoryFullPath -ErrorAction Stop

            ## On retire le groupe User
            $acl.access | Where-Object IdentityReference -like "BUILTIN\Users" | ForEach-Object{
                $acl.PurgeAccessRules($_.identityreference)
            }

            ## On retire le compte CREATOR OWNER
            $acl.access | Where-Object IdentityReference -like "CREATOR OWNER" | ForEach-Object{
                $acl.PurgeAccessRules($_.identityreference)
            }

            ## On retire les groupes de 1� ou 2� niveau
            If ( $this.DirectoryGroups.Depth -in 2..3 ) {
                $acl.access | Where-Object IdentityReference -like "*$($this.DirectoryGroups.Prefix)*" | ForEach-Object{
                    $acl.PurgeAccessRules($_.identityreference)
                }    
            }

            $acl | Set-Acl -ErrorAction Stop

            If ( $this.Log ) { $this.Log.WriteMessage('Suppression des ACE de type BUILtin\Users & CREATOR OWNER sur: '+$this.DirectoryFullPath+' -> SUCCESS',$true) }

        } Catch {

            If ( $this.Log ) { $this.Log.WriteMessage('Suppression des ACE de type BUILtin\Users & CREATOR OWNER sur: '+$this.DirectoryFullPath+' -> FAILURE',$true) ; $this.Log.WriteMessage('-------------------------',$false) }
            Return $False
        }

        Try{
            ## Recuperation de l acl du repertoire
            $acl = Get-ACL -Path $this.DirectoryFullPath -ErrorAction Stop
            
            ## Creation des regles
            ## Read : groupe L
            $acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($this.DirectoryGroups.GroupeSids['Read'],'ReadAndExecute','ContainerInherit,ObjectInherit','None','Allow')))
            
            If ( $this.DirectoryGroups.Depth -in 1..2 ){
                ## List : groupe T level1 & 2
                $acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($this.DirectoryGroups.GroupeSids['List'],'ReadData, Synchronize','None','None','Allow')))

                ## Write : groupe M level1 & 2
                $acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($this.DirectoryGroups.GroupeSids['Modify'],'ReadData, CreateFiles, ReadPermissions, Synchronize','None','None','Allow')))
                $acl.AddAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($this.DirectoryGroups.GroupeSids['Modify'],'Modify, Synchronize','ObjectInherit','InheritOnly','Allow')))
            } else {
                ## Write : groupe M level3
                $acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($this.DirectoryGroups.GroupeSids['Modify'],'Modify','ContainerInherit,ObjectInherit','None','Allow')))
            }
            
            $acl | Set-Acl -ErrorAction Stop

            If ( $this.Log ) { $this.Log.WriteMessage('Posistionnement des groupes sur l ACL sur: '+$this.DirectoryFullPath+' -> SUCCESS',$true) ; $this.Log.WriteMessage('-------------------------',$false)  }
            return $True

        } Catch {

            If ( $this.Log ) { $this.Log.WriteMessage('Posistionnement des groupes sur l ACL sur: '+$this.DirectoryFullPath+' -> FAILURE',$True) ; $this.Log.WriteMessage('-------------------------',$false) }
            return $False
        }
    }

    ## Methode tout en un
    [PSObject]OneForAll(){

        If ( $this.Log ) { $this.Log.WriteMessage("Class DirectoryCreation, Method OneForAll",$true) }

        If ( $This.SetDirectory() ) {
            If ( $This.SetAcl() ) {
                Return New-Object -TypeName psobject -Property @{Result=$True;ActionType="OverAll Result";Message="Creating directory "+$this.DirectoryFullPath+" and Setting ACL SUCCEDED";Log=$this.Log.LogPath}
            } Else {
                Return New-Object -TypeName psobject -Property @{Result=$False;ActionType="Setting ACLs";Message="Setting ACL on directory "+$this.DirectoryFullPath+" FAILED, Check Logs...";Log=$this.Log.LogPath}
            }
        } Else {
            Return New-Object -TypeName psobject -Property @{Result=$False;ActionType="Creating New Directory";Message="Creating directory "+$this.DirectoryFullPath+" FAILED, Check Logs...";Log=$this.Log.LogPath}
        }
    }

}

Class Log {

    $LogPath = $null

    Log ([String]$a){
        if ( !(test-path $a) ) {
            New-Item -Path $a -ItemType file
            $this.LogPath = $a
        } else {
            $this.LogPath = $a
        }
    }

    Log () {}

    [void] WriteMessage ([String]$m, [Bool]$n){
        If ( $null -ne $this.LogPath  ) {
            If ( $n ) {
                $(get-date -Format "dd/MM/yyyy hh:mm:ss") + ' - ' + $m | Out-File -FilePath $this.LogPath -Append
            } else {
                $m | Out-File -FilePath $this.LogPath -Append
            }
        }
    }
}