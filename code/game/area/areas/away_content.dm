/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	ambient_effects = AWAY_MISSION

/area/awaymission/beach
	name = "Beach"
	icon_state = "away"

	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambient_effects = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambinice.ogg')

/area/awaymission/errorroom
	name = "Super Secret Room"
	has_gravity = STANDARD_GRAVITY

	base_lighting = "#ffffff"
	base_lighting_alpha = BASE_LIGHTING_ALPHA

/area/awaymission/vr
	name = "Virtual Reality"
	icon_state = "awaycontent1"
	requires_power = FALSE

	var/pacifist = TRUE // if when you enter this zone, you become a pacifist or not
	var/death = FALSE // if when you enter this zone, you die
