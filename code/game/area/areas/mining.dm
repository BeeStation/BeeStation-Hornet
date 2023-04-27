/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	lighting_colour_tube = "#ffe8d2"
	lighting_colour_bulb = "#ffdcb7"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED
	ambient_buzz = 'sound/ambience/magma.ogg'
	ambient_buzz_vol = 10
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED

/area/mine/explored
	name = "Mine"
	icon_state = "explored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	flags_1 = NONE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = VALID_TERRITORY | UNIQUE_AREA

/area/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	flags_1 = NONE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED | CAVES_ALLOWED

/area/mine/lobby
	name = "Mining Station"

/area/mine/storage
	name = "Mining Station Storage"

/area/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Abandoned Mining Station"

/area/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Mining Station Communications"
	lighting_colour_tube = "#edfdff"
	lighting_colour_bulb = "#dafffd"

/area/mine/cafeteria
	name = "Mining Station Cafeteria"

/area/mine/hydroponics
	name = "Mining Station Hydroponics"

/area/mine/sleeper
	name = "Mining Station Emergency Sleeper"

/area/mine/laborcamp
	name = "Labor Camp"

/area/mine/laborcamp/security
	name = "Labor Camp Security"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER

//This is a placeholder for the lavaland sci area. Whoever is here after me, I have made you some additional areas to work with.
//You are free to rename these and change their icons. My job is done here.

/area/mine/science
	name = "Research Outpost"
	icon_state = "medresearch"
	requires_power = TRUE	//Remove this when there will be pre-built APCs in the area.

/area/mine/science/shuttledock
	name = "Outpost"

/area/mine/science/xenoarch
	name = "Outpost Xenoarcheology Lab"

/area/mine/science/elevator	//for going to lavaland depths if there will be those
	name = "Outpost Elevator"

/area/mine/science/experimentor
	name = "Outpost Experimentor Lab"

/area/mine/science/heavyexperiment
	name = "Outpost Reinforced Chamber"

/area/mine/science/robotics
	name = "Outpost Robotics"






/**********************Lavaland Areas**************************/

/area/lavaland
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LAVALAND
	ambient_buzz = 'sound/ambience/magma.ogg'
	ambient_buzz_vol = 20
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED

/area/lavaland/surface
	name = "Lavaland"
	icon_state = "explored"
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/lavaland/underground
	name = "Lavaland Caves"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/lavaland/surface/outdoors
	name = "Lavaland Wastes"
	outdoors = TRUE

/area/lavaland/surface/outdoors/unexplored //monsters and ruins spawn here
	icon_state = "unexplored"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED

/area/lavaland/surface/outdoors/unexplored/danger //megafauna will also spawn here
	icon_state = "danger"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED
	map_generator = /datum/map_generator/cave_generator/lavaland

/area/lavaland/surface/outdoors/explored
	name = "Lavaland Labor Camp"
	area_flags = VALID_TERRITORY | UNIQUE_AREA
