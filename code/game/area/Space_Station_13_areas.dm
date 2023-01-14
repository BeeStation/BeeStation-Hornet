/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = 'ICON FILENAME' 			(defaults to 'icons/turf/areas.dmi')
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = FALSE 				(defaults to true)
	ambience_index = AMBIENCE_GENERIC   (picks the ambience from an assoc list in ambience.dm)
	ambientsounds = list()				(defaults to ambience_index's assoc on Initialize(). override it as "ambientsounds = list('sound/ambience/signal.ogg')" or by changing ambience_index)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/

/area/ai_monitored	//stub defined ai_monitored.dm

/area/ai_monitored/turret_protected

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	area_flags = UNIQUE_AREA
	outdoors = TRUE
	ambience_index = null
	ambient_music_index = AMBIENCE_SPACE
	ambient_buzz = null
	sound_environment = SOUND_AREA_SPACE

/area/space/nearstation
	icon_state = "space_near"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT

/area/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY
	ambience_index = null
	ambient_buzz = null

/area/testroom
	requires_power = FALSE
	name = "Test Room"
	icon_state = "storage"

//EXTRA

/area/asteroid
	name = "\improper Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_MINING
	sound_environment = SOUND_AREA_ASTEROID
	area_flags = UNIQUE_AREA

/area/asteroid/nearstation
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambience_index = AMBIENCE_RUINS
	always_unpowered = FALSE
	requires_power = TRUE
	area_flags = UNIQUE_AREA | BLOBS_ALLOWED

/area/asteroid/nearstation/bomb_site
	name = "\improper Bomb Testing Asteroid"

//STATION13

//Docking Areas

/area/docking
	ambience_index = AMBIENCE_MAINT
	mood_bonus = -1
	mood_message = "<span class='warning'>You feel that you shouldn't stay here with such shuttle traffic...\n</span>"
	lighting_colour_tube = "#1c748a"
	lighting_colour_bulb = "#1c748a"

/area/docking/arrival
	name = "\improper Arrivals Docking Area"
	icon_state = "arrivaldockarea"

/area/docking/arrivalaux
	name = "\improper Auxiliary Arrivals Docking Area"
	icon_state = "arrivalauxdockarea"

/area/docking/bridge
	name = "\improper Bridge Docking Area"
	icon_state = "bridgedockarea"

//Dry Dock

/area/drydock
	name = "\improper Shuttle Drydock"
	icon_state = "drydock"
	ambience_index = AMBIENCE_MAINT
	lighting_colour_tube = "#1c748a"
	lighting_colour_bulb = "#1c748a"

/area/drydock/security
	name = "\improper Security Shuttle Drydock"
	icon_state = "drydock_sec"

//Maintenance

/area/maintenance
	ambience_index = AMBIENCE_MAINT
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	mood_bonus = -1
	mood_message = "<span class='warning'>It's kind of cramped in here!\n</span>"
	// assistants are associated with maints, jani closet is in maints, engis have to go into maints often
	mood_job_allowed = list(JOB_NAME_ASSISTANT, JOB_NAME_JANITOR, JOB_NAME_STATIONENGINEER, JOB_NAME_CHIEFENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)
	mood_job_reverse = TRUE
	lighting_colour_tube = "#ffe5cb"
	lighting_colour_bulb = "#ffdbb4"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

//Maintenance - Departmental

/area/maintenance/department/chapel
	name = "Chapel Maintenance"
	icon_state = "maint_chapel"

/area/maintenance/department/chapel/monastery
	name = "Monastery Maintenance"
	icon_state = "maint_monastery"

/area/maintenance/department/crew_quarters/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/maintenance/department/crew_quarters/dorms
	name = "Dormitory Maintenance"
	icon_state = "maint_dorms"

/area/maintenance/department/eva
	name = "EVA Maintenance"
	icon_state = "maint_eva"

/area/maintenance/department/electrical
	name = "Electrical Maintenance"
	icon_state = "maint_electrical"

/area/maintenance/department/engine/atmos
	name = "Atmospherics Maintenance"
	icon_state = "maint_atmos"

/area/maintenance/department/security
	name = "Security Maintenance"
	icon_state = "maint_sec"

/area/maintenance/department/security/brig
	name = "Brig Maintenance"
	icon_state = "maint_brig"

/area/maintenance/department/medical
	name = "Medbay Maintenance"
	icon_state = "medbay_maint"

/area/maintenance/department/medical/central
	name = "Central Medbay Maintenance"
	icon_state = "medbay_maint_central"

/area/maintenance/department/medical/morgue
	name = "Morgue Maintenance"
	icon_state = "morgue_maint"

/area/maintenance/department/science
	name = "Science Maintenance"
	icon_state = "maint_sci"

/area/maintenance/department/science/central
	name = "Central Science Maintenance"
	icon_state = "maint_sci_central"

/area/maintenance/department/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/maintenance/department/bridge
	name = "Bridge Maintenance"
	icon_state = "maint_bridge"

/area/maintenance/department/engine
	name = "Engineering Maintenance"
	icon_state = "maint_engi"

/area/maintenance/department/science/xenobiology
	name = "Xenobiology Maintenance"
	icon_state = "xenomaint"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE


//Maintenance - Generic

/area/maintenance/aft
	name = "\improper Aft Maintenance"
	icon_state = "aftmaint"

/area/maintenance/aft/secondary
	name = "\improper Aft Maintenance"
	icon_state = "aftmaint"

/area/maintenance/central
	name = "\improper Central Maintenance"
	icon_state = "centralmaint"

/area/maintenance/central/secondary
	name = "\improper Central Maintenance"
	icon_state = "centralmaint"

/area/maintenance/fore
	name = "\improper Fore Maintenance"
	icon_state = "foremaint"

/area/maintenance/fore/secondary
	name = "\improper Fore Maintenance"
	icon_state = "foremaint"

/area/maintenance/starboard
	name = "\improper Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/starboard/central
	name = "\improper Central Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/starboard/secondary
	name = "\improper Secondary Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/starboard/aft
	name = "\improper Starboard Quarter Maintenance"
	icon_state = "asmaint"

/area/maintenance/starboard/aft/secondary
	name = "\improper Secondary Starboard Quarter Maintenance"
	icon_state = "asmaint"

/area/maintenance/starboard/fore
	name = "\improper Starboard Bow Maintenance"
	icon_state = "fsmaint"

/area/maintenance/port
	name = "\improper Port Maintenance"
	icon_state = "portmaint"

/area/maintenance/port/central
	name = "\improper Central Port Maintenance"
	icon_state = "centralmaint"

/area/maintenance/port/aft
	name = "\improper Port Quarter Maintenance"
	icon_state = "apmaint"

/area/maintenance/port/fore
	name = "\improper Port Bow Maintenance"
	icon_state = "fpmaint"

/area/maintenance/disposal
	name = "\improper Waste Disposal"
	icon_state = "disposal"

/area/maintenance/disposal/incinerator
	name = "\improper Incinerator"
	icon_state = "incinerator"

//Maintenance - Upper

/area/maintenance/upper/aft
	name = "\improper Upper Aft Maintenance"
	icon_state = "aftmaint"

/area/maintenance/upper/aft/secondary
	name = "\improper Upper Aft Maintenance"
	icon_state = "aftmaint"

/area/maintenance/upper/central
	name = "\improper Upper Central Maintenance"
	icon_state = "centralmaint"

/area/maintenance/upper/central/secondary
	name = "\improper Upper Central Maintenance"
	icon_state = "centralmaint"

/area/maintenance/upper/fore
	name = "\improper Upper Fore Maintenance"
	icon_state = "foremaint"

/area/maintenance/upper/fore/secondary
	name = "\improper Upper Fore Maintenance"
	icon_state = "foremaint"

/area/maintenance/upper/starboard
	name = "\improper Upper Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/upper/starboard/central
	name = "\improper Upper Central Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/upper/starboard/secondary
	name = "\improper Upper Secondary Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/upper/starboard/aft
	name = "\improper Upper Starboard Quarter Maintenance"
	icon_state = "asmaint"

/area/maintenance/upper/starboard/aft/secondary
	name = "\improper Upper Secondary Starboard Quarter Maintenance"
	icon_state = "asmaint"

/area/maintenance/upper/starboard/fore
	name = "\improper Upper Starboard Bow Maintenance"
	icon_state = "fsmaint"

/area/maintenance/upper/port
	name = "\improper Upper Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/upper/port/central
	name = "\improper Upper Central Port Maintenance"
	icon_state = "centralmaint"

/area/maintenance/upper/port/aft
	name = "\improper Upper Port Quarter Maintenance"
	icon_state = "apmaint"

/area/maintenance/upper/port/fore
	name = "\improper Upper Port Bow Maintenance"
	icon_state = "fpmaint"


//Hallway
/area/hallway
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hallway
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8

/area/hallway/primary
	name = "\improper Primary Hallway"

/area/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/secondary/command
	name = "\improper Command Hallway"
	icon_state = "bridge_hallway"

/area/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/exit/departure_lounge
	name = "\improper Departure Lounge"
	icon_state = "escape_lounge"

/area/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/secondary/service
	name = "\improper Service Hallway"
	icon_state = "hall_service"

/area/hallway/secondary/law
	name = "\improper Law Hallway"
	icon_state = "security"

/area/hallway/secondary/asteroid
	name = "\improper Asteroid Hallway"
	icon_state = "construction"

/area/hallway/upper/primary/aft
	name = "\improper Upper Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/upper/primary/fore
	name = "\improper Upper Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/upper/primary/starboard
	name = "\improper Upper Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/upper/primary/port
	name = "\improper Upper Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/upper/primary/central
	name = "\improper Upper Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/upper/secondary/command
	name = "\improper Upper Command Hallway"
	icon_state = "bridge_hallway"

/area/hallway/upper/secondary/construction
	name = "\improper Upper Construction Area"
	icon_state = "construction"

/area/hallway/upper/secondary/exit
	name = "\improper Upper Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/upper/secondary/exit/departure_lounge
	name = "\improper Upper Departure Lounge"
	icon_state = "escape_lounge"

/area/hallway/upper/secondary/entry
	name = "\improper Upper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/upper/secondary/service
	name = "\improper Upper Service Hallway"
	icon_state = "hall_service"

//Command

/area/bridge
	name = "\improper Bridge"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION

	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/bridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/meeting_room/council
	name = "\improper Council Chamber"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/showroom/corporate
	name = "\improper Corporate Showroom"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/crew_quarters/heads/captain
	name = "\improper Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/crew_quarters/heads/captain/private
	name = "\improper Captain's Quarters"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/crew_quarters/heads/chief
	name = "\improper Chief Engineer's Office"
	icon_state = "ce_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/crew_quarters/heads/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "cmo_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/crew_quarters/heads/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "hop_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/crew_quarters/heads/hos
	name = "\improper Head of Security's Office"
	icon_state = "hos_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/crew_quarters/heads/hor
	name = "\improper Research Director's Office"
	icon_state = "rd_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/comms
	name = "\improper Communications Relay"
	icon_state = "tcom_sat_cham"
	lighting_colour_tube = "#e2feff"
	lighting_colour_bulb = "#d5fcff"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/server
	name = "\improper Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

//Crew

/area/crew_quarters
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/crew_quarters/dorms
	name = "\improper Dormitories"
	icon_state = "dorms"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>There's no place like the dorms!\n</span>"

/area/commons/dorms/barracks
	name = "\improper Sleep Barracks"

/area/commons/dorms/barracks/male
	name = "\improper Male Sleep Barracks"
	icon_state = "dorms_male"

/area/commons/dorms/barracks/female
	name = "\improper Female Sleep Barracks"
	icon_state = "dorms_female"

/area/commons/dorms/laundry
	name = "\improper Laundry Room"
	icon_state = "laundry_room"

/area/crew_quarters/dorms/upper
	name = "\improper Upper Dorms"

/area/crew_quarters/cryopods
	name = "\improper Cryopod Room"
	icon_state = "cryopod"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"

/area/crew_quarters/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet/auxiliary
	name = "\improper Auxiliary Restrooms"
	icon_state = "toilet"

/area/crew_quarters/toilet/locker
	name = "\improper Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/restrooms
	name = "\improper Restrooms"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/crew_quarters/lounge
	name = "\improper Lounge"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/crew_quarters/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/fitness/locker_room
	name = "\improper Unisex Locker Room"
	icon_state = "fitness"

/area/crew_quarters/fitness/recreation
	name = "\improper Recreation Area"
	icon_state = "fitness"

/area/crew_quarters/fitness/recreation/upper
	name = "\improper Upper Recreation Area"
	icon_state = "fitness"

/area/crew_quarters/park
	name = "\improper Recreational Park"
	icon_state = "fitness"
	lighting_colour_bulb = "#80aae9"
	lighting_colour_tube = "#80aae9"
	lighting_brightness_bulb = 9

/area/crew_quarters/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"

/area/crew_quarters/kitchen/coldroom
	name = "\improper Kitchen Cold Room"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/bar
	name = "\improper Bar"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "<span class='nicegreen'>I love being in the bar!\n</span>"
	lighting_colour_tube = "#fff4d6"
	lighting_colour_bulb = "#ffebc1"
	sound_environment = SOUND_AREA_WOODFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/crew_quarters/bar/mood_check(mob/living/carbon/subject)
	if(istype(subject) && HAS_TRAIT(subject, TRAIT_LIGHT_DRINKER))
		return FALSE
	return ..()

/area/crew_quarters/bar/lounge
	name = "\improper Bar lounge"
	icon_state = "lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/crew_quarters/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/service/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/crew_quarters/bar/atrium
	name = "\improper Atrium"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/electronic_marketing_den
	name = "\improper Electronic Marketing Den"
	icon_state = "bar"

/area/crew_quarters/abandoned_gambling_den
	name = "\improper Abandoned Gambling Den"
	icon_state = "abandoned_g_den"

/area/crew_quarters/abandoned_gambling_den/secondary
	icon_state = "abandoned_g_den_2"

/area/crew_quarters/theatre
	name = "\improper Theatre"
	icon_state = "theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/theatre/backstage
	name = "\improper Backstage"
	icon_state = "theatre_back"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/theatre/abandoned
	name = "\improper Abandoned Theatre"
	icon_state = "theatre"

/area/library
	name = "\improper Library"
	icon_state = "library"
	flags_1 = NONE

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/library/lounge
	name = "\improper Library Lounge"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	icon_state = "library"

/area/library/abandoned
	name = "\improper Abandoned Library"
	icon_state = "library"
	flags_1 = NONE

/area/chapel
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The consecration here prevents you from warping in."
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/chapel/main
	name = "\improper Chapel"

/area/chapel/main/monastery
	name = "\improper Monastery"

/area/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/chapel/asteroid
	name = "\improper Chapel Asteroid"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/chapel/asteroid/monastery
	name = "\improper Monastery Asteroid"

/area/chapel/dock
	name = "\improper Chapel Dock"
	icon_state = "construction"

/area/lawoffice
	name = "\improper Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED


//Engineering

/area/engine
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	lighting_colour_tube = "#ffce93"
	lighting_colour_bulb = "#ffbc6f"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED

/area/engine/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"

/area/engine/engineering
	name = "Engineering"
	icon_state = "engine"

/area/engineering/hallway
	name = "\improper Engineering Hallway"
	icon_state = "engine_hallway"

/area/engine/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	flags_1 = NONE

/area/engine/atmospherics_engine
	name = "\improper Atmospherics Engine"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/engine/engine_room //donut station specific
	name = "\improper Engine Room"
	icon_state = "engine_sm"

/area/engine/engine_room/external
	name = "\improper Supermatter External Access"
	icon_state = "engine_foyer"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/engine/supermatter
	name = "\improper Supermatter Engine"
	icon_state = "engine_sm_room"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/engine/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engine_foyer"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>Ahhh, time to take a break.\n</span>"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/gravity_generator
	name = "\improper Gravity Generator Room"
	icon_state = "grav_gen"
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The gravitons generated here could throw off your warp's destination and possibly throw you into deep space."
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/engine/storage
	name = "Engineering Storage"
	icon_state = "engine_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/storage_shared
	name = "Shared Engineering Storage"
	icon_state = "engine_storage_shared"

/area/engine/transit_tube
	name = "\improper Transit Tube"
	icon_state = "transit_tube"


//Solars

/area/solar
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	area_flags = UNIQUE_AREA
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_SPACE

/area/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/solar/aft
	name = "\improper Aft Solar Array"
	icon_state = "yellow"

/area/solar/aux/port
	name = "\improper Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solar/aux/starboard
	name = "\improper Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solar/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/starboard/aft
	name = "\improper Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/solar/starboard/fore
	name = "\improper Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/solar/port
	name = "\improper Port Solar Array"
	icon_state = "panelsP"

/area/solar/port/aft
	name = "\improper Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/solar/port/fore
	name = "\improper Port Bow Solar Array"
	icon_state = "panelsFP"



//Solar Maint

/area/maintenance/solars
	name = "Solar Maintenance"
	icon_state = "yellow"

/area/maintenance/solars/port
	name = "Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/solars/port/aft
	name = "Port Quarter Solar Maintenance"
	icon_state = "SolarcontrolAP"

/area/maintenance/solars/port/fore
	name = "Port Bow Solar Maintenance"
	icon_state = "SolarcontrolFP"

/area/maintenance/solars/starboard
	name = "Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/solars/starboard/aft
	name = "Starboard Quarter Solar Maintenance"
	icon_state = "SolarcontrolAS"

/area/maintenance/solars/starboard/fore
	name = "Starboard Bow Solar Maintenance"
	icon_state = "SolarcontrolFS"

//Teleporter

/area/teleporter
	name = "\improper Teleporter Room"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/gateway
	name = "\improper Gateway"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED

//MedBay

/area/medical
	name = "Medical"
	icon_state = "medbay"
	ambience_index = AMBIENCE_MEDICAL
	sound_environment = SOUND_AREA_STANDARD_STATION
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>I feel safe in here!\n</span>"
	lighting_colour_tube = "#e7f8ff"
	lighting_colour_bulb = "#d5f2ff"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/medical/medbay/zone2
	name = "\improper Medbay"
	icon_state = "medbay2"

/area/medical/abandoned
	name = "\improper Abandoned Medbay"
	icon_state = "abandoned_medbay"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/medbay/balcony
	name = "\improper Medbay Balcony"
	icon_state = "medbay"

/area/medical/medbay/central
	name = "\improper Medbay Central"
	icon_state = "med_central"

/area/medical/medbay/lobby
	name = "\improper Medbay Lobby"
	icon_state = "med_lobby"

	//Medbay is a large area, these additional areas help level out APC load.

/area/medical/medbay/aft
	name = "\improper Medbay Aft"
	icon_state = "med_aft"

/area/medical/storage
	name = "Medbay Storage"
	icon_state = "med_storage"

/area/medical/office
	name = "\improper Medical Office"
	icon_state = "med_office"

/area/medical/break_room
	name = "\improper Medical Break Room"
	icon_state = "med_break"

/area/medical/patients_rooms
	name = "Patients' Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/medical/patients_rooms/room_a
	name = "Patient Room A"
	icon_state = "patients"

/area/medical/patients_rooms/room_b
	name = "Patient Room B"
	icon_state = "patients"

/area/medical/patients_rooms/room_c
	name = "Patient Room C"
	icon_state = "patients"

/area/medical/virology
	name = "Virology"
	icon_state = "virology"
	flags_1 = NONE
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -2
	mood_message = "<span class='warning'>It smells like death in here!\n</span>"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/medical/chemistry/upper
	name = "Upper Chemistry"
	icon_state = "chem"

/area/medical/apothecary
	name = "Apothecary"
	icon_state = "apothecary"

/area/medical/surgery
	name = "Surgery"
	icon_state = "surgery"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED

/area/medical/surgery/aux
	name = "Auxillery Surgery"
	icon_state = "surgery"

/area/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "\improper Genetics Lab"
	icon_state = "genetics"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/medical/genetics/cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "\improper Medbay Treatment Center"
	icon_state = "exam_room"


//Security

/area/security
	name = "Security"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_AREA_STANDARD_STATION
	lighting_colour_tube = "#ffeee2"
	lighting_colour_bulb = "#ffdfca"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/security/main
	name = "\improper Security Office"
	icon_state = "security"

/area/security/brig
	name = "\improper Brig"
	icon_state = "brig"
	mood_bonus = -3
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN,JOB_NAME_SECURITYOFFICER,JOB_NAME_BRIGPHYSICIAN,JOB_NAME_DETECTIVE)
	mood_job_reverse = TRUE

	mood_message = "<span class='warning'>I hate cramped brig cells.\n</span>"

