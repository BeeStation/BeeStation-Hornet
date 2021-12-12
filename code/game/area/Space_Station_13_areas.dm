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
	name = "Asteroid"
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
	name = "Bomb Testing Asteroid"

//STATION13

//Maintenance

/area/maintenance
	ambience_index = AMBIENCE_MAINT
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	mood_bonus = -1
	mood_message = "<span class='warning'>It's kind of cramped in here!\n</span>"
	lighting_colour_tube = "#ffe5cb"
	lighting_colour_bulb = "#ffdbb4"

//Departments

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
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/aft/secondary
	name = "Aft Maintenance"
	icon_state = "amaint_2"

/area/maintenance/central
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/central/secondary
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/fore/secondary
	name = "Fore Maintenance"
	icon_state = "fmaint_2"

/area/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/starboard/central
	name = "Central Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/starboard/secondary
	name = "Secondary Starboard Maintenance"
	icon_state = "smaint_2"

/area/maintenance/starboard/aft
	name = "Starboard Quarter Maintenance"
	icon_state = "asmaint"

/area/maintenance/starboard/aft/secondary
	name = "Secondary Starboard Quarter Maintenance"
	icon_state = "asmaint_2"

/area/maintenance/starboard/fore
	name = "Starboard Bow Maintenance"
	icon_state = "fsmaint"

/area/maintenance/port
	name = "Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/port/central
	name = "Central Port Maintenance"
	icon_state = "maintcentral"

/area/maintenance/port/aft
	name = "Port Quarter Maintenance"
	icon_state = "apmaint"

/area/maintenance/port/fore
	name = "Port Bow Maintenance"
	icon_state = "fpmaint"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/maintenance/disposal/incinerator
	name = "Incinerator"
	icon_state = "disposal"

//Maintenance - Upper

/area/maintenance/upper/aft
	name = "Upper Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/upper/aft/secondary
	name = "Upper Aft Maintenance"
	icon_state = "amaint_2"

/area/maintenance/upper/central
	name = "Upper Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/upper/central/secondary
	name = "Upper Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/upper/fore
	name = "Upper Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/upper/fore/secondary
	name = "Upper Fore Maintenance"
	icon_state = "fmaint_2"

/area/maintenance/upper/starboard
	name = "Upper Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/upper/starboard/central
	name = "Upper Central Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/upper/starboard/secondary
	name = "Upper Secondary Starboard Maintenance"
	icon_state = "smaint_2"

/area/maintenance/upper/starboard/aft
	name = "Upper Starboard Quarter Maintenance"
	icon_state = "asmaint"

/area/maintenance/upper/starboard/aft/secondary
	name = "Upper Secondary Starboard Quarter Maintenance"
	icon_state = "asmaint_2"

/area/maintenance/upper/starboard/fore
	name = "Upper Starboard Bow Maintenance"
	icon_state = "fsmaint"

/area/maintenance/upper/port
	name = "Upper Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/upper/port/central
	name = "Upper Central Port Maintenance"
	icon_state = "maintcentral"

/area/maintenance/upper/port/aft
	name = "Upper Port Quarter Maintenance"
	icon_state = "apmaint"

/area/maintenance/upper/port/fore
	name = "Upper Port Bow Maintenance"
	icon_state = "fpmaint"


//Hallway
/area/hallway
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hallway
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8


/area/hallway/primary/aft
	name = "Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/fore
	name = "Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/port
	name = "Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/secondary/command
	name = "Command Hallway"
	icon_state = "bridge_hallway"

/area/hallway/secondary/construction
	name = "Construction Area"
	icon_state = "construction"

/area/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/exit/departure_lounge
	name = "Departure Lounge"
	icon_state = "escape_lounge"

/area/hallway/secondary/entry
	name = "Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/secondary/service
	name = "Service Hallway"
	icon_state = "hall_service"

/area/hallway/secondary/law
	name = "Law Hallway"
	icon_state = "security"


/area/hallway/upper/primary/aft
	name = "Upper Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/upper/primary/fore
	name = "Upper Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/upper/primary/starboard
	name = "Upper Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/upper/primary/port
	name = "Upper Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/upper/primary/central
	name = "Upper Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/upper/secondary/command
	name = "Upper Command Hallway"
	icon_state = "bridge_hallway"

/area/hallway/upper/secondary/construction
	name = "Upper Construction Area"
	icon_state = "construction"

/area/hallway/upper/secondary/exit
	name = "Upper Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/upper/secondary/exit/departure_lounge
	name = "Upper Departure Lounge"
	icon_state = "escape_lounge"

/area/hallway/upper/secondary/entry
	name = "Upper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/upper/secondary/service
	name = "Upper Service Hallway"
	icon_state = "hall_service"

