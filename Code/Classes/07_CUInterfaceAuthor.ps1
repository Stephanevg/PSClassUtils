using namespace System.Collections.Generic
using namespace System.Reflection

class CUInterfaceAuthor
{
    hidden [List[PropertyInfo]] $_properties
    hidden [List[MethodInfo]] $_methods

    [List[Type]]$Interfaces

    InterfaceAuthor([string]$Name,[type]$Interface)
    {
        $this.Interfaces = [List[type]]::new()
        $this.Interfaces.Add($Interface)
        $this.Interfaces.AddRange($Interface.GetInterfaces())

        $this._properties = [List[PropertyInfo]]::new()
        $this._methods = [List[MethodInfo]]::new()

        foreach($iface in $this.Interfaces){
            $this._properties.AddRange($iface.GetProperties())
            $this._methods.AddRange($iface.GetMethods())
        }
    }

    [string]
    GetPropertySection()
    {
        $sb = [System.Text.StringBuilder]::new()
        foreach($property in $this._properties){
            $sb = $sb.AppendFormat('  [{0}]${1}', $property.PropertyType, $property.Name).AppendLine()
        }

        return $sb.ToString()
    }

    [string]
    GetMethodSection()
    {
        $sb = [System.Text.StringBuilder]::new()
        foreach($method in $this._methods |? Name -notmatch '^(g|s)et_'){
            $sb = $sb.AppendFormat("  [{0}]{1}  {2}({3}){1}  {{{1}    throw '{2} not implemented '{1}  }}", $method.ReturnType, [Environment]::NewLine, $method.Name, ($method.GetParameters().ForEach({'[{0}]${1}' -f $_.ParameterType,$_.Name}) -join ', ')).AppendLine().AppendLine()
        }

        return $sb.ToString()
    }
}