/area/security/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED

/area/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"
	mood_bonus = -4
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN, JOB_NAME_SECURITYOFFICER)  // JUSTICE!
	mood_job_reverse = TRUE
	mood_message = "<span class='warning'>I'm trapped here with little hope of escape!\n</span>"

/area/security/prison/shielded
	name = "\improper Prison Wing Shielded area"
	icon_state = "sec_prison"

/area/security/processing
	name = "\improper Labor Shuttle Dock"
	icon_state = "sec_prison"

/area/security/processing/cremation
	name = "\improper Security Crematorium"
	icon_state = "sec_prison"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/security/warden
	name = "\improper Brig Control"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg','sound/ambience/ambidet3.ogg','sound/ambience/ambidet4.ogg')

/area/security/detectives_office/private_investigators_office
	name = "\improper Private Investigator's Office"
	icon_state = "detective"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

/area/security/execution
	icon_state = "execution_room"
	mood_bonus = -5
	mood_message = "<span class='warning'>I feel a sense of impending doom.\n</span>"

/area/security/execution/transfer
	name = "\improper Transfer Centre"

/area/security/execution/education
	name = "\improper Prisoner Education Chamber"

/area/security/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/ai_monitored/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint"

/area/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

/area/security/checkpoint/escape
	icon_state = "checkpoint_esc"

