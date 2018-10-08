# PSClassUtils

This module contains tools to ease the work with Powershell Classes.

The most usefull feature is probably the one **that it can generate UML-like Class Diagrams in png format of your scripts / modules.** (See Write-CUClassDiagram)

## How to install PSClassUtils

```powershell
Find-module PSClassUtils | install-Module
```

## Release Notes

Release notes can be found here --> [Release Notes](.\ReleaseNotes.md)


## Functions currently available:

```powershell

Install-CUDiagramPrerequisites
Write-CUClassDiagram
Get-CUClass
Get-CUClassConstructor
Get-CUClassMethod
Get-CUClassProperty
Get-CUCommands
Get-CUEnum

```



### Write-CUClassDiagram

Allows to generate UML diagrams of powerShell scripts / modules that contain PowerShell classes.


### Prerequisites

This module has a dependency on [Kevin Marquette](https://Twitter/KevinMarquette)'s [PSGraph](https://github.com/KevinMarquette/PSGraph) powershell module.
The prerequisites can be installed either manually, or by using the following methodology:

```powershell

Import-Module PSClassutils
Install-CUDiagramPreRequisites

```

### Functionality

#### Drawings

Write-CUClassDiagram currently allows to draw diagrams (or components of diagrams) of the follow items:
- Document a Class
    - it's Properties
    - it's Methods
    - it's Constructors
    - it's Inheritance

Has a relationships (Composition) is currently not supported. (But is planned for a future release)

#### Inputs

It is possible to draw diagrams from classes in the following different manners:
- On a folder level
    - This will create a diagram and document each independant .ps1 file that contains a class. If no classes are found, it will be an empty square.
- File base (.ps1)
    - you can point the function to a single .ps1 file, and will generate the diagram for all the classes located in that file.
- File base (.psm1)
    - you can point the function to a single .psm1 file, and will generate the diagram for all the classes located in that file.

#### Examples

A script called ```inheritance.ps1``` contains the following code:

```powershell

Class Woop {
    [String]$String
    [int]$number

    Woop([String]$String,[int]$Number){
s
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

#### Calling Write-CUClassDiagram
```Powershell
Write-CUClassDiagram -Path ".\Inheritance.ps1"
```

#### Results

![example with inheritance](/Examples/02/Inheritance.png)

## Live examples from existing modules on the internet:

I took the 'liberty' to run Write-CUClassDiagram on some well known modules available on the internet that are classed based.
These are all great modules, and I recommend you have a look at them!



### Class.HostsManagement

Below is the export of the Class Diagram of a module I wrote that helps to manage HostsFiles accross the network using PowerShell classes. (The project is accessible  [Here](https://github.com/Stephanevg/Class.HostsManagement))


![Class.HostsManagement](https://github.com/Stephanevg/Class.HostsManagement/blob/master/Images//Class.HostsManagement.png?raw=true)


### Poshbot

Write-CUClassDiagram allows to generate diagrams of complex class based modules, and gives you the ability to have a global picture of any project quickly, without reading through the code. PoshBot is probably the best example:

![PoshBot](https://github.com/Stephanevg/PSClassUtils/blob/master/Examples/06/PoshBot_Diagram.png?raw=true)

### AclApp

Acl class is used to create a 3 levels folder structure in a standardized way. The acl creates both folders and corresponding groups and set acl.

![AclApp](https://github.com/LxLeChat/PSClassUtils/blob/master/Examples/07/aclapp.class.png)

### Get-ClassConstructors

Coming soon...

### Get-ClassProperties

Coming soon...

### Get-ClassMethods

Coming soon...

## Contributing guide

You feel like contributing to this project? Awesome! We are happy to hear that, and will to help you succeed in that.
You can start by reading our [Contribution guide](CONTRIBUTING.MD).

Please don't hesitate to open an issue so we can quickly discuss about implementation details  and design of your, perhaps to be, new feature of PSClassutils :)
