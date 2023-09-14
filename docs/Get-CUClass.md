---
external help file: PSClassUtils-help.xml
Module Name: PSClassUtils
online version:
schema: 2.0.0
---

# Get-CUClass

## SYNOPSIS
This function returns all classes, loaded in memory or present in a ps1 or psm1 file.

## SYNTAX

```
Get-CUClass [-ClassName <Object>] [[-Path] <FileInfo[]>] [-Raw] [<CommonParameters>]
```

## DESCRIPTION
By default, the function will return all loaded classes in the current PSSession.
You can specify a file path to explore the classes present in a ps1 or psm1 file.

## EXAMPLES

### EXAMPLE 1
```
Get-CUClass
```

Return all classes alreay loaded in current PSSession.

### EXAMPLE 2
```
Get-CUClass -ClassName CUClass
```

Return the particuluar CUCLass.

### EXAMPLE 3
```
Get-CUClass -Path .\test.psm1,.\test2.psm1
```

Return all classes present in the test.psm1 and test2.psm1 file.

### EXAMPLE 4
```
Get-CUClass -Path .\test.psm1 -ClassName test
```

Return test class present in the test.psm1 file.

### EXAMPLE 5
```
Get-ChildItem -recurse | Get-CUClass
```

Return all classes, recursively, present in the C:\PSClassUtils Folder.

## PARAMETERS

### -ClassName
Specify the name of the class.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The path of a file containing PowerShell Classes.
Accept values from the pipeline.

```yaml
Type: FileInfo[]
Parameter Sets: (All)
Aliases: FullName

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Raw
The raw switch will display the raw content of the Class.

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

### Accepts type [System.IO.FileInfo]
## OUTPUTS

### Return type [CuClass]
## NOTES
Author: Tobias Weltner
Version: ??
Source --\> http://community.idera.com/powershell/powertips/b/tips/posts/finding-powershell-classes
Participate & contribute --\> https://github.com/Stephanevg/PSClassUtils

## RELATED LINKS
