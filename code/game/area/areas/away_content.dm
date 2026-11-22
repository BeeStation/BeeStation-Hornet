/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon = 'icons/area/areas_away_missions.dmi'
	icon_state = "away"
	default_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/awaymission/beach
	name = "Beach"
	icon_state = "away"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = "#FFFFCC"
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	ambientsounds = list('sound/ambience/beach/shore.ogg', 'sound/ambience/beach/seag1.ogg','sound/ambience/beach/seag2.ogg','sound/ambience/beach/seag2.ogg','sound/ambience/misc/ambiodd.ogg','sound/ambience/medical/ambinice.ogg')

/area/awaymission/errorroom
	name = "Super Secret Room"
	static_lighting = FALSE
	base_lighting_alpha = 255
	default_gravity = STANDARD_GRAVITY
