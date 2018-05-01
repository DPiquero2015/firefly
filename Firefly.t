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

    // defaults
	defTime = 1300
    
    // ship
    shipTime = 0
    shipDelay = 15
    doShip = rigged &&
        time >= shipTime &&
        time < shipTime + shipDelay
    rigged = nil
    answered = nil
    boardPeaceful = nil

    // reavers
    doReaver = nil
    reaverTime = -1
;

DefineSystemAction(Stats)
	execSystemAction()
	{
		"
		System Time:\t<<stats.defTime + stats.time>>
		\nOxygen Levels:\t<<stats.oxygen>>%
		\nTemperature:\t<<stats.temp>>F
        \nShip:\t<<stats.doShip ? 'Y' : 'N'>>
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

DefineTAction(Answer);

VerbRule(Answer)
    'answer' singleDobj
    : AnswerAction
    verbPhrase = 'answer/answering (what)'
;

me: Actor
	location = roomBridge

	travelTo(dest, connector, backConnector)
	{
        stats.time++;
		stats.oxygen--;
		stats.temp--;
        
        if (stats.doReaver && stats.time > stats.reaverTime)
            finishGameMsg('Reavers boarded the ship.
                There was nothing that could be done.
                Any crew onboard have either been killed or will soon wish they had been. ',
                          [finishOptionQuit, finishOptionRestart]);
        
        if (stats.oxygen <= 0)
            finishGameMsg('The oxygen levels on the ship have depleted.
                Any life onboard has suffocated and died. ',
                          [finishOptionQuit, finishOptionRestart]);
        
        if (stats.temp <= -20)
            finishGameMsg('The ship\' temperature has dropped too low.
                Any life onboard has frozen and died. ',
                          [finishOptionQuit, finishOptionRestart]);

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
	desc = "The ship consoles.
        \bThe navigation controls, system controls, and comms are layed out. "
;

++ bridgeControlsNavigation: Fixture
	vocabWords = 'navigation'
	name = 'Navigation Controls'
	desc = "The navigation controls.
        \bNothing seems to have power. A joystick can still be used though. "
;

+++ bridgeTheStick: Thing
	vocabWords = 'stick/joystick'
	name = 'Joystick'
	desc = "A joystick that looks like it controls some part of the ship. Moving it has no effect. "
;

++ bridgeControlsSystem: Fixture
	vocabWords = 'system'
	name = 'System Controls'
	desc = "The system controls.
        \bThe power, door, and airlock controls are scattered around. "
;

+++ bridgeControlsPower: Switch
	vocabWords = 'power'
	name = 'Power Controls'
	desc = "Switches that seem like they can toggle the lights. "
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
	desc = "Buttons that look like they can lock and unlock the ship's doors. "
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
            makeLocked(true);
            
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
            makeLocked(nil);
            
            stats.locked = nil;
            "The doors are now unlocked. ";
        }
    }
;

+++ bridgeControlsCargoBay: Openable, Fixture
	vocabWords = 'airlock'
	name = 'Airlock Controls'
	desc = "Buttons that seem like they can open and close the cargo bay airlock. "
    initiallyOpen = nil
    dobjFor(Open)
    {
        verify()
        {
            if (isOpen)
                illogicalAlready('The airlock is already open. ');
        }
        action()
        {
            inherited();
            
            stats.airlock = true;
            "The airlock is now open. ";
        }
    }
    dobjFor(Close)
    {
        verify()
        {
            if (!isOpen)
                illogicalAlready('The airlock is already closed. ');
        }
        action()
        {
            inherited();
            
            stats.airlock = nil;
            "The airlock is now closed. ";
        }
    }
;

++ bridgeControlsComms: Fixture
	vocabWords = 'comm*comms'
	name = 'Communication Controls'
    description = 'The communication controls.
        \bCan be rigged to emit a static that may cause passing ships to stop and investigate. '
	desc
    {
        "<<description>>";
    }
    dobjFor(Rig)
    {
        verify()
        {
            if (stats.rigged)
                illogicalAlready('The comms have already been rigged. ');
        }
        action()
        {
            stats.rigged = true;
            "The comms have been rigged. ";
            
            description = 'The communication controls.
                \bThe screen lights up with the face of a ship\'s captain. Their hail may be answered. ';
        }
    }
    dobjFor(Answer)
    {
        verify()
        {
            if (stats.doShip && stats.answered)
                illogicalAlready('The captain\'s hail has already been answered. ');
            if (!stats.doShip)
                illogicalAlready('There is nothing to answer. ');
        }
        action()
        {
            "The ship arrives and a spare part is given by the captain. ";
        }
     }