/area/security/checkpoint/supply
	name = "\improper Security Post - Cargo Bay"
	icon_state = "checkpoint_supp"

/area/security/checkpoint/engineering
	name = "\improper Security Post - Engineering"
	icon_state = "checkpoint_engi"

/area/security/checkpoint/medical
	name = "\improper Security Post - Medbay"
	icon_state = "checkpoint_med"

/area/security/checkpoint/science
	name = "\improper Security Post - Science"
	icon_state = "checkpoint_sci"

/area/security/checkpoint/science/research
	name = "\improper Security Post - Research Division"
	icon_state = "checkpoint_res"

/area/security/checkpoint/customs
	name = "Customs"
	icon_state = "customs_point"

/area/security/checkpoint/customs/auxiliary
	icon_state = "customs_point_aux"

/area/security/prison/vip
	name = "\improper VIP Prison Wing"
	icon_state = "sec_prison"

/area/security/prison/asteroid
	name = "\improper Outer Asteroid Prison Wing"
	icon_state = "sec_prison"

/area/security/prison/asteroid/service
	name = "\improper Outer Asteroid Prison Wing Services"
	icon_state = "sec_prison"

/area/security/prison/asteroid/arrival
	name = "\improper Outer Asteroid Prison Wing Arrival"
	icon_state = "sec_prison"