//Command

/area/bridge
	name = "Bridge"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/meeting_room/council
	name = "Council Chamber"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/showroom/corporate
	name = "Corporate Showroom"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/crew_quarters/heads/captain
	name = "Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/heads/captain/private
	name = "Captain's Quarters"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/heads/chief
	name = "Chief Engineer's Office"
	icon_state = "ce_office"

/area/crew_quarters/heads/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/crew_quarters/heads/hop
	name = "Head of Personnel's Office"
	icon_state = "hop_office"

/area/crew_quarters/heads/hos
	name = "Head of Security's Office"
	icon_state = "hos_office"

/area/crew_quarters/heads/hor
	name = "Research Director's Office"
	icon_state = "rd_office"

/area/comms
	name = "Communications Relay"
	icon_state = "tcomsatcham"
	lighting_colour_tube = "#e2feff"
	lighting_colour_bulb = "#d5fcff"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/server
	name = "Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

//Crew

/area/crew_quarters
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/crew_quarters/dorms
	name = "Dormitories"
	icon_state = "Sleep"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>There's no place like the dorms!\n</span>"

/area/crew_quarters/dorms/upper
	name = "Upper Dorms"

/area/crew_quarters/cryopods
	name = "Cryopod Room"
	icon_state = "cryopod"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"

/area/crew_quarters/toilet
	name = "Dormitory Toilets"
	icon_state = "toilet"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet/auxiliary
	name = "Auxiliary Restrooms"
	icon_state = "toilet"

/area/crew_quarters/toilet/locker
	name = "Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/toilet/restrooms
	name = "Restrooms"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"

/area/crew_quarters/lounge
	name = "Lounge"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/fitness/locker_room
	name = "Unisex Locker Room"
	icon_state = "fitness"

/area/crew_quarters/fitness/recreation
	name = "Recreation Area"
	icon_state = "fitness"

/area/crew_quarters/fitness/recreation/upper
	name = "Upper Recreation Area"
	icon_state = "fitness"

/area/crew_quarters/park
	name = "Recrational Park"
	icon_state = "fitness"
	lighting_colour_bulb = "#80aae9"
	lighting_colour_tube = "#80aae9"
	lighting_brightness_bulb = 9

/area/crew_quarters/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"

/area/crew_quarters/kitchen/coldroom
	name = "Kitchen Cold Room"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/bar
	name = "Bar"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "<span class='nicegreen'>I love being in the bar!\n</span>"
	lighting_colour_tube = "#fff4d6"
	lighting_colour_bulb = "#ffebc1"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/service/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/crew_quarters/bar/atrium
	name = "Atrium"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/electronic_marketing_den
	name = "Electronic Marketing Den"
	icon_state = "bar"

/area/crew_quarters/abandoned_gambling_den
	name = "Abandoned Gambling Den"
	icon_state = "abandoned_g_den"

/area/crew_quarters/abandoned_gambling_den/secondary
	icon_state = "abandoned_g_den_2"

/area/crew_quarters/theatre
	name = "Theatre"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/theatre/abandoned
	name = "Abandoned Theatre"
	icon_state = "Theatre"

/area/library
	name = "Library"
	icon_state = "library"
	flags_1 = NONE

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8

/area/library/lounge
	name = "Library Lounge"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	icon_state = "library"

/area/library/abandoned
	name = "Abandoned Library"
	icon_state = "library"
	flags_1 = NONE

/area/chapel
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The consecration here prevents you from warping in."
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/chapel/main
	name = "Chapel"

/area/chapel/main/monastery
	name = "Monastery"

/area/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"

/area/chapel/asteroid
	name = "Chapel Asteroid"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/chapel/asteroid/monastery
	name = "Monastery Asteroid"

/area/chapel/dock
	name = "Chapel Dock"
	icon_state = "construction"

/area/lawoffice
	name = "Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR


//Engineering

/area/engine
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	lighting_colour_tube = "#ffce93"
	lighting_colour_bulb = "#ffbc6f"

/area/engine/engine_smes
	name = "Engineering SMES"
	icon_state = "engine_smes"

/area/engine/engineering
	name = "Engineering"
	icon_state = "engine"

/area/engine/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	flags_1 = NONE

/area/engine/atmospherics_engine
	name = "Atmospherics Engine"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/engine/engine_room //donut station specific
	name = "Engine Room"
	icon_state = "atmos_engine"

/area/engine/engine_room/external
	name = "Supermatter External Access"
	icon_state = "engine_foyer"