;

+ bridgeWindows: Fixture
	vocabWords = 'window*windows'
	name = 'windows'
    description = [
        'Stuck here at the corner of no and where... ',
        'Nothing but the black. ',
        'Well... Here I am. '
    ]
    desc
    {
        if (stats.doReaver && stats.time == stats.reaverTime)
                "An old, heavily modified ship is drifting close.
                On it's bloody red exterior are skeletons draped accross the bow.
                What appear to be magnetic grapplers seem to be moving closer to the ship.
                This can only mean reavers. ";
        else
            "<<rand(description)>> ";
    }
    
    dobjFor(LookThrough) remapTo(Examine, bridgeWindows)
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
	"The front hall. To the north is the bridge. To the south is the kitchen. Below are the crew's dorms.
    \bTo the side is a ladder that goes past the roof. "
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

+ hallFrontLadder: Fixture
    vocabWords = 'ladder'
    name = 'ladder'
    desc = "The ladder up to the life support equipment.
        \bControls for the oxygen supply and temperature regulator sit at the top. "
;

++ hallFrontOxygen: Fixture
    vocabWords = 'oxygen'
    name = 'oxygen'
    desc = "Oxygen controls for the ship. "
;

++ hallFrontTemperature: Fixture
    vocabWords = 'temperature regulator'
    name = 'temperature'
    desc = "Temperature controls for the ship. "
;

/*-----------END FRONT HALL-----------*/

/*----------BEGIN KITCHEN----------*/

roomKitchen: Room 'The Kitchen'
	"The kitchen. To the north is the front hall. To the south is the back hall.
    \bCabinets and cupboards dot the walls while a large wooden table rests in the center. "
	north = roomHallFront
	south = roomHallBack
;

+ kitchenCabinets: Fixture
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

+ kitchenTable: Fixture
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
	"The back hall. To the north is the kitchen. To the south is the engine room.
    \bTo the side is a ladder. "
	north = roomKitchen
	south = roomEngine
;

+ hallBackLadder: Fixture
    vocabWords = 'ladder'
    name = 'ladder'
    desc = "The ladder up to auxiliary system access. "
;

++ hallBackAirlock: Fixture
    vocabWords = 'airlock'
    name = 'airlock'
    desc = "An auxiliary airlock. "
;

++ hallBackGravity: Fixture
    vocabWords = 'gravity'
    name = 'gravity'
    desc = "The gravity rotor. "
;

/*-----------END BACK HALL-----------*/

/*----------BEGIN ENGINE----------*/

roomEngine: Room 'The Engine Room'
	"The engine room. To the north is the back hall.
    \bIn the middle sits the engine, and scattered around are various equipment bins. "
	north = roomHallBack
;

+ engineEngine: Fixture
    vocabWords = 'engine'
    name = 'engine'
    desc = "The ship's engine. "
;

+ engineBins: Fixture
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
	"The crew's dorms. To the south is the catwalk. Above is the front hall.
    \bAt the front is a ladder. "
	south = roomCatwalk
	up = roomHallFront
;

+ dormCrewLadder: Fixture
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
	"The air lock before the cargo bay. To the south is the cargo bay.
    \bThere is a switch on the wall. "
	south = roomCargoBay
;

+ airLockSwitch: Fixture
    vocabWords = 'door switch'
    name = 'switch'
    desc = "The switch controlling the airlock door. "
;

/*-----------END AIR LOCK-----------*/

/*----------BEGIN CARGO----------*/

roomCargoBay: Room 'The Cargo Bay'
	"The cargo bay. To the north is the air lock. To the south is the infirmary. Above is the catwalk.
    \bTaking up most of the space are large cargo boxes, in the corner space suits can be seen. "
	north = roomAirLock
	south = roomInfirmary
	up = roomCatwalk
;

+ cargoBayBoxes: Fixture
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
	"The infirmary. To the north is the cargo bay. To the south are the passengers' dorms.
    \bCabinets line the walls while small side tables sit unused. "
	north = roomCargoBay
	south = roomDormsPassengers
;

+ infirmaryCabinets: Fixture
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

+ infirmaryTables: Fixture
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
	"The passenger's dorms. To the north is the infirmary.
    \bDressers along the wall hold passengers' belongings. "
	north = roomInfirmary
;

+ dormPassengerDressers: Fixture
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