/area/security/prison/asteroid/abbandoned
	name = "\improper Outer Asteroid Prison Wing Abandoned maintenance"
	icon_state = "sec_prison"
	mood_bonus = -2
	mood_message = "<span class='warning'>This place gives me the creeps...\n</span>"

/area/security/prison/asteroid/shielded
	name = "\improper Outer Asteroid Prison Wing Shielded area"
	icon_state = "sec_prison"

//Cargo

/area/quartermaster
	name = "Quartermasters"
	icon_state = "quart"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/quartermaster/sorting
	name = "\improper Delivery Office"
	icon_state = "cargo_delivery"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/quartermaster/warehouse
	name = "\improper Warehouse"
	icon_state = "cargo_warehouse"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/quartermaster/office
	name = "\improper Cargo Office"
	icon_state = "cargo_office"

/area/quartermaster/storage
	name = "\improper Cargo Bay"
	icon_state = "cargo_bay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/cargo/lobby
	name = "\improper Cargo Lobby"
	icon_state = "cargo_lobby"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/quartermaster/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quart_office"

/area/quartermaster/qm_bedroom
	name = "\improper Quartermaster's Bedroom"
	icon_state = "quart_private"

/area/quartermaster/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining_dock"

/area/quartermaster/miningoffice
	name = "\improper Mining Office"
	icon_state = "mining"

