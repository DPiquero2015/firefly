#include <adv3.h>
#include <en_us.h>

gameMain: GameMainDef
	initialPlayerChar = me
;

versionInfo: GameID
	name = 'Firefly'
	byline = 'by Dmitri Piquero and Ryan Wojtyla'
	desc = 'Television and Pop Culture Spring 2018 Final Project'
	version = '1'
	IFID = '1CB06A44-AA04-48CE-9892-BA2ABFECC120'
;

stats: Thing
	time = 0
	oxygen = 100
	temp = 75

	defTime = 1300
;

DefineSystemAction(Stats)
	execSystemAction()
	{
		local t = stats.defTime + stats.time;
		local o = stats.oxygen;
		local m = stats.temp;

		"
		System Time:\t<<t>>
		\nOxygen Levels:\t<<o>>%
		\nTemperature:\t<<m>>F
		";
	}
;

VerbRule(Stats)
	'stats'
	: StatsAction
	verbPhrase = 'check/checking the system statistics'
;

me: Actor
	location = roomBridge

	travelTo(dest, connector, backConnector)
	{
		stats.time++;
		stats.oxygen--;
		stats.temp--;
		inherited(dest, connector, backConnector);
	}
;

/*----------BEGIN BRIDGE----------*/

roomBridge: Room 'The Bridge'
	"The bridge of the ship. To the south is the front hall. Inside there are consoles, windows looking out, and to the side a ladder. "
	south = roomHallFront
;

+ bridgeConsoles: Thing
        vocabWords = 'consoles'
	name = 'the consoles'
	desc = "See the navigation controls, system controls, and comms. "
;

++ bridgeControlsNavigation: Thing
	vocabWords = 'navigation'
	name = 'navigation controls'
	desc = "See the navigation controls and joystick. Everything has been powered down. "
;

+++ bridgeTheStick: Thing
	vocabWords = 'stick/joystick'
	name = 'the joystick'
	desc = "Moving the stick has no effect. "
;

++ bridgeControlsSystem: Thing
	vocabWords = 'system'
	name = 'system controls'
	desc = "See the power diversion controls, door controls, and airlock controls. "
;

+++ bridgeControlsPower: Thing
	vocabWords = 'power'
	name = 'power diversion controls'
	desc = "Can toggle the lights, and re-route remaining power to different sectors of the ship. "
;

+++ bridgeControlsDoors: Thing
	vocabWords = 'doors'
	name = 'door controls'
	desc = "Can open, close, and lock the various doors of the ship. "
;

+++ bridgeControlsAirlock: Thing
	vocabWords = 'airlock'
	name = 'airlock controls'
	desc = "Can open and close the various airlocks on the ship. "
;

++ bridgeControlsComms: Thing
	vocabWords = 'comms'
	name = 'communication controls'
	desc = "Can be rigged to emit a static that may cause passing ships to stop and investigate. "
;

+ bridgeWindows: Thing
	vocabWords = 'windows'
	name = 'windows'
	desc = "See space, at the corner of no and where..."
;

+ bridgeLadder: Thing
	vocabWords = 'ladder'
	name = 'ladder'
	desc = "A ladder leading down to an airlock. "
;

++ bridgeAirlock: Thing
	vocabWords = 'airlock'
	name = 'airlock'
	desc = "An airlock. It seems to be sealed shut. "
;

/*-----------END BRIDGE-----------*/

/*----------BEGIN FRONT HALL----------*/

roomHallFront: Room 'The Front Hall'
	"The front hall. To the north is the bridge. To the south is the kitchen. Below are the crew's dorms. "
	north = roomBridge
	south = roomKitchen
	down = roomDormsCrew
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
