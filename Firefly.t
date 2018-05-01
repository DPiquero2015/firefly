#include <adv3.h>
#include <en_us.h>

gameMain: GameMainDef
	initialPlayerChar = me
;

gameInit: InitObject
    execute()
    {
        stats.doReaver = rand(2) == 0;
        stats.reaverTime = stats.doReaver ? rand(5) : -1;
    }
;

versionInfo: GameID
	name = 'Firefly'
	byline = 'by Dmitri Piquero and Ryan Wojtyla'
	desc = 'Television and Pop Culture Spring 2018 Final Project'
	version = '1'
	IFID = '1CB06A44-AA04-48CE-9892-BA2ABFECC120'
;

modify Thing
    contentsListedInExamine = nil
;

stats: Thing
    // vitals
    time = 0
	oxygen = 100
	temp = 75

    // game values
    lights = true
    locked = nil
    airlock = nil
    rigged = nil

    // defaults
	defTime = 1300

    // reavers
    doReaver = nil
    reaverTime = -1
;

DefineSystemAction(Stats)
	execSystemAction()
	{
		local t = stats.defTime + stats.time;
		local o = stats.oxygen;
		local m = stats.temp;
        local r = stats.doReaver ? 'Yes' : 'No';
        local b = stats.reaverTime;

		"
		System Time:\t<<t>>
		\nOxygen Levels:\t<<o>>%
		\nTemperature:\t<<m>>F
        \nReaver:\t\t<<r>>
        \nReaver Time:\t<<b>>
		";
	}
;

VerbRule(Stats)
	'stats' | 'status'
	: StatsAction
	verbPhrase = 'check/checking the system statistics'
;

DefineTAction(Rig);

VerbRule(Rig)
    'rig' singleDobj
    : RigAction
    verbPhrase = 'rig/rigging (what)'
;

me: Actor
	location = roomBridge

	travelTo(dest, connector, backConnector)
	{
        stats.time++;
		stats.oxygen--;
		stats.temp--;
        
        if (stats.doReaver && stats.time > stats.reaverTime)
            finishGameMsg('Reavers boarded the ship. There was nothing that could be done. Any crew onboard have either been killed or will soon wish they had been. ', [finishOptionQuit, finishOptionRestart]);
        
        if (stats.oxygen <= 0)
            finishGameMsg('The oxygen levels on the ship have depleted. Any life onboard has suffocated and died. ', [finishOptionQuit, finishOptionRestart]);
        
        if (stats.temp <= -20)
            finishGameMsg('The ship\' temperature has dropped too low. Any life onboard has frozen and died. ', [finishOptionQuit, finishOptionRestart]);

		inherited(dest, connector, backConnector);
	}
;

/*----------BEGIN BRIDGE----------*/

roomBridge: Room 'The Bridge'
	"The bridge of the ship. To the south is the front hall.
    \bInside there are consoles, windows looking out, and to the side a ladder. "
	south = roomHallFront
;

+ bridgeConsoles: Fixture
    vocabWords = 'console*consoles'
	name = 'Bridge Consoles'
	desc = "See the navigation controls, system controls, and comms. "
;

++ bridgeControlsNavigation: Fixture
	vocabWords = 'navigation'
	name = 'Navigation Controls'
	desc = "See the navigation controls and joystick. Everything has been powered down. "
;

+++ bridgeTheStick: Thing
	vocabWords = 'stick/joystick'
	name = 'Joystick'
	desc = "A joystick that looks like it controls some part of the ship. Moving it has no effect. "
;

++ bridgeControlsSystem: Fixture
	vocabWords = 'system'
	name = 'System Controls'
	desc = "See the power controls, door controls, and airlock controls. "
;

+++ bridgeControlsPower: Switch
	vocabWords = 'power'
	name = 'Power Controls'
	desc = "Can toggle the lights. "
    isOn = true
    makeOn(val)
    {
        inherited(val);
        stats.lights = val;
    }
