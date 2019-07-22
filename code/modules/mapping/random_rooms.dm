/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0

/datum/map_template/random_room/fivebyfour // As a general rule keep the middle 3 tiles of the long side clear for doors
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/fivebyfour/surgery
	name = "Abandoned Surgery"
	room_id = "surgery"
	mappath = "_maps/RandomRooms/Five-by-Four/surgery.dmm"

/datum/map_template/random_room/fivebyfour/electronics
	name = "Electronics Den"
	room_id = "electronics"
	mappath = "_maps/RandomRooms/Five-by-Four/electronics.dmm"
