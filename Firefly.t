#include <adv3.h>
#include <en_us.h>

gameMain: GameMainDef
	initialPlayerChar = me
;

gameInit: InitObject
    execute()
    {
        stats.doReaver = rand(10) == 0;
        stats.reaverTime = stats.doReaver ? rand(60) : -1;
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
    manual = nil
    knowledge = nil
    catalyzer = nil

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
        \nAirlock:\t<<stats.airlock ? 'Y' : 'N'>>
		";
	}
;

VerbRule(Stats)
	('stats' | 'status')
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

DefineTAction(Diagnose);

VerbRule(Diagnose)
    'diagnose' singleDobj
    : DiagnoseAction
    verbPhrase = 'diagnose/diagnosing (what)'
;

DefineTAction(Repair);

VerbRule(Repair)
    ('repair' | 'fix') singleDobj
    : RepairAction
    verbPhrase = 'repair/repairing (what)'
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

+++ bridgeTheStick: Fixture
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
    description = 'Can be rigged to emit a static that may cause passing ships to stop and investigate. '
	desc
    {
        "The communication controls.
        \b<<description>>";
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
            
            description = 'The screen lights up with the face of a ship\'s captain. Their hail may be answered. ';
        }
    }
    dobjFor(Answer)
    {
        verify()
        {
            if (stats.doShip && stats.answered)
                illogicalAlready('The captain\'s hail has already been answered. ');
            if (!stats.doShip)
                illogicalNow('There is nothing to answer. ');
        }
        action()
        {
            "The ship arrives and a spare part is given by the captain. ";
            stats.boardPeaceful = true;
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
    isPlural = true
;

++ kitchenCabinetCutlery: Thing
    vocabWords = 'cutlery'
    name = 'cutlery'
    desc = "Cutlery in the cabinets. "
    isPlural = true
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
    isPlural = true
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
    description = 'It is currently broken down, and whatever problems it has need to be diagnosed. '
	desc
    {
        "The ship's engine.
        \b<<description>>";
    }
    dobjFor(Diagnose) remapTo(Examine, engineEngine)
    dobjFor(Examine)
    {
        verify()
        {
            if (stats.knowledge)
                illogicalAlready('The engine has already been examined, a new catalyzer is needed. ');
        }
        action()
        {
            if (stats.manual || (!stats.manual && rand(4) == 0))
            {
                stats.knowledge = true;
                description = 'It is currently broken down, but can be fixed with a new catalyzer. ';
                "It appears that the catalyzer on the port compression coil blew. That's where the trouble started. ";
            }
            else
                "The engine is broken, and it is not obvious why. ";
        }
    }
    dobjFor(Repair)
    {
        verify()
        {
            if (!stats.catalyzer)
                illogicalNow('The engine can\'t be repaired without the right parts. ');
        }
        action()
        {
            if (stats.catalyzer)
            {
                finishGameMsg('Plugging in the catalyer, the engine begins to turn.
                    Power is restored and air begins to circulate throughout the ship.
                    The crew survived. ',
                              [finishOptionQuit, finishOptionRestart]);
            }
        }
    }
;

+ engineBins: Fixture
    vocabWords = 'equipment bins'
    name = 'equiment bins'
    desc = "Bins containing miscellaneous engine equipment.
        \bTools, parts, and a manual can be found in the various bins. "
;

++ engineBinTools: Thing
    vocabWords = 'tools'
    name = 'tools'
    desc = "Mechanic's tools. "
    isPlural = true
;

++ engineBinParts: Thing
    vocabWords = 'parts'
    name = 'parts'
    desc = "Miscellaneous engine parts. "
    isPlural = true
;

++ engineBinManual: Readable
    vocabWords = 'manual'
    name = 'manual'
    desc = "Ship engine manual. "
    dobjFor(Read)
    {
        verify()
        {
            if (stats.manual)
                illogicalAlready('The manual has already been read, there\'s not much more that can be got out of it. ');
        }
        action()
        {
            stats.manual = true;
            "Reading the manual gives insight into the construction of the engine. ";
        }
    }
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
    isPlural = true
;

+ dormCrewFood: Thing
    vocabWords = 'food/water'
    name = 'food'
    desc = "The crew's rations. "
    isPlural = true
;

+ dormCrewClothing: Thing
    vocabWords = 'clothing/clothes'
    name = 'clothing'
    desc = "The crew's wardrobe. "
    isPlural = true
;

/*-----------END CREW DORM-----------*/

/*----------BEGIN CATWALK----------*/

roomCatwalk: Room 'The Catwalk'
	"The catwalk above the cargo bay. To the north are the crew's dorms. Beneath is the cargo bay. "
	north = roomDormsCrew
	down = roomCargoBay
    dobjFor(Enter)
    {
        action()
        {
            inherited();
            
            if (stats.airlock)
                finishGameMsg('Sucked out into space, the captain of the ship <<cargoBaySuit.isWornBy(me)
                      ? 'Drifted in space until their space suit ran out of Oxygen. '
                      : 'Quickly suffocated and died from the lack of pressure and Oxygen in the cold depths of nothing. '>>',
                              [finishOptionQuit, finishOptionRestart]);
        }
    }
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
    name = 'cargo boxes'
    desc = "Boxes containing various types of cargo. "
;

++ cargoBayWeapons: Thing
    vocabWords = 'weapons/guns'
    name = 'weapons'
    desc = "Weapons stored inside the cargo boxes. "
    isPlural = true
;

++ cargoBayParts: Thing
    vocabWords = 'parts'
    name = 'parts'
    desc = "Various parts stored inside the cargo boxes. "
    isPlural = true
;

+ cargoBaySuit: Wearable
    vocabWords = 'space suit'
    name = 'space suit'
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
    isPlural = true
;

++ infirmaryBandages: Thing
    vocabWords = 'bandages'
    name = 'bandages'
    desc = "Slow-acting wound sealant. "
    isPlural = true
;

++ infirmaryPainkillers: Thing
    vocabWords = 'painkillers'
    name = 'painkillers'
    desc = "Mitigate the strain of sustaining injury. "
    isPlural = true
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
    isPlural = true
;

++ infirmaryTools: Thing
    vocabWords = 'surgical tools'
    name = 'tools'
    desc = "Various medical supplies, many of them sharp. "
    isPlural = true
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
    isPlural = true
;

++ dormPassengerClothes: Thing
    vocabWords = 'clothes/clothing'
    name = 'clothes'
    desc = "Passenger wardrobe. "
    isPlural = true
;

/*-----------END PASSANGER DORM-----------*/