;

+++ bridgeControlsDoors: Lockable, Fixture
	vocabWords = 'door*doors'
	name = 'Coor Controls'
	desc = "Can lock and unlock the ship's doors. "
    initiallyLocked = nil
    dobjFor(Lock)
    {
        verify()
        {
            if (isLocked)
                illogicalAlready('The doors are already locked. ');
        }
        action()
        {
            makeLoked(true);
            
            stats.locked = true;
            
            "The doors are now locked. ";
        }
    }
    dobjFor(Unlock)
    {
        verify()
        {
            if (!isLocked)
                illogicalAlready('The doors are already unlocked. ');
        }
        action()
        {
            makeLoked(nil);
            
            stats.locked = nil;
            
            "The doors are now unlocked. ";
        }
    }
;

+++ bridgeControlsCargoBay: Openable, Fixture
	vocabWords = 'airlock'
	name = 'Airlock Controls'
	desc = "Can open and close the cargo bay airlock. "
    initiallyOpen = nil
    dobjFor(Open)
    {
        verify()
        {
            if (isOpen)
                illogicalAlready('The cargo bay airlock is already open. ');
        }
        action()
        {
            inherited();
            
            stats.airlock = true;
            
            "The cargo bay airlock is now open. ";
        }
    }
    dobjFor(Close)
    {
        verify()
        {
            if (!isOpen)
                illogicalAlready('The cargo bay airlock is already closed. ');
        }
        action()
        {
            inherited();
            
            stats.airlock = nil;
            
            "The cargo bay airlock is now closed. ";
        }
    }
;

++ bridgeControlsComms: Fixture
	vocabWords = 'comm*comms'
	name = 'Communication Controls'
	desc = "Can be rigged to emit a static that may cause passing ships to stop and investigate. "
    dobjFor(Rig)
    {
        action()
        {
            stats.rigged = true;
            "The comms have been rigged. ";
        }
    }
;

+ bridgeWindows: Fixture
	vocabWords = 'window*windows'
	name = 'windows'
    descriptions = [
        'Space, at the corner of no and where... ',
        'Nothing but the black. '
    ]
    dobjFor(LookIn) remapTo(LookThrough, bridgeWindows)
    dobjFor(Examine) remapTo(LookThrough, bridgeWindows)
	dobjFor(LookThrough)
    {
        action()
        {
            if (stats.doReaver && stats.time == stats.reaverTime)
                "An old, heavily modified ship is drifting close.
                On it's bloody red exterior are skeletons draped accross the bow.
                What appear to be magnetic grapplers seem to be moving closer to the ship.
                This can only mean reavers. ";
            else
            {
                local r = rand(descriptions);
                "<<r>> ";
            }
        }
    }
;

+ bridgeLadder: Fixture
	vocabWords = 'ladder'
	name = 'ladder'
	desc = "A ladder leading down to an airlock. It appears to be sealed shut. "
;
;

/*-----------END BRIDGE-----------*/

/*----------BEGIN FRONT HALL----------*/

roomHallFront: Room 'The Front Hall'
	"The front hall. To the north is the bridge. To the south is the kitchen. Below are the crew's dorms. "
	north = roomBridge
	south = roomKitchen
	down = roomDormsCrew
    canTravelerPass(traveler)
    {
        return inherited(traveler) && !stats.locked;
    }
    explainTravelBarrier(traveler)
    {
        if (stats.locked)
            "The door is locked. ";
        else
            inherited(traveler);
    }
;

+ hallFrontLadder: Thing
    vocabWords = 'ladder'
    name = 'ladder'
    desc = "The ladder up to the life support equipment. "
;

++ hallFrontOxygen: Thing
    vocabWords = 'oxygen'
    name = 'oxygen'
    desc = "Oxygen controls for the ship. "
;

++ hallFrontTemperature: Thing
    vocabWords = 'temperature'
    name = 'temperature'
    desc = "Temperature controls for the ship. "