/area/quartermaster/meeting_room
	name = "\improper Supply Meeting Room"
	icon_state = "quart_perch"

/area/quartermaster/exploration_prep
	name = "\improper Exploration Preparation Room"
	icon_state = "mining"

/area/quartermaster/exploration_dock
	name = "\improper Exploration Dock"
	icon_state = "mining"

//Service

/area/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"
	flags_1 = NONE
	mood_bonus = -1
	mood_message = "<span class='warning'>It feels dirty in here!\n</span>"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/hydroponics/garden
	name = "\improper Garden"
	icon_state = "garden"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>It's so peaceful in here!\n</span>"

/area/hydroponics/garden/abandoned
	name = "\improper Abandoned Garden"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/hydroponics/garden/monastery
	name = "\improper Monastery Garden"
	icon_state = "hydro"


//Science

/area/science
	name = "Science Division"
	icon_state = "science"
	lighting_colour_tube = "#f0fbff"
	lighting_colour_bulb = "#e4f7ff"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED

/area/science/lobby
	name = "\improper Science Lobby"
	icon_state = "science_lobby"

/area/science/breakroom
	name = "\improper Science Break Room"
	icon_state = "science_breakroom"

/area/science/lab
	name = "Research and Development"
	icon_state = "research"

/area/science/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenobio"

