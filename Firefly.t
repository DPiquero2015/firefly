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
;

me: Actor
	location = roomBridge
;

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

roomHallFront: Room 'The Front Hall'
	"The front hall. To the north is the bridge. To the south is the kitchen. Below are the crew's dorms. "
	north = roomBridge
	south = roomKitchen
	down = roomDormsCrew
;

roomKitchen: Room 'The Kitchen'
	"The kitchen. To the north is the front hall. To the south is the back hall. "
	north = roomHallFront
	south = roomHallBack
;

roomHallBack: Room 'The Back Hall'
	"The back hall. To the north is the kitchen. To the south is the engine room. "
	north = roomKitchen
	south = roomEngine
;

roomEngine: Room 'The Engine Room'
	"The engine room. To the north is the back hall. "
	north = roomHallBack
;

roomDormsCrew: Room 'Crew Dorms'
	"The crew's dorms. To the south is the catwalk. Above is the front hall. "
	south = roomCatwalk
	up = roomHallFront
;

roomCatwalk: Room 'The Catwalk'
	"The catwalk above the cargo bay. To the north are the crew's dorms. Beneath is the cargo bay. "
	north = roomDormsCrew
	down = roomCargoBay
;

roomAirLock: Room 'The Air Lock'
	"The air lock before the cargo bay. To the south is the cargo bay. "
	south = roomCargoBay
;

roomCargoBay: Room 'The Cargo Bay'
	"The cargo bay. To the north is the air lock. To the south is the infirmary. Above is the catwalk. "
	north = roomAirLock
	south = roomInfirmary
	up = roomCatwalk
;

roomInfirmary: Room 'The Infirmary'
	"The infirmary. To the north is the cargo bay. To the south are the passengers' dorms. "
	north = roomCargoBay
	south = roomDormsPassengers
;

roomDormsPassengers: Room 'Passenger Dorms'
	"The passenger's dorms. To the north is the infirmary. "
	north = roomInfirmary
;