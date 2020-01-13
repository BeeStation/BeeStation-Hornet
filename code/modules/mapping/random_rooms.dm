/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
//5x4

/datum/map_template/random_room/surgery
	name = "Abandoned Surgery"
	room_id = "surgery"
	mappath = "_maps/RandomRooms/5x4/surgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/electronics
	name = "Electronics Den"
	room_id = "electronics"
	mappath = "_maps/RandomRooms/5x4/electronics.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/template5x4
	name = "5x4 template"
	room_id = "template5x4"
	mappath = "_maps/RandomRooms/5x4/template5x4.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

//10x10

/datum/map_template/random_room/template10x10
	name = "10x10 template"
	room_id = "template10x10"
	mappath = "_maps/RandomRooms/10x10/template10x10.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10

//10x5

/datum/map_template/random_room/template10x5
	name = "10x5 template"
	room_id = "template10x5"
	mappath = "_maps/RandomRooms/10x5/template10x5.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

//5x3

/datum/map_template/random_room/template5x3
	name = "5x3 template"
	room_id = "template5x3"
	mappath = "_maps/RandomRooms/5x3/template5x3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

//3x5

/datum/map_template/random_room/template3x5
	name = "3x5 template"
	room_id = "template3x5"
	mappath = "_maps/RandomRooms/3x5/template3x5.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

//3x3

/datum/map_template/random_room/template3x3
	name = "3x3 template"
	room_id = "template3x3"
	mappath = "_maps/RandomRooms/3x3/template3x3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
