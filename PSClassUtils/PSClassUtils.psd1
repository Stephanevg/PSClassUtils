#
# Manifeste de module pour le module « PSGet_PSClassUtils »
#
# Généré par : StÃ©phane van Gulick
#
# Généré le : 02/07/2019
#

@{

# Module de script ou fichier de module binaire associé à ce manifeste
RootModule = 'PSClassUtils.psm1'

# Numéro de version de ce module.
ModuleVersion = '2.6.3'

# Éditions PS prises en charge
# CompatiblePSEditions = @()

# ID utilisé pour identifier de manière unique ce module
GUID = 'c60f1a5b-deb3-44e7-8193-77aaa92ffb42'

# Auteur de ce module
Author = 'StÃ©phane van Gulick'

# Société ou fournisseur de ce module
CompanyName = 'District'

# Déclaration de copyright pour ce module
Copyright = '(c) 2018 TAAVAST3. All rights reserved.'

# Description de la fonctionnalité fournie par ce module
Description = 'Contains a set of utilities to work with Powershell Classes.'

# Version minimale du moteur Windows PowerShell requise par ce module
PowerShellVersion = '5.0'

# Nom de l'hôte Windows PowerShell requis par ce module
# PowerShellHostName = ''

# Version minimale de l'hôte Windows PowerShell requise par ce module
# PowerShellHostVersion = ''

# Version minimale du Microsoft .NET Framework requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# DotNetFrameworkVersion = ''

# Version minimale de l’environnement CLR (Common Language Runtime) requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# CLRVersion = ''

# Architecture de processeur (None, X86, Amd64) requise par ce module
# ProcessorArchitecture = ''

# Modules qui doivent être importés dans l'environnement global préalablement à l'importation de ce module
# RequiredModules = @()

# Assemblys qui doivent être chargés préalablement à l'importation de ce module
# RequiredAssemblies = @()

# Fichiers de script (.ps1) exécutés dans l’environnement de l’appelant préalablement à l’importation de ce module
# ScriptsToProcess = @()

# Fichiers de types (.ps1xml) à charger lors de l'importation de ce module
# TypesToProcess = @()

# Fichiers de format (.ps1xml) à charger lors de l'importation de ce module
# FormatsToProcess = @()

# Modules à importer en tant que modules imbriqués du module spécifié dans RootModule/ModuleToProcess
# NestedModules = @()

# Fonctions à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucune fonction à exporter.
FunctionsToExport = 'Get-CUClass', 'Get-CUClassConstructor', 'Get-CUClassMethod', 
               'Get-CUClassProperty', 'Get-CUCommands', 'Get-CUEnum', 
               'Get-CULoadedClass', 'Get-CURaw', 'Install-CUDiagramPrerequisites', 
               'Test-IsCustomType', 'Write-CUClassDiagram', 
               'Write-CUInterfaceImplementation', 'Write-CUPesterTest'

# Applets de commande à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucune applet de commande à exporter.
CmdletsToExport = @()

# Variables à exporter à partir de ce module
VariablesToExport = '*'

# Alias à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucun alias à exporter.
AliasesToExport = @()

# Ressources DSC à exporter depuis ce module
# DscResourcesToExport = @()

# Liste de tous les modules empaquetés avec ce module
# ModuleList = @()

# Liste de tous les fichiers empaquetés avec ce module
# FileList = @()

# Données privées à transmettre au module spécifié dans RootModule/ModuleToProcess. Cela peut également inclure une table de hachage PSData avec des métadonnées de modules supplémentaires utilisées par PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Classes','helper','diagram','uml','psgraph','graphviz','class'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Stephanevg/PSClassUtils'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '
        
        2.5.0 - 20190228
            Enhanced Write-CUPEsterScripts (Added -PassThru)
            Fixed Minor bugs.

        2.4.2 - 20190227
            Added Write-CUPesterScripts
            Added Get-CUPesterScripts

        2.3.0 - 20190125
            Added possibility to exclude some classes from the Diagram Generation.
            Write-CuClassDiagram -Exclude
        
         2.2.5 - 20181213
            Added support for -ShowComposition on Wirte-CuClassDiagram
            Rewrote base AST parsing and base classes.
        '

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# URI HelpInfo de ce module
# HelpInfoURI = ''

# Le préfixe par défaut des commandes a été exporté à partir de ce module. Remplacez le préfixe par défaut à l’aide d’Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