/area/science/shuttle
	name = "Shuttle Construction"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"

/area/science/storage
	name = "Toxins Storage"
	icon_state = "tox_storage"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/science/test_area
	name = "\improper Toxins Test Area"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "tox_test"

/area/science/mixing
	name = "\improper Toxins Mixing Lab"
	icon_state = "tox_mix"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/science/mixing/chamber
	name = "\improper Toxins Mixing Chamber"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "tox_mix_chamber"

/area/science/misc_lab
	name = "\improper Testing Lab"
	icon_state = "tox_misc"

/area/science/misc_lab/range
	name = "\improper Research Testing Range"
	icon_state = "tox_range"

/area/science/server
	name = "\improper Research Division Server Room"
	icon_state = "server"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/science/explab
	name = "\improper Experimentation Lab"
	icon_state = "exp_lab"

/area/science/robotics
	name = "Robotics"
	icon_state = "robotics"

/area/science/robotics/mechbay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/science/robotics/lab
	name = "\improper Robotics Lab"
	icon_state = "ass_line"

/area/science/research
	name = "\improper Research Division"
	icon_state = "science"

/area/science/research/abandoned
	name = "\improper Abandoned Research Lab"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/science/nanite
	name = "\improper Nanite Lab"
	icon_state = "nanite_lab"