/area/engine/supermatter
	name = "Supermatter Engine"
	icon_state = "engine_sm"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/break_room
	name = "Engineering Foyer"
	icon_state = "engine_foyer"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>Ahhh, time to take a break.\n</span>"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/gravity_generator
	name = "Gravity Generator Room"
	icon_state = "grav_gen"
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The gravitons generated here could throw off your warp's destination and possibly throw you into deep space."

/area/engine/storage
	name = "Engineering Storage"
	icon_state = "engi_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/storage_shared
	name = "Shared Engineering Storage"
	icon_state = "engi_storage"

/area/engine/transit_tube
	name = "Transit Tube"
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
	name = "Fore Solar Array"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/solar/aft
	name = "Aft Solar Array"
	icon_state = "yellow"

/area/solar/aux/port
	name = "Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solar/aux/starboard
	name = "Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/solar/starboard
	name = "Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/starboard/aft
	name = "Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/solar/starboard/fore
	name = "Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/solar/port
	name = "Port Solar Array"
	icon_state = "panelsP"

/area/solar/port/aft
	name = "Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/solar/port/fore
	name = "Port Bow Solar Array"
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
	name = "Teleporter Room"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI

/area/gateway
	name = "Gateway"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

//MedBay

/area/medical
	name = "Medical"
	icon_state = "medbay3"
	ambience_index = AMBIENCE_MEDICAL
	sound_environment = SOUND_AREA_STANDARD_STATION
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>I feel safe in here!\n</span>"
	lighting_colour_tube = "#e7f8ff"
	lighting_colour_bulb = "#d5f2ff"

/area/medical/abandoned
	name = "Abandoned Medbay"
	icon_state = "medbay3"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/medbay/balcony
	name = "Medbay Balcony"
	icon_state = "medbay"

/area/medical/medbay/central
	name = "Medbay Central"
	icon_state = "medbay"

/area/medical/medbay/lobby
	name = "Medbay Lobby"
	icon_state = "medbay"

	//Medbay is a large area, these additional areas help level out APC load.

/area/medical/medbay/zone2
	name = "Medbay"
	icon_state = "medbay2"

/area/medical/medbay/aft
	name = "Medbay Aft"
	icon_state = "medbay3"

/area/medical/storage
	name = "Medbay Storage"
	icon_state = "medbay2"

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

/area/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -2
	mood_message = "<span class='warning'>It smells like death in here!\n</span>"

/area/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/medical/chemistry/upper
	name = "Upper Chemistry"
	icon_state = "chem"

/area/medical/apothecary
	name = "Apothecary"
	icon_state = "apothecary"

/area/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/medical/surgery/aux
	name = "Auxillery Surgery"
	icon_state = "surgery"

/area/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics/cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Medbay Treatment Center"
	icon_state = "exam_room"


//Security

/area/security
	name = "Security"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_AREA_STANDARD_STATION
	lighting_colour_tube = "#ffeee2"
	lighting_colour_bulb = "#ffdfca"

/area/security/main
	name = "Security Office"
	icon_state = "security"

/area/security/brig
	name = "Brig"
	icon_state = "brig"
	mood_bonus = -3
	mood_message = "<span class='warning'>I hate cramped brig cells.\n</span>"

/area/security/courtroom
	name = "Courtroom"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	mood_bonus = -4
	mood_message = "<span class='warning'>I'm trapped here with little hope of escape!\n</span>"

/area/security/processing
	name = "Labor Shuttle Dock"
	icon_state = "sec_prison"

/area/security/processing/cremation
	name = "Security Crematorium"
	icon_state = "sec_prison"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/security/warden
	name = "Brig Control"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg','sound/ambience/ambidet3.ogg','sound/ambience/ambidet4.ogg')

/area/security/detectives_office/private_investigators_office
	name = "Private Investigator's Office"
	icon_state = "detective"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/security/execution
	icon_state = "execution_room"
	mood_bonus = -5
	mood_message = "<span class='warning'>I feel a sense of impending doom.\n</span>"

/area/security/execution/transfer
	name = "Transfer Centre"

/area/security/execution/education
	name = "Prisoner Education Chamber"

/area/security/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/ai_monitored/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

/area/security/checkpoint/escape
	icon_state = "checkpoint_esc"

/area/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint_supp"

/area/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint_engi"

/area/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint_med"

/area/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint_sci"

/area/security/checkpoint/science/research
	name = "Security Post - Research Division"
	icon_state = "checkpoint_res"

/area/security/checkpoint/customs
	name = "Customs"
	icon_state = "customs_point"

/area/security/checkpoint/customs/auxiliary
	icon_state = "customs_point_aux"


//Service

