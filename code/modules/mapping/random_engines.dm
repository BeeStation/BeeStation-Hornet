/datum/map_template/random_engines
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 10 //how many times this room can appear in a round

/datum/map_template/random_engines/sk_ren_001
	name = "Meta Singularity/Tesla engine"
	room_id = "sk_ren_001Meta"
	mappath = "_maps/RandomEngines/Meta/sk_ren_001Meta.dmm"
	centerspawner = TRUE
	template_height = 23
	template_width = 19
	weight = 1