/area/science/shuttledock
	name = "\improper Science Shuttle Dock"
	icon_state = "sci_dock"

//Storage
/area/storage
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/storage/tools
	name = "\improper Auxiliary Tool Storage"
	icon_state = "tool_storage"

/area/storage/primary
	name = "\improper Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "art_storage"

/area/storage/tcom
	name = "Telecomms Storage"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "green"

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	clockwork_warp_allowed = FALSE

/area/storage/emergency/starboard
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency/port
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "tech_storage"

//Construction

/area/construction
	name = "\improper Construction Area"
	icon_state = "yellow"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/construction/mining/aux_base
	name = "\improper Auxiliary Base Construction"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/construction/storage_wing
	name = "\improper Storage Wing"
	icon_state = "storage_wing"

// Vacant Rooms
/area/vacant_room
	name = "\improper Vacant Room"
	icon_state = "yellow"
	ambience_index = AMBIENCE_MAINT
	icon_state = "vacant_room"

/area/vacant_room/office
	name = "\improper Vacant Office"
	icon_state = "vacant_office"

/area/vacant_room/commissary
	name = "\improper Vacant Commissary"
	icon_state = "vacant_commissary"

/area/vacant_room/commissary/commissary1
	name = "\improper Vacant Commissary #1"
	icon_state = "vacant_commissary"

