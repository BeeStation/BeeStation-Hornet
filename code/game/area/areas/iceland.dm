/area/iceland
	name = "iceland plains"
	icon_state = "iceland"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	always_unpowered = TRUE
	requires_power = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	flags_1 = NONE
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
	default_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	area_flags = UNIQUE_AREA | FLORA_ALLOWED
	lighting_overlay_colour = "#93c3cf"
	lighting_overlay_opacity = 60

/area/iceland/planetgen
	map_generator = /datum/map_generator/tundra_generator

/area/iceland/shaded
	name = "iceland plains"
	icon_state = "iceland_shaded"
	lighting_overlay_opacity = 0

/area/iceland/underground
	name = "icecaverns"
	icon_state = "iceland_underground"
	ambience_index = AMBIENCE_RUINS
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	area_flags = UNIQUE_AREA | FLORA_ALLOWED | CAVES_ALLOWED | MOB_SPAWN_ALLOWED
	lighting_overlay_opacity = 0

/area/iceland/cavern
	name = "icecaverns"
	icon_state = "iceland_cave"
	ambience_index = AMBIENCE_RUINS
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	area_flags = UNIQUE_AREA | FLORA_ALLOWED | CAVES_ALLOWED | MOB_SPAWN_ALLOWED
	map_generator = /datum/map_generator/cave_generator/iceland
	lighting_overlay_opacity = 0

/area/iceland/cavern/lavacavern
	name = "lavacaverns"
	icon_state = "iceland_lavacave"
	map_generator = /datum/map_generator/cave_generator/lavacavern
