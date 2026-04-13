/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = 'ICON FILENAME' (defaults to 'icons/area_misc.dmi')
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = FALSE 				(defaults to true)
	ambience_index = AMBIENCE_GENERIC   (picks the ambience from an assoc list in ambience.dm)
	ambientsounds = list()				(defaults to ambience_index's assoc on Initialize(). override it as "ambientsounds = list('sound/ambience/signal.ogg')" or by changing ambience_index)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/

/area/paradise
	name = "paradise"
	icon_state = "asteroid"
	outdoors = TRUE
	area_flags = UNIQUE_AREA | BLOBS_ALLOWED
	camera_networks = list(CAMERA_NETWORK_STATION)
	requires_power = FALSE

/area/paradise/surface
	name = "paradise surface"
	ambientsounds = list('sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambinice.ogg')
	sound_environment = null
	area_flags = VALID_TERRITORY | UNIQUE_AREA | HIDDEN_STASH_LOCATION
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/paradise/surface/sand
	name = "paradise surface sand"
	map_generator = /datum/map_generator/grass_generator

/area/paradise/surface/water
	name = "paradise surface water"
	ambientsounds = list('sound/ambience/shore.ogg')
	mood_bonus = 1
	mood_message = span_warning("The waves sound nice.\n")

/area/paradise/surface/grass
	name = "paradise surface grass"
	map_generator = /datum/map_generator/grass_generator


//STATION13
//Docking Areas

/area/docking
	ambience_index = AMBIENCE_MAINT
	mood_bonus = -1
	mood_message = span_warning("You feel that you shouldn't stay here with such shuttle traffic...\n")
	lighting_colour_tube = "#1c748a"
	lighting_colour_bulb = "#1c748a"
	lights_always_start_on = TRUE
	camera_networks = list(CAMERA_NETWORK_STATION)

/area/docking/arrival
	name = "Arrival Docking Area"
	icon_state = "arrivaldockarea"

/area/docking/arrivalaux
	name = "Auxiliary Arrival Docking Area"
	icon_state = "arrivalauxdockarea"

/area/docking/bridge
	name = "Bridge Docking Area"
	icon_state = "bridgedockarea"

//Dry Dock

/area/drydock
	name = "Shuttle drydock"
	icon_state = "drydock"
	ambience_index = AMBIENCE_MAINT
	lighting_colour_tube = "#1c748a"
	lighting_colour_bulb = "#1c748a"
	lights_always_start_on = TRUE
	camera_networks = list(CAMERA_NETWORK_STATION)

/area/drydock/security
	name = "Security Shuttle drydock"
	icon_state = "drydock_sec"

//Flavor area on Card Station

/area/syndicate_sat
	name = "Starboard Aft Bathroom" //syndies are spoofing sensor area reading
	icon_state = "syndie-control"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
