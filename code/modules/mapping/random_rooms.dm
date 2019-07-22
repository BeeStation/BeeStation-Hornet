/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE

/datum/map_template/random_room/fivebyfour // As a general rule keep the middle 3 tiles of the long side clear for doors
	centerspawner = FALSE

/datum/map_template/random_room/fivebyfour/surgery
	name = "Abandoned Surgery"
	room_id = "surgery"
	mappath = "_maps/RandomRooms/Five-by-Four/surgery.dmm"

/datum/map_template/random_room/fivebyfour/electronics
	name = "Electronics Den"
	room_id = "electronics"
	mappath = "_maps/RandomRooms/Five-by-Four/electronics.dmm"
