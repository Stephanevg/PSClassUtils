Class Woop {
    [String]$String
    [int]$number

    Woop(){

    }

    Woop([String]$String,[int]$Number){
        
    }
    Woop([String]$String,[int]$Number,[DateTime]$Time){
    
    }

    [String]DoSomething(){
        return $this.String
    }
}

Class Wap :Woop {
    [String]$prop3

    DoChildthing(){}
    [int]DoChildthing2(){
        return 3
    }
    DoChildthing3([int]$Param1,[bool]$Param2){
        #Does stuff
    }
    [Bool] DoChildthing4([String]$MyString,[int]$MyInt,[DateTime]$MyDate){
        return $true
    }
    

}

Class Wep : Woop {
    [String]$prop4

    DoOtherChildThing(){

    }
}