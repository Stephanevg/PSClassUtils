# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
or any other method with the owners of this repository before making a change. 


## To contribute, please follow these simple rules:
1. According to the type of submission you are planning to make, create a branch named with one of these prefixes:
     - Feauture: "Feature_"
     - BugFix: "BugFix_"
     - Minor: "Minor_"
     
     Example: Feature_AddGet-CUASTCmdlet
     
2. Update the README.md with details of changes to the the code. 
3. Increase the version numbers in any examples files and the README.md to the new version that this
   Pull Request would represent. The versioning scheme we use is [SemVer](http://semver.org/).
4. Create the PR to the `dev` branch *only*. 

## Renaming a Parameter in a function

Don't remove it directly, have the funciton have the old + new parameter live side by side for at least '2' minor versions. 
Implement a Warning message saying the parameter is deprecated, and that it will need to be replaced in the futur by <ParameterName>

## Diagrams and other generated files


- just making the Pester tests pass, is not enough if you modifiy a cmdlet that generate exported files. 
I have create a .\Examples folder which contains a set of examples that could be used to generate diagrams, for example. Although the Pester tests all pass, please be sure that the new diagrams generated, are identical as the original ones.

- Please push the (re)generated examples diagrams to the repo *ONLY* of they have really something new on them.



Pleas verifiy that the diagram, looks as it 

## When creating a Pull Request (PR) make sure that you have respected the following common sense / best practises:

 1) Comment your code (when needed)
 2) If it is a new feautre / cmdlet, please add some help (Comment based help will suffice in most cases).
 3) One or two examples on how to use it.
 4) That you are targeting the `dev` branch.
    
    
