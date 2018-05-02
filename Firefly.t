#charset "us-ascii"

#include <adv3.h>
#include <en_us.h>

gameMain: GameMainDef
    initialPlayerChar = me

    showIntro()
    {
        "You are the captain of a Firefly class ship fitted for hauling cargo. You are
         passing through a rather desolate region of the 'verse when the lights suddenly
         flicker and warning lights begin flashing on your console. The engine has given
         out. Not only is the ship helplessly stranded in space, but the life support
         systems are now inoperable. You must act quickly before you run out of both oxygen
         and heat... 
         \bTo get info about the ship, type \'stats\'.\b ";
    }
;

gameInit: InitObject
    execute()
    {
        // Chance for reavers to spawn
        stats.doReaver = rand(10) == 0;
        // Time for reavers to arrive
        stats.reaverTime = stats.doReaver ? rand(30) : -1;
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

/*----------BEGIN STATS----------*/

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
    shipTime = 20
    shipDelay = 15
    doShip = rigged &&
           time >= shipTime &&
           time < shipTime + shipDelay
    rigged = nil
    answered = nil
    boarding = nil
    gunpoint = nil

    // reavers
    doReaver = nil
    reaverTime = -1
;

sit(min)
{
    stats.time += min;
    stats.oxygen -= min;
    stats.temp -= min;

    if (stats.oxygen <= 0)
       dieOxygen();

    if (stats.temp <= -20)
       dieTemperature();

    "You wait for <<min>> minute<<min > 1 ? 's' : ''>>. ";
}

dieOxygen()
{
    finishGameMsg('The oxygen levels on the ship have depleted.
                   You suffocate and die. ',
                   [finishOptionQuit, finishOptionRestart]);
}

dieTemperature()
{
    finishGameMsg('The ship\' temperature has dropped too low.
                   You freeze and die. ',
                   [finishOptionQuit, finishOptionRestart]);
}

DefineSystemAction(Stats)
    execSystemAction()
    {
        "
        System Time:\t<<stats.defTime + stats.time>>
        \nOxygen Levels:\t<<stats.oxygen>>%
        \nTemperature:\t<<stats.temp>>F
        ";
    }
;

VerbRule(Stats)
    'stats'
    : StatsAction
    verbPhrase = 'check/checking the system statistics'
;

/*-----------END STATS-----------*/

/*----------BEGIN VERB DEFINITIONS----------*/

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

DefineLiteralAction(WaitFor)
    execAction()
    {
        if (rexMatch('[0-9]+', getLiteral()))
            sit(toInteger(getLiteral()));
    }
;
VerbRule(WaitFor)
    'wait' singleLiteral ( | 'minute' | 'minutes' )
    : WaitForAction
    verbPhrase = 'wait/waiting for (what) minutes'
;

/*-----------END VERB DEFINITIONS----------*/

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
                           You either die or will soon wish you did. ',
                           [finishOptionQuit, finishOptionRestart]);

        if (stats.oxygen <= 0)
            dieOxygen();

        if (stats.temp <= -20)
            dieTemperature();

        inherited(dest, connector, backConnector);
    }

    lookAround(verbose)
    {
        if (!stats.lights)
            "It's hard to tell where anything is without the lights on. ";
        else
            inherited(verbose);
    }
;

/*----------BEGIN BRIDGE----------*/

roomBridge: Room 'The Bridge'
    "The bridge of the ship. To the south is the front hall.
     \bInside there are consoles, windows looking out, and, to the side, a ladder. "
    south = roomHallFront
;

+ bridgeConsoles: Fixture
    vocabWords = 'console*consoles'
    name = 'bridge consoles'
    desc = "The ship consoles.
    \bThe navigation controls, system controls, and comms are layed out. "
;

++ bridgeControlsNavigation: Fixture
    vocabWords = 'navigation controls'
    name = 'navigation controls'
    desc = "The navigation controls.
    \bNothing seems to have power. A joystick can still be used though. "
;

+++ bridgeTheStick: Fixture
    vocabWords = 'stick/joystick'
    name = 'joystick'
    desc = "A joystick that looks like it controls some part of the ship. Moving it has no effect. "
;

++ bridgeControlsSystem: Fixture
    vocabWords = 'system controls'
    name = 'system controls'
    desc = "The system controls.
            \bThe door and airlock controls are scattered around next to the light switch. "
;

+++ bridgeControlsPower: Switch
    vocabWords = 'light switch/lights'
    name = 'lights'
    desc = "The master switch for the ship\'s interior lighting. "
    isOn = true
    isPlural = true
    makeOn(val)
    {
        inherited(val);
        stats.lights = val;
    }
;

+++ bridgeControlsDoors: Lockable, Fixture
    vocabWords = 'door*doors'
    name = 'door controls'
    desc = "Buttons that look like they can lock and unlock the ship's doors. "
    initiallyLocked = nil
    makeLocked(val)
    {
        inherited(val);
        stats.locked = val;
    }
;

