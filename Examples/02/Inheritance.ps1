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