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

me: Actor
	location = roomBridge
;

roomBridge: Room 'The Bridge'
	"The bridge of the ship.
	\nTo the south is the front hall. "
	south = roomHallFront
;

roomHallFront: Room 'The Front Hall'
	"The front hall.
	\nTo the north is the bridge. To the south is the kitchen. Below are the crew's dorms. "
	north = roomBridge
	south = roomKitchen
	down = roomDormsCrew
;

roomKitchen: Room 'The Kitchen'
	"The kitchen.
	\nTo the north is the front hall. To the south is the back hall. "
	north = roomHallFront
	south = roomHallBack
;

roomHallBack: Room 'The Back Hall'
	"The back hall.
	\nTo the north is the kitchen. To the south is the engine room. "
	north = roomKitchen
	south = roomEngine
;

roomEngine: Room 'The Engine Room'
	"The engine room.
	\nTo the north is the back hall. "
	north = roomHallBack
;

roomDormsCrew: Room 'Crew Dorms'
	"The crew's dorms.
	\nTo the south is the catwalk. Above is the front hall. "
	south = roomCatwalk
	up = roomHallFront
;

roomCatwalk: Room 'The Catwalk'
	"The catwalk above the cargo bay.
	\nTo the north are the crew's dorms. Beneath is the cargo bay. "
	north = roomDormsCrew
	down = roomCargoBay
;

roomAirLock: Room 'The Air Lock'
	"The air lock before the cargo bay.
	\nTo the south is the cargo bay. "
	south = roomCargoBay
;

roomCargoBay: Room 'The Cargo Bay'
	"The cargo bay.
	\nTo the north is the air lock. To the south is the infirmary. Above is the catwalk. "
	north = roomAirLock
	south = roomInfirmary
	up = roomCatwalk
;

roomInfirmary: Room 'The Infirmary'
	"The infirmary.
	\nTo the north is the cargo bay. To the south are the passengers' dorms. "
	north = roomCargoBay
	south = roomDormsPassengers
;

roomDormsPassengers: Room 'Passenger Dorms'
	"The passenger's dorms.
	\nTo the north is the infirmary. "
	north = roomInfirmary
;