+++ bridgeControlsCargoBay: Openable, Fixture
    vocabWords = 'airlock'
    name = 'airlock controls'
    desc = "Buttons that seem like they can open and close the cargo bay airlock. "
    initiallyOpen = nil
    makeOpen(val)
    {
        inherited(val);
        stats.airlock = val;
    }
;

++ bridgeControlsComms: Fixture
    vocabWords = 'comm*comms'
    name = 'communication controls'
    description = 'Can be rigged to emit a static that may cause passing ships to stop and investigate. '
    desc
    {
        "The communication controls.
        \b<<stats.doShip ? 'The screen lights up with the face of a ship\'s captain. Their hail may be answered. ' : description>>";
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
            description = 'The comms screen is blank. ';
            "The comms have been rigged. ";
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
            stats.answered = true;
            stats.boarding = true;
            "The ship arrives and docks at the airlock. ";
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

/*-----------END BRIDGE-----------*/

/*----------BEGIN FRONT HALL----------*/

roomHallFront: Room 'The Front Hall'
    "The front hall. To the north is the bridge. To the south is the kitchen. Below are the crew's dorms.
     \bTo the side is a ladder that goes past the roof. "
    north = roomBridge
    south = roomKitchen
    down = roomDormsCrew
    dobjFor(TravelVia)
    {
        verify()
        {
            if (stats.locked)
                illogicalNow('The door is locked. ');
        }
        action()
        {
            inherited();
        }
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
                    You survive. ',
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
                illogicalAlready('The manual has already been read, there\'s not much more to get out of it. ');
        }
        action()
        {
            stats.manual = true;
            "Reading the manual gives you insight into the construction of the engine. ";
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
    dobjFor(TravelVia)
    {
        action()
        {
            if (stats.airlock && !stats.boarding)
                finishGameMsg('Sucked out into space, you <<cargoBaySuit.isWornBy(me)
                      ? 'drift until your space suit runs out of oxygen. '
                      : 'quickly fall unconscious from the lack of oxygen and die from pressure reduction out in the cold depths of nothing. '>>',
                              [finishOptionQuit, finishOptionRestart]);

            inherited();
        }
    }
;

/*----------END CATWALK-----------*/

/*----------BEGIN CARGO----------*/

roomCargoBay: Room 'The Cargo Bay'
    "The cargo bay. The airlock door towers above you. To the south is the infirmary. Above is the catwalk.
    \bTaking up most of the space are large cargo boxes, on the wall is a switch, and in the corner space suits can be seen."
    south = roomInfirmary
    up = roomCatwalk
    dobjFor(TravelVia)
    {
        action()
        {
            if (stats.airlock && !stats.boarding)
                finishGameMsg('Sucked out into space, you <<cargoBaySuit.isWornBy(me)
                      ? 'drift until your space suit runs out of oxygen. '
                      : 'quickly fall unconscious from the lack of oxygen and die from pressure reduction out in the cold depths of nothing. '>>',
                              [finishOptionQuit, finishOptionRestart]);

            inherited();
        }
    }
    roomAfterAction()
    {
        if (stats.boarding)
        {
            if (stats.gunpoint)
            {
                local region = rand('head', 'chest', 'stomach', 'legs');
                "The captain of the ship shoots you in the <<region>>. ";

                if (region == 'head' || region == 'chest')
                    finishGameMsg('After being shot in the <<region>>, you die. ',
                              [finishOptionQuit, finishOptionRestart]);
                if (cargoBayWeapons.isHeldBy(me) || dormCrewWeapons.isHeldBy(me))
                {
                    "With a gun hidden in your coat you catch the captain by surprise.
                    Reluctantly he hands over the catalyzer and orders his crew to put down their guns and leave. ";
                    cargoAirLockSwitch.makeOpen(nil);
                    stats.catalyzer = true;
                    stats.boarding = nil;
                }
                else
                    finishGameMsg('With nothing to defend yourself with, the captain shoots you again. This time, he doesn\'t miss. You die. ',
                                  [finishOptionQuit, finishOptionRestart]);
            }
            else
            {
                if (stats.airlock)
                {
                    "The captain of the ship and some members of his crew stand at the edge of the airlock,
                    guns drawn and pointed at you. ";
                    stats.gunpoint = true;
                }
                else
                    "The captain of the ship can be seen outside the airlock. ";
            }
        }
    }
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
    isListed = nil
;

+ cargoAirLockSwitch: Openable, Fixture
    vocabWords = 'airlock switch'
    name = 'airlock switch'
    desc = "The switch for opening and closing the airlock door. "
    initiallyOpen = nil
    makeOpen(val)
    {
        finishGameMsg('Sucked out into space, you <<cargoBaySuit.isWornBy(me)
                      ? 'drift until your space suit runs out of oxygen. '
                      : 'quickly fall unconscious from the lack of oxygen and die from pressure reduction out in the cold depths of nothing. '>>',
                              [finishOptionQuit, finishOptionRestart]);
        //inherited(val);
        //stats.airlock = val;
    }
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