;

/*-----------END FRONT HALL-----------*/

/*----------BEGIN KITCHEN----------*/

roomKitchen: Room 'The Kitchen'
	"The kitchen. To the north is the front hall. To the south is the back hall. "
	north = roomHallFront
	south = roomHallBack
;

+ kitchenCabinets: Thing
    vocabWords = 'cabinets/cupboards'
    name = 'cabinets and cupboards'
    desc = "The cabinets and cupboards of the kitchen. "
;

++ kitchenCabinetFood: Thing
    vocabWords = 'food'
    name = 'food'
    desc = "Food in the cupboards. "
;

++ kitchenCabinetCutlery: Thing
    vocabWords = 'cutlery'
    name = 'cutlery'
    desc = "Cutlery in the cabinets. "
;

+ kitchenTable: Thing
    vocabWords = 'table'
    name = 'table'
    desc = "The wooden dining table in the kitchen. "
;

++ kitchenTableCutlery: Thing
    vocabWords = 'cutlery'
    name = 'cutlery'
    desc = "Cutlery on the table. "
;

/*-----------END KITCHEN-----------*/

/*----------BEGIN BACK HALL----------*/

roomHallBack: Room 'The Back Hall'
	"The back hall. To the north is the kitchen. To the south is the engine room. "
	north = roomKitchen
	south = roomEngine
;

+ hallBackLadder: Thing
    vocabWords = 'ladder'
    name = 'ladder'
    desc = "The ladder up to auxiliary system access. "
;

++ hallBackAirlock: Thing
    vocabWords = 'airlock'
    name = 'airlock'
    desc = "An auxiliary airlock. "
;

++ hallBackGravity: Thing
    vocabWords = 'gravity'
    name = 'gravity'
    desc = "The gravity rotor. "
;

/*-----------END BACK HALL-----------*/

/*----------BEGIN ENGINE----------*/

roomEngine: Room 'The Engine Room'
	"The engine room. To the north is the back hall. "
	north = roomHallBack
;

+ engineEngine: Thing
    vocabWords = 'engine'
    name = 'engine'
    desc = "The ship's engine. "
;

+ engineBins: Thing
    vocabWords = 'equipment bins'
    name = 'bins'
    desc = "Bins containing miscellaneous engine equipment. "
;

++ engineBinTools: Thing
    vocabWords = 'tools'
    name = 'tools'
    desc = "Mechanic's tools. "
;

++ engineBinParts: Thing
    vocabWords = 'parts'
    name = 'parts'
    desc = "Miscellaneous engine parts. "
;

++ engineBinManual: Thing
    vocabWords = 'manual'
    name = 'manual'
    desc = "Ship engine manual. "
;

/*-----------END ENGINE-----------*/

/*----------BEIGN CREW DORM----------*/

roomDormsCrew: Room 'Crew Dorms'
	"The crew's dorms. To the south is the catwalk. Above is the front hall. "
	south = roomCatwalk
	up = roomHallFront
;

+ dormCrewLadder: Thing
    vocabWords = 'ladder'
    name = 'ladder'
    desc = "Ladder leading up to the Front Hall. "
;

+ dormCrewWeapons: Thing
    vocabWords = 'weapons/guns'
    name = 'weapons'
    desc = "The personal weapons of the crew, mostly firearms. "
;

+ dormCrewFood: Thing
    vocabWords = 'food/water'
    name = 'food'
    desc = "The crew's rations. "
;

+ dormCrewClothing: Thing
    vocabWords = 'clothing/clothes'
    name = 'clothing'
    desc = "The crew's wardrob. "
;

/*-----------END CREW DORM-----------*/

/*----------BEGIN CATWALK----------*/

roomCatwalk: Room 'The Catwalk'
	"The catwalk above the cargo bay. To the north are the crew's dorms. Beneath is the cargo bay. "
	north = roomDormsCrew
	down = roomCargoBay
