/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	default_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/awaymission/beach
	name = "Beach"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambinice.ogg')

/area/awaymission/errorroom
	name = "Super Secret Room"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	default_gravity = STANDARD_GRAVITY

/area/awaymission/vr
	name = "Virtual Reality"
	icon_state = "awaycontent1"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	var/pacifist = TRUE // if when you enter this zone, you become a pacifist or not
	var/death = FALSE // if when you enter this zone, you die
