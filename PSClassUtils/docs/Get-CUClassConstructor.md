---
external help file: PSClassUtils-help.xml
Module Name: PSClassUtils
online version:
schema: 2.0.0
---

# Get-CUClassConstructor

## SYNOPSIS
This function returns all existing constructors of a specific powershell class.

## SYNTAX

### All (Default)
```
Get-CUClassConstructor [-ClassName <String[]>] [-Raw] [<CommonParameters>]
```

### Set1
```
Get-CUClassConstructor [-ClassName <String[]>] [-InputObject <CUClass[]>] [-Raw] [<CommonParameters>]
```

### Set2
```
Get-CUClassConstructor [-ClassName <String[]>] [-Path <FileInfo[]>] [-Raw] [<CommonParameters>]
```

## DESCRIPTION
This function returns all existing constructors of a specific powershell class.
You can pipe the result of get-cuclass.
Or you can specify a file to get all the constructors present in this specified file.

## EXAMPLES

### EXEMPLE 1
```
Get-CUClassConstructor
```

Return all the constructors of the classes loaded in the current PSSession.

PS C:\\\> Get-CUClassConstructor -ClassName woop
ClassName Name    Parameter
--------- ----    ---------
woop    woop
woop    woop       {String, Number}
Return constructors for the woop Class.

PS C:\\\> Get-CUClassConstructor -Path .\Woop.psm1
ClassName Name    Parameter
--------- ----    ---------
woop    woop
woop    woop       {String, Number}
Return constructors for the woop Class present in the woop.psm1 file.

PS C:\PSClassUtils\> Gci -recurse | Get-CUClassConstructor -ClassName CuClass
ClassName Name    Parameter
--------- ----    ---------
CUClass   CUClass {RawAST}
CUClass   CUClass {Name, Property, Constructor, Method}
CUClass   CUClass {Name, Property, Constructor, Method...}
Return constructors for the CUclass Class present somewhere in the c:\psclassutils folder.

## PARAMETERS

### -ClassName
Specify the name of the class.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
An object, or array of object of type CuClass

```yaml
Type: CUClass[]
Parameter Sets: Set1
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
The path of a file containing PowerShell Classes.
Accept values from the pipeline.

```yaml
Type: FileInfo[]
Parameter Sets: Set2
Aliases: FullName

Required: False
Position: Named
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

### String
## OUTPUTS

### ClassConstructor
## NOTES
Author: St ©phane van Gulick
Version: 0.7.1
www.powershellDistrict.com
Report bugs or submit feature requests here:
https://github.com/Stephanevg/PowerShellClassUtils

## RELATED LINKS