/area/vacant_room/commissary/commissary2
	name = "\improper Vacant Commissary #2"
	icon_state = "vacant_commissary"

/area/vacant_room/commissary/commissaryFood
	name = "\improper Vacant Food Stall Commissary"
	icon_state = "vacant_commissary"

/area/vacant_room/commissary/commissaryRandom
	name = "\improper Unique Commissary"
	icon_state = "vacant_commissary"

//AI

/area/ai_monitored
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/ai_monitored/security/armory
	name = "\improper Armory"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	mood_job_allowed = list(JOB_NAME_WARDEN)
	mood_bonus = 1
	mood_message = "<span class='nicegreen'>It's good to be home.</span>"

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER

/area/ai_monitored/storage/satellite
	name = "AI Satellite Maint"
	icon_state = "storage"
	ambience_index = AMBIENCE_DANGER

	//Turret_protected

/area/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/ai_monitored/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_job_allowed = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CAPTAIN)
	mood_bonus = 4
	mood_message = "<span class='nicegreen'>The AI will bend to my will!\n</span>"

/area/ai_monitored/turret_protected/ai_upload_foyer
	name = "\improper AI Upload Access"
	icon_state = "ai_upload_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ai_monitored/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"

/area/ai_monitored/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/ai_monitored/turret_protected/aisat/atmos
	name = "\improper AI Satellite Atmos"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/foyer
	name = "\improper AI Satellite Foyer"
	icon_state = "ai_foyer"

/area/ai_monitored/turret_protected/aisat/service
	name = "\improper AI Satellite Service"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/hallway
	name = "\improper AI Satellite Hallway"
	icon_state = "ai"

/area/aisat
	name = "\improper AI Satellite Exterior"
	icon_state = "yellow"

/area/ai_monitored/turret_protected/aisat/maint
	name = "\improper AI Satellite Maintenance"
	icon_state = "ai_maint"

/area/ai_monitored/turret_protected/aisat_interior
	name = "\improper AI Satellite Antechamber"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/ai_monitored/turret_protected/AIsatextAS
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_east"

/area/ai_monitored/turret_protected/AIsatextAP
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_west"


// Telecommunications Satellite

/area/tcommsat
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "For safety reasons, warping here is disallowed; the radio and bluespace noise could cause catastrophic results."
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	network_root_id = STATION_NETWORK_ROOT	// They should of unpluged the router before they left
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/tcommsat/computer
	name = "\improper Telecomms Control Room"
	icon_state = "tcom_sat_comp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	mood_job_allowed = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER)
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>It's good to see these in working order.\n</span>"

/area/tcommsat/server
	name = "\improper Telecomms Server Room"
	icon_state = "tcom_sat_cham"

/area/tcommsat/relay
	name = "\improper Telecommunications Relay"
	icon_state = "tcom_sat_cham"
