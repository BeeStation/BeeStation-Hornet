/datum/map_template/random_room
	/// The SSmapping random_room_template list is ordered by this var
	var/room_id
	var/spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	/// How likely this room is to spawn
	var/weight = 10
	/// The amount of times this room can appear in a round
	var/stock = 1
