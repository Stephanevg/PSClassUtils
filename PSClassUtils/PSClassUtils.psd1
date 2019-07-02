#
# Manifeste de module pour le module ��PSGet_PSClassUtils��
#
# G�n�r� par�: Stéphane van Gulick
#
# Generated on: 3/25/2019
#

@{

# Module de script ou fichier de module binaire associ� � ce manifeste
RootModule = 'PSClassUtils.psm1'

# Num�ro de version de ce module.
ModuleVersion = '2.6.3'

# �ditions PS prises en charge
# CompatiblePSEditions = @()

# ID utilis� pour identifier de mani�re unique ce module
GUID = 'c60f1a5b-deb3-44e7-8193-77aaa92ffb42'

# Auteur de ce module
Author = 'Stéphane van Gulick'

# Soci�t� ou fournisseur de ce module
CompanyName = 'District'

# D�claration de copyright pour ce module
Copyright = '(c) 2018 TAAVAST3. All rights reserved.'

# Description de la fonctionnalit� fournie par ce module
Description = 'Contains a set of utilities to work with Powershell Classes.'

# Version minimale du moteur Windows PowerShell requise par ce module
PowerShellVersion = '5.0'

# Nom de l'h�te Windows PowerShell requis par ce module
# PowerShellHostName = ''

# Version minimale de l'h�te Windows PowerShell requise par ce module
# PowerShellHostVersion = ''

# Version minimale du Microsoft .NET Framework requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# DotNetFrameworkVersion = ''

# Version minimale de l�environnement CLR (Common Language Runtime) requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# CLRVersion = ''

# Architecture de processeur (None, X86, Amd64) requise par ce module
# ProcessorArchitecture = ''

# Modules qui doivent �tre import�s dans l'environnement global pr�alablement � l'importation de ce module
# RequiredModules = @()

# Assemblys qui doivent �tre charg�s pr�alablement � l'importation de ce module
# RequiredAssemblies = @()

# Fichiers de script (.ps1) ex�cut�s dans l�environnement de l�appelant pr�alablement � l�importation de ce module
# ScriptsToProcess = @()

# Fichiers de types (.ps1xml) � charger lors de l'importation de ce module
# TypesToProcess = @()

# Fichiers de format (.ps1xml) � charger lors de l'importation de ce module
# FormatsToProcess = @()

# Modules � importer en tant que modules imbriqu�s du module sp�cifi� dans RootModule/ModuleToProcess
# NestedModules = @()

# Fonctions � exporter � partir de ce module. Pour de meilleures performances, n�utilisez pas de caract�res g�n�riques et ne supprimez pas l�entr�e. Utilisez un tableau vide si vous n�avez aucune fonction � exporter.
FunctionsToExport = 'Get-CUClass', 'Get-CUClassConstructor', 'Get-CUClassMethod', 
               'Get-CUClassProperty', 'Get-CUCommands', 'Get-CUEnum', 
               'Get-CULoadedClass', 'Get-CURaw', 'Install-CUDiagramPrerequisites', 
               'Test-IsCustomType', 'Write-CUClassDiagram', 
               'Write-CUInterfaceImplementation', 'Write-CUPesterTest'

# Applets de commande � exporter � partir de ce module. Pour de meilleures performances, n�utilisez pas de caract�res g�n�riques et ne supprimez pas l�entr�e. Utilisez un tableau vide si vous n�avez aucune applet de commande � exporter.
CmdletsToExport = @()

# Variables � exporter � partir de ce module
VariablesToExport = '*'


# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'digraph'

# Ressources DSC � exporter depuis ce module
# DscResourcesToExport = @()

# Liste de tous les modules empaquet�s avec ce module
# ModuleList = @()

# Liste de tous les fichiers empaquet�s avec ce module
# FileList = @()

# Donn�es priv�es � transmettre au module sp�cifi� dans RootModule/ModuleToProcess. Cela peut �galement inclure une table de hachage PSData avec des m�tadonn�es de modules suppl�mentaires utilis�es par PowerShell.
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

# Le pr�fixe par d�faut des commandes a �t� export� � partir de ce module. Remplacez le pr�fixe par d�faut � l�aide d�Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

