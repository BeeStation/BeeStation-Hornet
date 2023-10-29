/area/iceland
	name = "iceland plains"
	icon_state = "iceland"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	always_unpowered = TRUE
	requires_power = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	flags_1 = NONE
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	area_flags = UNIQUE_AREA | FLORA_ALLOWED
	lighting_overlay_colour = "#93c3cf"
	lighting_overlay_opacity = 60
	ambientsounds = list('sound/ambience/ice_event/AWind1.ogg', 'sound/ambience/ice_event/AWind2.ogg', 'sound/ambience/ice_event/AWind3.ogg', \
	'sound/ambience/ice_event/AWind4.ogg', 'sound/ambience/ice_event/AWind5.ogg', 'sound/ambience/ice_event/AWind6.ogg')
	rare_ambient_sounds = list('sound/ambience/ice_event/AWhisper1.ogg', 'sound/ambience/ice_event/AWhisper2.ogg', 'sound/ambience/ice_event/AWhisper3.ogg', \
	'sound/ambience/ice_event/AWhisper4.ogg', 'sound/ambience/ice_event/AWhisper5.ogg', 'sound/ambience/ice_event/AWhisper6.ogg')
	rare_ambient_sound_chance = 10
	min_ambience_cooldown = 30 SECONDS
	max_ambience_cooldown = 120 SECONDS

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
	outdoors = FALSE

/area/iceland/underground/safe
	name = "icecaverns (but safe)"
	icon_state = "iceland_underground"
	outdoors = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	area_flags = UNIQUE_AREA | VALID_TERRITORY | HIDDEN_AREA

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