;

/*----------END CATWALK-----------*/

/*----------BEGIN AIR LOCK-----------*/

roomAirLock: Room 'The Air Lock'
	"The air lock before the cargo bay. To the south is the cargo bay. "
	south = roomCargoBay
;

+ airLockSwitch: Thing
    vocabWords = 'door switch'
    name = 'switch'
    desc = "The switch controlling the airlock door. "
;

/*-----------END AIR LOCK-----------*/

/*----------BEGIN CARGO----------*/

roomCargoBay: Room 'The Cargo Bay'
	"The cargo bay. To the north is the air lock. To the south is the infirmary. Above is the catwalk. "
	north = roomAirLock
	south = roomInfirmary
	up = roomCatwalk
;

+ cargoBayBoxes: Thing
    vocabWords = 'cargo boxes'
    name = 'boxes'
    desc = "Boxes containing various types of cargo. "
;

++ cargoBayWeapons: Thing
    vocabWords = 'weapons/guns'
    name = 'weapons'
    desc = "Weapons stored inside the cargo boxes. "
;

++ cargoBayParts: Thing
    vocabWords = 'parts'
    name = 'parts'
    desc = "Various parts stored inside the cargo boxes. "
;

+ cargoBaySuit: Thing
    vocabWords = 'space suit'
    name = 'suit'
    desc = "Space suits for venturing out into the black. "
;

/*-----------END CARGO-----------*/

/*---------BEGIN INFIRMARY----------*/

roomInfirmary: Room 'The Infirmary'
	"The infirmary. To the north is the cargo bay. To the south are the passengers' dorms. "
	north = roomCargoBay
	south = roomDormsPassengers
;

+ infirmaryCabinets: Thing
    vocabWords = 'cabinents'
    name = 'cabinets'
    desc = "Cabinets containing various medical supplies. "
;

++ infirmaryBiofoam: Thing
    vocabWords = 'biofoam'
    name = 'biofoam'
    desc = "Fast-acting wound sealant. "
;

++ infirmaryBandages: Thing
    vocabWords = 'bandages'
    name = 'bandages'
    desc = "Slow-acting wound sealant. "
;

++ infirmaryPainkillers: Thing
    vocabWords = 'painkillers'
    name = 'painkillers'
    desc = "Mitigate the strain of sustaining injury. "
;

++ infirmaryAdrenaline: Thing
    vocabWords = 'adrenaline'
    name = 'adrenaline'
    desc = "Provides a very temporary surge of incredible energy. "
;

+ infirmaryTables: Thing
    vocabWords = 'side tables'
    name = 'tables'
    desc = "Tables containing various medical supplies. "
;

++ infirmaryDope: Thing
    vocabWords = 'dope'
    name = 'dope'
    desc = "Powerful sedative. "
;

++ infirmarySyringes: Thing
    vocabWords = 'syringes'
    name = 'syringes'
    desc = "Can be used to administer drugs or extract liquids. "
;

++ infirmaryTools: Thing
    vocabWords = 'surgical tools'
    name = 'tools'
    desc = "Various medical supplies, many of them sharp. "
;

/*-----------END INFIRMARY-----------*/

/*----------BEGIN PASSANGER DORM----------*/

roomDormsPassengers: Room 'Passenger Dorms'
	"The passenger's dorms. To the north is the infirmary. "
	north = roomInfirmary
;

+ dormPassengerDressers: Thing
    vocabWords = 'dresser/drawer'
    name = 'dresser'
    desc = "Storage for the passengers. "
;

++ dormPassengerFood: Thing
    vocabWords = 'food'
    name = 'food'
    desc = "Passenger rations. "
;

++ dormPassengerClothes: Thing
    vocabWords = 'clothes/clothing'
    name = 'clothes'
    desc = "Passenger wardrobe. "
;

/*-----------END PASSANGER DORM-----------*/
