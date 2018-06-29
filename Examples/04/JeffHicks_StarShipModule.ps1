#requires -version 5.0

#The original script/Module is available here --> https://github.com/jdhitsolutions/myStarShip
#All rights go to Jeff Hicks

#demonstrate PowerShell classes in v5 using inheritance

#This is a Non-DSC resource example.

#region Enums

Enum ShipClass {
    Shuttle
    Clipper
    Frigate
    Transport
    XWing
    Cruiser
    Destroyer
    Battlestar
    Dreadnought    
}

Enum ShipSpeed {
    Stopped
    Impulse
    Sublight
    Translight
}

Enum Cloak {
    Absent
    Present
}

#endregion

#region general class definition

Class mystarshIp {

    #region properties
    [ValidateNotNullorEmpty()]
    [string]$Name 

    [ValidateNotNullorEmpty()]
    [Shipclass]$ShipClass 

    [ValidateNotNullorEmpty()]
    [ShipSpeed]$Speed 

    [ValidateRange(1,1000)]
    [int]$Crew = 1

    [boolean]$Shields = $False

    [ValidateRange(0,20)]
    [int]$Torpedos = 0

    [string]$Captain = $env:USERNAME

    [Cloak]$CloakingDevice

    #These are hidden properties
    hidden [string]$Transponder = [guid]::NewGuid().Guid
    hidden [datetime]$ManufacturingDate = (Get-Date).AddYears(245)

    #endregion

    #region methods

    #returns the new crew complement
    [int]AddCrew([int]$Number) {
        $this.Crew+= $Number
        return $this.Crew
    }

    [timespan]GetAge() {
        $timespan = (Get-Date).AddYears(250) - $this.ManufacturingDate
        return $timespan
    }

    [string]GetAge([switch]$AsString) {
        $timespan = (Get-Date).AddYears(250) - $this.ManufacturingDate
        return $timespan.ToString()
    }

    #return True or False if operation was successful
    [Boolean]RaiseShields() {
    if (-Not $this.shields) {
        $this.shields = $True
        #must use Return keyword
        Return $True
    }
    else {
        Write-Warning "Are you paying attention Captain $($this.captain)? The shields are already up."
        Return $False
    }

    } #close RaiseShields method

    [Boolean]LowerShields() {
    if ($this.shields) {
        $this.shields = $False
        Return $True
    }
    else {
        Write-Warning "Are you paying attention Captain $($this.captain)? The shields are already down."
        Return $False
    }

    } #close RaiseShields method

    [void]OpenCommunication () {

        1..7 | foreach {
        $f = Get-Random -Minimum 500 -Maximum 1200
        $d = Get-Random -Minimum 90 -Maximum 125
        [console]::Beep($f,$d)
        }

    } #close OpenCommunication

    #region using overloads

    [void]Fire() {
    if ($this.Torpedos -gt 0 ) {
        Write-Host "Fire!" -ForegroundColor Red -BackgroundColor Yellow
        $this.Torpedos-=1
    }
    else {
        Write-Warning "There's nothing left to fire."
    }

    } #close first Fire method

    [void]Fire([int]$Count) {
        1..$count | foreach  {
        if ($this.Torpedos -ge $_) {
            Write-Host "Fire $_ !" -ForegroundColor Red -BackgroundColor Yellow
            $this.Torpedos-=1
            Start-Sleep -Milliseconds 200
        }
        else {
            Write-Warning "There's nothing left to fire."
            #bail out
            Break
        }
        }
    } #close second Fire method

    #endregion

    #endregion

    #region constructor

    #I have 2 ways of constructing an instance of this class
    MyStarship() {}

    MyStarShip([string]$Name,[ShipClass]$ShipClass) {

        $this.Name = $Name
        $this.ShipClass = $ShipClass
        $this.Speed = "Stopped"

    }
    #endregion

} #close MyStarship

#endregion

Class Cruiser : MyStarship {

    #define different property defaults
    [ShipClass]$ShipClass = [shipclass]::Cruiser
    [int]$Torpedos = 10
    [int]$Crew = 200

    #custom constructor
    Cruiser([string]$Name) {
        $this.name = $Name
    }

}

Class Dreadnought : MyStarShip {

    [ShipClass]$ShipClass = [shipclass]::Dreadnought
    [int]$Torpedos = 20
    [int]$Crew = 900
    [Cloak]$CloakingDevice = [cloak]::Present

    #add a new property
    [ValidateRange(1,100)]
    [int]$FluxCapacitor = 50

    #add a new method
    [boolean]TestFluxCapacitor() {
    if ($this.FluxCapacitor -ge 50) {
        Return $True
    }
    else {
        Return $False
    }
    }


    Dreadnought([string]$Name) {
        $this.name = $Name
    }

}

RETURN

#region fun with the class


#look at constructor
[cruiser]::new

$a = [Cruiser]::new("Barney")
$a
$a | Get-Member

$a.Speed = "impulse"

$b = [dreadnought]::new("Cerebus")
$b | Get-Member
$b
$b.TestFluxCapacitor()

$b.fire(5)
$b | format-table

$c = [MyStarship]::new("Ad Astra","Clipper")
$c.Captain = 'Jason'
$c

$a,$b,$c | format-table -AutoSize

#add some type information
Update-TypeData -TypeName MyStarship -DefaultDisplayPropertySet "Name","ShipClass","Captain","Crew","Speed"
$c
$a
$a,$b,$c

#You could also come up with custom format extensions. Care to try?

#endregion

