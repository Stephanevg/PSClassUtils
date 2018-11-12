---
external help file: PSClassUtils-help.xml
Module Name: PSClassUtils
online version:
schema: 2.0.0
---

# Write-CUClassDiagram

## SYNOPSIS
This script allows to document automatically existing script(s)/module(s) containing classes by generating the corresponding UML Diagram.

## SYNTAX

```
Write-CUClassDiagram [-Path <String>] [-FolderPath <String>] [-Recurse] [-ExportFolder <DirectoryInfo>]
 [-OutputFormat <String>] [-Show] [-PassThru] [-IgnoreCase] [<CommonParameters>]
```

## DESCRIPTION
Automatically generate a UML diagram of scripts/Modules that contain powershell classes.

## EXAMPLES

### EXEMPLE 1
```
#Generate a UML diagram of the classes located in MyClass.Ps1
```

# The diagram will be automatically created in the same folder as the file that contains the classes (C:\Classes).

Write-CUClassDiagram.ps1 -File C:\Classes\MyClass.ps1

### EXEMPLE 2
```
#Various output formats are available using the parameter "OutPutFormat"
```

Write-CUClassDiagram.ps1 -File C:\Classes\Logging.psm1 -ExportFolder C:\admin\ -OutputFormat gif


Directory: C:\admin


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----       12.06.2018     07:47          58293 Logging.gif

### EXEMPLE 3
```
Write-CUClassDiagram -Path "C:\Modules\PSClassUtils\Classes\Private\" -Show
```

Will generate a diagram of all the private classes available in the Path specified, and immediatley show the diagram.

## PARAMETERS

### -Path
The path that contains the classes that need to be documented. 
The path parameter should point to either a .ps1, .psm1 file, or a directory containing either/both of those file types.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FolderPath
This parameter is deprecated, and will be removed in a future version.
Please use -Path instead

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse
{{Fill Recurse Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportFolder
This optional parameter, allows to specifiy an alternative export folder.
By default, the diagram is created in the same folder as the source file.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFormat
Using the parameter OutputFormat, it is possible change the default output format (.png) to one of the following ones:

'jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Png
Accept pipeline input: False
Accept wildcard characters: False
```

### -Show
Open's the generated diagram immediatly

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
When specified, the raw Graph inn GraphViz format will be returned back in String format.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IgnoreCase
By default, Class names MUST be case identical to have the Write-CUClassDiagram cmdlet generate the correct inheritence tree.
When the switch -IgnoreCase is specified, All class names will be converted to 'Titlecase' to force the case, and ensure the inheritence is correctly drawed in the Class Diagram.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: St ©phane van Gulick
Version: 0.8.2
www: www.powershellDistrict.com
Report bugs or ask for feature requests here:
https://github.com/Stephanevg/Write-CUClassDiagram

## RELATED LINKS