/area/quartermaster
	name = "Quartermasters"
	icon_state = "quart"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/quartermaster/sorting
	name = "Delivery Office"
	icon_state = "cargo_delivery"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/quartermaster/warehouse
	name = "Warehouse"
	icon_state = "cargo_warehouse"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "cargo_bay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/quartermaster/qm
	name = "Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/qm_bedroom
	name = "Quartermaster's Bedroom"
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningoffice
	name = "Mining Office"
	icon_state = "mining"

/area/quartermaster/meeting_room
	name = "Supply Meeting Room"
	icon_state = "mining"

/area/quartermaster/exploration_prep
	name = "Exploration Preparation Room"
	icon_state = "mining"

/area/quartermaster/exploration_dock
	name = "Exploration Dock"
	icon_state = "mining"

/area/janitor
	name = "Custodial Closet"
	icon_state = "janitor"
	flags_1 = NONE
	mood_bonus = -1
	mood_message = "<span class='warning'>It feels dirty in here!\n</span>"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hydroponics/garden
	name = "Garden"
	icon_state = "garden"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>It's so peaceful in here!\n</span>"

/area/hydroponics/garden/abandoned
	name = "Abandoned Garden"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/hydroponics/garden/monastery
	name = "Monastery Garden"
	icon_state = "hydro"


//Science

/area/science
	name = "Science Division"
	icon_state = "toxlab"
	lighting_colour_tube = "#f0fbff"
	lighting_colour_bulb = "#e4f7ff"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/science/lab
	name = "Research and Development"
	icon_state = "toxlab"

/area/science/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxlab"

/area/science/shuttle
	name = "Shuttle Construction"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"

/area/science/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"

/area/science/test_area
	name = "Toxins Test Area"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "toxtest"

/area/science/mixing
	name = "Toxins Mixing Lab"
	icon_state = "toxmix"

/area/science/mixing/chamber
	name = "Toxins Mixing Chamber"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "toxmix"

/area/science/misc_lab
	name = "Testing Lab"
	icon_state = "toxmisc"

/area/science/misc_lab/range
	name = "Research Testing Range"
	icon_state = "toxmisc"

/area/science/server
	name = "Research Division Server Room"
	icon_state = "server"

/area/science/explab
	name = "Experimentation Lab"
	icon_state = "toxmisc"

/area/science/robotics
	name = "Robotics"
	icon_state = "medresearch"

/area/science/robotics/mechbay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/science/robotics/lab
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/science/research
	name = "Research Division"
	icon_state = "medresearch"

/area/science/research/abandoned
	name = "Abandoned Research Lab"
	icon_state = "medresearch"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/science/nanite
	name = "Nanite Lab"
	icon_state = "toxmisc"

/area/science/shuttledock
	name = "Science Shuttle Dock"
	icon_state = "toxmisc"

//Storage
/area/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

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
	icon_state = "auxstorage"

//Construction

/area/construction
	name = "Construction Area"
	icon_state = "yellow"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/construction/mining/aux_base
	name = "Auxiliary Base Construction"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/construction/storage_wing
	name = "Storage Wing"
	icon_state = "storage_wing"

// Vacant Rooms
/area/vacant_room
	name = "Vacant Room"
	icon_state = "yellow"
	ambience_index = AMBIENCE_MAINT
	icon_state = "vacant_room"

/area/vacant_room/office
	name = "Vacant Office"
	icon_state = "vacant_office"

/area/vacant_room/commissary
	name = "Vacant Commissary"
	icon_state = "vacant_commissary"

//AI

/area/ai_monitored
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ai_monitored/security/armory
	name = "Armory"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER

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
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ai_monitored/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ai_monitored/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/ai_monitored/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/ai_monitored/turret_protected/aisat/atmos
	name = "AI Satellite Atmos"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/foyer
	name = "AI Satellite Foyer"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/service
	name = "AI Satellite Service"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/hallway
	name = "AI Satellite Hallway"
	icon_state = "ai"

/area/aisat
	name = "AI Satellite Exterior"
	icon_state = "yellow"

/area/ai_monitored/turret_protected/aisat_interior
	name = "AI Satellite Antechamber"
	icon_state = "ai"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/ai_monitored/turret_protected/AIsatextAS
	name = "AI Sat Ext"
	icon_state = "storage"

/area/ai_monitored/turret_protected/AIsatextAP
	name = "AI Sat Ext"
	icon_state = "storage"


// Telecommunications Satellite

/area/tcommsat
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "For safety reasons, warping here is disallowed; the radio and bluespace noise could cause catastrophic results."
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')

/area/tcommsat/computer
	name = "Telecomms Control Room"
	icon_state = "tcomsatcomp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/tcommsat/server
	name = "Telecomms Server Room"
	icon_state = "tcomsatcham"

/area/tcommsat/relay
	name = "Telecommunications Relay"
	icon_state = "tcomsatcham"
