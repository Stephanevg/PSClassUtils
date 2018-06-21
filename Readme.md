# PowerShell ClassUtils

This module contains tools to ease the work with Powershell Classes.

The most usefull feature is probably the one **that it can generate UML Class Diagrams in png format of your scripts / modules.** (See Write-UMLClassDiagram)

## Functions currently available:

```powershell
Write-UMLClassDiagram
Get-ClassConstructors
Get-ClassMethods
Get-ClassProperties

```



### Write-UMLClassDiagram

Allows to generate UML diagrams of powerShell scripts / modules that contain PowerShell classes.

This module has a dependency on [Kevin Marquette](https://Twitter/KevinMarquette)'s [PSGraph](https://github.com/KevinMarquette/PSGraph) powershell module.

#### Functionality

It currently support the following features:
- Document Class
    - Properties
    - Methods
    - Constructors
- Inheritance

#### Examples

A script called ```inheritance.ps1``` contains the following code:

```powershell

Class Woop {
    [String]$String
    [int]$number

    Woop([String]$String,[int]$Number){

    }

    [String]DoSomething(){
        return $this.String
    }
}

Class Wap :Woop {
    [String]$prop3

    DoChildthing(){}

}

Class Wep : Woop {
    [String]$prop4

    DoOtherChildThing(){

    }
}

```

#### Calling Write-UMLClassDiagram
```Powershell
.\Write-UMLClassDiagram.ps1 -Path ".\Inheritance.ps1"
```

#### Results

![example with inheritance](/Examples/02/Inheritance.png)

## Live examples from existing modules on the internet:

I took the 'liberty' to run Write-UMLClassDiagram on some well known modules available on the internet that are classed based.
These are all great modules, and I recommend you have a look at them!



### Class.HostsManagement

Below is the export of the Class Diagram of a module I wrote that helps to manage HostsFiles accross the network using PowerShell classes. (The project is accessible  [Here](https://github.com/Stephanevg/Class.HostsManagement))


![Class.HostsManagement](https://github.com/Stephanevg/Class.HostsManagement/blob/master/Class.HostsManagement.png?raw=true)

### Get-ClassConstructors

Coming soon...

### Get-ClassProperties

Coming soon...

### Get-ClassMethods

Coming soon...