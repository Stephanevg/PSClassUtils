function Write-CUInterfaceImplementation
{
    param(
        [string]$Name,
        [type]$InterfaceType
    )

    if(-not [System.CodeDom.Compiler.CodeGenerator]::IsValidLanguageIndependentIdentifier($Name)){
        throw "'$Name' is not a valid type name"
        return
    }

    if(-not $InterfaceType.IsInterface){
        throw "'$InterfaceType' is not an interface"
    }

    try{
        $author = [CUInterfaceAuthor]::new($Name, $InterfaceType)

        $sb = [System.Text.StringBuilder]::new()
        $sb = $sb.AppendFormat("class {0} : {1}", $Name, $InterfaceType).AppendLine()
        $sb = $sb.AppendLine('{')
        $sb = $sb.AppendLine($author.GetPropertySection())
        $sb = $sb.Append($author.GetMethodSection())
        $sb = $sb.AppendLine('}')

        return $sb.ToString()
    }
    finally{
        $null = $sb.Clear()
    }
}
