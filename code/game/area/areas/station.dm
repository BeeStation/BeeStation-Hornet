// Station areas and shuttles

/area/station
	name = "Station Areas"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "station"
	camera_networks = list(CAMERA_NETWORK_STATION)

//Maintenance

/area/station/maintenance
	name = "Generic Maintenance"
	ambience_index = AMBIENCE_MAINT
	ambient_buzz = 'sound/ambience/source_corridor2.ogg'
	ambient_buzz_vol = 20
	area_flags = HIDDEN_STASH_LOCATION | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	rare_ambient_sounds = list(
		'sound/machines/airlock.ogg',
		'sound/effects/snap.ogg',
		'sound/effects/clownstep1.ogg',
		'sound/effects/clownstep2.ogg',
		'sound/items/welder.ogg',
		'sound/items/welder2.ogg',
		'sound/items/crowbar.ogg',
		'sound/items/deconstruct.ogg',
		'sound/ambience/source_holehit3.ogg',
		'sound/ambience/cavesound3.ogg',
	)
	min_ambience_cooldown = 20 SECONDS
	max_ambience_cooldown = 35 SECONDS
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	mood_bonus = -1
	mood_message = span_warning("It's kind of cramped in here!\n")
	// assistants are associated with maints, jani closet is in maints, engis have to go into maints often
	mood_job_allowed = list(JOB_NAME_ASSISTANT, JOB_NAME_JANITOR, JOB_NAME_STATIONENGINEER, JOB_NAME_CHIEFENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)
	mood_job_reverse = TRUE
	lighting_colour_tube = "#ffe5cb"
	lighting_colour_bulb = "#ffdbb4"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_NONE
	lights_always_start_on = TRUE
	color_correction = /datum/client_colour/area_color/cold_ish
	camera_networks = list(CAMERA_NETWORK_STATION) //Maint cameras go fuck yourself

/area/station/maintenance/get_area_textures()
	return GLOB.turf_texture_maint

//Maintenance - Departmental

/area/station/maintenance/department/chapel
	name = "Chapel Maintenance"
	icon_state = "maint_chapel"

/area/station/maintenance/department/chapel/monastery
	name = "Monastery Maintenance"
	icon_state = "maint_monastery"

/area/station/maintenance/department/crew_quarters/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"
	sound_environment = SOUND_AREA_WOODFLOOR
	color_correction = /datum/client_colour/area_color/warm_ish

/area/station/maintenance/department/crew_quarters/dorms
	name = "Dormitory Maintenance"
	icon_state = "maint_dorms"

/area/station/maintenance/department/eva
	name = "EVA Maintenance"
	icon_state = "maint_eva"

/area/station/maintenance/department/electrical
	name = "Electrical Maintenance"
	icon_state = "maint_electrical"

/area/station/maintenance/department/engine/atmos
	name = "Atmospherics Maintenance"
	icon_state = "maint_atmos"

/area/station/maintenance/department/security
	name = "Security Maintenance"
	icon_state = "maint_sec"

/area/station/maintenance/department/security/upper
	name = "Upper Security Maintenance"

/area/station/maintenance/department/security/brig
	name = "Brig Maintenance"
	icon_state = "maint_brig"

/area/station/maintenance/department/medical
	name = "Medbay Maintenance"
	icon_state = "medbay_maint"

/area/station/maintenance/department/medical/central
	name = "Central Medbay Maintenance"
	icon_state = "medbay_maint_central"

/area/station/maintenance/department/medical/morgue
	name = "Morgue Maintenance"
	icon_state = "morgue_maint"

/area/station/maintenance/department/science
	name = "Science Maintenance"
	icon_state = "maint_sci"

/area/station/maintenance/department/science/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/maintenance/department/science/central
	name = "Central Science Maintenance"
	icon_state = "maint_sci_central"

/area/station/maintenance/department/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/station/maintenance/department/bridge
	name = "Bridge Maintenance"
	icon_state = "maint_bridge"
	camera_networks = list(CAMERA_NETWORK_PRIVATE)

/area/station/maintenance/department/engine
	name = "Engineering Maintenance"
	icon_state = "maint_engi"

/area/station/maintenance/department/science/xenobiology
	name = "Xenobiology Maintenance"
	icon_state = "xenomaint"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE | CULT_PERMITTED

//Maintenance - Cardstation's club

/area/station/maintenance/club
	name = "Abandoned Club"
	icon_state = "yellow"

//Maintenance - Generic Tunnels

/area/station/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "aftmaint"

/area/station/maintenance/aft/upper
	name = "Upper Aft Maintenance"
	icon_state = "upperaftmaint"

/area/station/maintenance/aft/greater //use greater variants of area definitions for when the station has two different sections of maintenance on the same z-level. Can stand alone without "lesser". This one means that this goes more fore/north than the "lesser" maintenance area.
	name = "Greater Aft Maintenance"
	icon_state = "greateraftmaint"

/area/station/maintenance/aft/lesser //use lesser variants of area definitions for when the station has two different sections of maintenance on the same z-level in conjunction with "greater" (just because it follows better). This one means that this goes more aft/south than the "greater" maintenance area.
	name = "Lesser Aft Maintenance"
	icon_state = "lesseraftmaint"

/area/station/maintenance/central
	name = "Central Maintenance"
	icon_state = "centralmaint"

/area/station/maintenance/central/greater
	name = "Greater Central Maintenance"
	icon_state = "greatercentralmaint"

/area/station/maintenance/central/lesser
	name = "Lesser Central Maintenance"
	icon_state = "lessercentralmaint"

/area/station/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "foremaint"

/area/station/maintenance/fore/greater
	name = "Greater Fore Maintenance"
	icon_state = "greaterforemaint"

/area/station/maintenance/fore/lesser
	name = "Lesser Fore Maintenance"
	icon_state = "lesserforemaint"

/area/station/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "starboardmaint"

/area/station/maintenance/starboard/upper
	name = "Upper Starboard Maintenance"
	icon_state = "upperstarboardmaint"

/area/station/maintenance/starboard/central
	name = "Central Starboard Maintenance"
	icon_state = "centralstarboardmaint"

/area/station/maintenance/starboard/greater
	name = "Greater Starboard Maintenance"
	icon_state = "greaterstarboardmaint"

/area/station/maintenance/starboard/lesser
	name = "Lesser Starboard Maintenance"
	icon_state = "lesserstarboardmaint"

/area/station/maintenance/starboard/aft
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/starboard/fore
	name = "Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/port
	name = "Port Maintenance"
	icon_state = "portmaint"

/area/station/maintenance/port/central
	name = "Central Port Maintenance"
	icon_state = "centralportmaint"

/area/station/maintenance/port/greater
	name = "Greater Port Maintenance"
	icon_state = "greaterportmaint"

/area/station/maintenance/port/lesser
	name = "Lesser Port Maintenance"
	icon_state = "lesserportmaint"

/area/station/maintenance/port/aft
	name = "Aft Port Maintenance"
	icon_state = "apmaint"

/area/station/maintenance/port/fore
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

//Maintenance - Discrete Areas
/area/station/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/station/maintenance/disposal/incinerator
	name = "\improper Incinerator"
	icon_state = "incinerator"
	disable_air_alarm_automation = TRUE

//Radiation storm shelter
/area/station/maintenance/radshelter
	name = "\improper Radstorm Shelter"
	icon_state = "radstorm_shelter"

/area/station/maintenance/radshelter/medical
	name = "\improper Medical Radstorm Shelter"

/area/station/maintenance/radshelter/sec
	name = "\improper Security Radstorm Shelter"

/area/station/maintenance/radshelter/service
	name = "\improper Service Radstorm Shelter"

/area/station/maintenance/radshelter/civil
	name = "\improper Civilian Radstorm Shelter"

/area/station/maintenance/radshelter/sci
	name = "\improper Science Radstorm Shelter"

/area/station/maintenance/radshelter/cargo
	name = "\improper Cargo Radstorm Shelter"


//Hallway

/area/station/hallway
	icon_state = "hall"
	sound_environment = SOUND_AREA_STANDARD_STATION
	lights_always_start_on = TRUE
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8

/area/station/hallway/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/hallway/primary
	name = "\improper Primary Hallway"
	icon_state = "primaryhall"

/area/station/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "afthall"

/area/station/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "forehall"

/area/station/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "starboardhall"

/area/station/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "porthall"

/area/station/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/primary/central/fore
	name = "\improper Fore Central Primary Hallway"
	icon_state = "hallCF"

/area/station/hallway/primary/central/aft
	name = "\improper Aft Central Primary Hallway"
	icon_state = "hallCA"

/area/station/hallway/primary/upper
	name = "\improper Upper Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/primary/upper/aft
	name = "\improper Upper Aft Primary Hallway"
	icon_state = "afthall"

/area/station/hallway/primary/upper/fore
	name = "\improper Upper Fore Primary Hallway"
	icon_state = "forehall"

/area/station/hallway/primary/upper/starboard
	name = "\improper Upper Starboard Primary Hallway"
	icon_state = "starboardhall"

/area/station/hallway/primary/upper/port
	name = "\improper Upper Port Primary Hallway"
	icon_state = "porthall"

/area/station/hallway/primary/upper/central
	name = "\improper Upper Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/secondary // This shouldn't be used, but it gives an icon for the enviornment tree in the map editor
	icon_state = "secondaryhall"

/area/station/hallway/secondary/command
	name = "\improper Command Hallway"
	icon_state = "bridge_hallway"

/area/station/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/station/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/station/hallway/secondary/exit/departure_lounge
	name = "\improper Departure Lounge"
	icon_state = "escape_lounge"

/area/station/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/station/hallway/secondary/service
	name = "\improper Service Hallway"
	icon_state = "hall_service"

/area/station/hallway/secondary/law
	name = "Law Hallway"
	icon_state = "security"

/area/station/hallway/secondary/asteroid
	name = "Asteroid Hallway"
	icon_state = "construction"

//Command

/area/station/command
	name = "Command"
	icon_state = "command"
	ambientsounds = list('sound/ambience/signal.ogg')

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION

	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

	color_correction = /datum/client_colour/area_color/cold_ish
	camera_networks = list(CAMERA_NETWORK_PRIVATE)

/area/station/command/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/station/command/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/meeting_room/council
	name = "\improper Council Chamber"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_showroom
	name = "\improper Corporate Showroom"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/heads_quarters
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = FALSE
	camera_networks = list(CAMERA_NETWORK_PRIVATE)

/area/station/command/heads_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/station/command/heads_quarters/captain/private
	name = "\improper Captain's Quarters"
	icon_state = "captain_private"

/area/station/command/heads_quarters/chief
	name = "\improper Chief Engineer's Office"
	icon_state = "ce_office"

/area/station/command/heads_quarters/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/station/command/heads_quarters/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "hop_office"
	color_correction = /datum/client_colour/area_color/cold_ish

/area/station/command/heads_quarters/hos
	name = "\improper Head of Security's Office"
	icon_state = "hos_office"

/area/station/command/heads_quarters/rd
	name = "\improper Research Director's Office"
	icon_state = "rd_office"

//Command - Teleporters

/area/station/command/teleporter
	name = "\improper Teleporter Room"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_RESEARCH)

/area/station/command/gateway
	name = "\improper Gateway"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_RESEARCH)

//Commons

/area/station/commons
	name = "\improper Crew Facilities"
	area_flags = HIDDEN_STASH_LOCATION | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION
	lights_always_start_on = TRUE
	color_correction = /datum/client_colour/area_color/warm_ish
	camera_networks = list(CAMERA_NETWORK_STATION)

/area/station/commons/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/commons/dorms
	name = "\improper Dormitories"
	icon_state = "dorms"
	mood_bonus = 3
	mood_message = span_nicegreen("There's no place like the dorms!\n")

/area/station/commons/dorms/barracks
	name = "\improper Sleep Barracks"

/area/station/commons/dorms/barracks/male
	name = "\improper Male Sleep Barracks"
	icon_state = "dorms_male"

/area/station/commons/dorms/barracks/female
	name = "\improper Female Sleep Barracks"
	icon_state = "dorms_female"

/area/station/commons/dorms/laundry
	name = "\improper Laundry Room"
	icon_state = "laundry_room"

/area/station/commons/dorms/upper
	name = "\improper Upper Dorms"

/area/station/commons/cryopods
	name = "\improper Cryopod Room"
	icon_state = "cryopod"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"

/area/station/commons/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/commons/toilet/auxiliary
	name = "\improper Auxiliary Restrooms"
	icon_state = "toilet"

/area/station/commons/toilet/locker
	name = "\improper Locker Toilets"
	icon_state = "toilet"

/area/station/commons/toilet/restrooms
	name = "\improper Restrooms"
	icon_state = "toilet"

/area/station/commons/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/station/commons/lounge
	name = "\improper Bar Lounge"
	icon_state = "lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/commons/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/station/commons/fitness/locker_room
	name = "\improper Unisex Locker Room"
	icon_state = "fitness"

/area/station/commons/fitness/locker_room/male
	name = "\improper Male Locker Room"
	icon_state = "locker_male"

/area/station/commons/fitness/locker_room/female
	name = "\improper Female Locker Room"
	icon_state = "locker_female"

/area/station/commons/fitness/recreation
	name = "\improper Recreation Area"
	icon_state = "fitness"

/area/station/commons/fitness/recreation/upper
	name = "\improper Upper Recreation Area"
	icon_state = "fitness"

/area/station/commons/fitness/recreation/entertainment
	name = "\improper Entertainment Center"
	icon_state = "entertainment"

/area/station/commons/park
	name = "\improper Recreational Park"
	icon_state = "fitness"
	lighting_colour_bulb = "#80aae9"
	lighting_colour_tube = "#80aae9"
	lighting_brightness_bulb = 9

// Commons - Vacant Rooms

/area/station/commons/vacant_room
	name = "\improper Vacant Room"
	icon_state = "vacant_room"
	ambience_index = AMBIENCE_MAINT

/area/station/commons/vacant_room/office
	name = "\improper Vacant Office"
	icon_state = "vacant_office"

/area/station/commons/vacant_room/commissary
	name = "\improper Vacant Commissary"
	icon_state = "vacant_commissary"

/area/station/commons/vacant_room/commissary/commissary1
	name = "Vacant Commissary #1"
	icon_state = "vacant_commissary"

/area/station/commons/vacant_room/commissary/commissary2
	name = "Vacant Commissary #2"
	icon_state = "vacant_commissary"

/area/station/commons/vacant_room/commissary/commissaryFood
	name = "Vacant Food Stall Commissary"
	icon_state = "vacant_commissary"

/area/station/commons/vacant_room/commissary/commissaryRandom
	name = "Unique Commissary"
	icon_state = "vacant_commissary"

//Commons - Storage
/area/station/commons/storage
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE
	lights_always_start_on = TRUE
	color_correction = /datum/client_colour/area_color/warm_yellow

/area/station/commons/storage/tools
	name = "\improper Auxiliary Tool Storage"
	icon_state = "tool_storage"

/area/station/commons/storage/primary
	name = "\improper Primary Tool Storage"
	icon_state = "primary_storage"

/area/station/commons/storage/primary/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/commons/storage/art
	name = "\improper Art Supply Storage"
	icon_state = "art_storage"

/area/station/commons/storage/emergency/starboard
	name = "\improper Starboard Emergency Storage"
	icon_state = "emergency_storage"

/area/station/commons/storage/emergency/port
	name = "\improper Port Emergency Storage"
	icon_state = "emergency_storage"

/area/station/commons/storage/mining
	name = "\improper Public Mining Storage"
	icon_state = "mining_storage"

//Service

/area/station/service
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_NONE

/area/station/service/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"
	color_correction = /datum/client_colour/area_color/warm_ish

/area/station/service/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"
	lights_always_start_on = FALSE
	color_correction = /datum/client_colour/area_color/cold_ish

/area/station/service/kitchen/coldroom
	name = "\improper Kitchen Cold Room"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	color_correction = /datum/client_colour/area_color/cold

/area/station/service/kitchen/diner
	name = "\improper Diner"
	icon_state = "diner"

/area/station/service/kitchen/abandoned
	name = "\improper Abandoned Kitchen"
	icon_state = "abandoned_kitchen"

/area/station/service/bar
	name = "\improper Bar"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = span_nicegreen("I love being in the bar!\n")
	lights_always_start_on = TRUE
	lighting_colour_tube = "#fff4d6"
	lighting_colour_bulb = "#ffebc1"
	sound_environment = SOUND_AREA_WOODFLOOR
	color_correction = /datum/client_colour/area_color/warm_ish

/area/station/service/bar/mood_check(mob/living/carbon/subject)
	if(istype(subject) && HAS_TRAIT(subject, TRAIT_LIGHT_DRINKER))
		return FALSE
	return ..()

/area/station/service/bar/lounge
	name = "Bar Lounge"
	icon_state = "lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/station/service/bar/atrium
	name = "\improper Atrium"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/electronic_marketing_den
	name = "\improper Electronic Marketing Den"
	icon_state = "abandoned_marketing_den"

/area/station/service/abandoned_gambling_den
	name = "\improper Abandoned Gambling Den"
	icon_state = "abandoned_gambling_den"

/area/station/service/abandoned_gambling_den/gaming
	name = "\improper Abandoned Gaming Den"
	icon_state = "abandoned_gaming_den"

/area/station/service/barbershop
	name = "\improper Barbershop"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/station/service/theater
	name = "\improper Theater"
	icon_state = "theatre"
	sound_environment = SOUND_AREA_WOODFLOOR
	color_correction = /datum/client_colour/area_color/clown

/area/station/service/theater/backstage
	name = "\improper Backstage"
	icon_state = "theater_back"
	sound_environment = SOUND_AREA_WOODFLOOR
	lights_always_start_on = FALSE

/area/station/service/theater/abandoned
	name = "\improper Abandoned Theater"
	icon_state = "theater"
	lights_always_start_on = FALSE

/area/station/service/library
	name = "\improper Library"
	icon_state = "library"
	area_flags = HIDDEN_STASH_LOCATION | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	color_correction = /datum/client_colour/area_color/warm_ish

/area/station/service/library/lounge
	name = "\improper Library Lounge"
	icon_state = "library_lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/library/artgallery
	name = "\improper  Art Gallery"
	icon_state = "library_gallery"

/area/station/service/library/private
	name = "\improper Library Private Study"
	icon_state = "library_gallery_private"

/area/station/service/library/upper
	name = "\improper Library Upper Floor"
	icon_state = "library"

/area/station/service/library/printer
	name = "\improper Library Printer Room"
	icon_state = "library"

/area/station/service/library/abandoned
	name = "\improper Abandoned Library"
	icon_state = "abandoned_library"

/area/station/service/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	flags_1 = NONE
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The consecration here prevents you from warping in."
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/service/chapel/monastery
	name = "\improper Monastery"

/area/station/service/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/station/service/chapel/asteroid
	name = "\improper Chapel Asteroid"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/station/service/chapel/asteroid/monastery
	name = "\improper Monastery Asteroid"

/area/station/service/chapel/dock
	name = "\improper Chapel Dock"
	icon_state = "construction"

/area/station/service/chapel/storage
	name = "\improper Chapel Storage"
	icon_state = "chapelstorage"

/area/station/service/chapel/funeral
	name = "\improper Chapel Funeral Room"
	icon_state = "chapelfuneral"

/area/station/service/lawoffice
	name = "\improper Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/service/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED | UNIQUE_AREA
	mood_bonus = -1
	mood_message = span_warning("It feels dirty in here!\n")
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	color_correction = /datum/client_colour/area_color/cold_ish

/area/station/service/hydroponics/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/service/hydroponics/upper
	name = "Upper Hydroponics"
	icon_state = "hydro"

/area/station/service/hydroponics/garden
	name = "Garden"
	icon_state = "garden"
	mood_bonus = 2
	mood_message = span_nicegreen("It's so peaceful in here!\n")

/area/station/service/hydroponics/garden/abandoned
	name = "\improper Abandoned Garden"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/hydroponics/garden/monastery
	name = "\improper Monastery Garden"
	icon_state = "hydro"

//Engineering

/area/station/engineering
	icon_state = "engie"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	lighting_colour_tube = "#ffce93"
	lighting_colour_bulb = "#ffbc6f"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	color_correction = /datum/client_colour/area_color/warm_yellow
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_ENGINEERING)

/area/station/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"

/area/station/engineering/main
	name = "Engineering"
	icon_state = "engine"

/area/station/engineering/main/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/engineering/hallway
	name = "Engineering Hallway"
	icon_state = "engine_hallway"

/area/station/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/station/engineering/atmos/upper
	name = "Upper Atmospherics"

/area/station/engineering/atmos/project
	name = "\improper Atmospherics Project Room"
	icon_state = "atmos_projectroom"

/area/station/engineering/atmos/pumproom
	name = "\improper Atmospherics Pumping Room"
	icon_state = "atmos_pump_room"

/area/station/engineering/atmos/mix
	name = "\improper Atmospherics Mixing Room"
	icon_state = "atmos_mix"

/area/station/engineering/atmos/storage
	name = "\improper Atmospherics Storage Room"
	icon_state = "atmos_storage"

/area/station/engineering/atmos/storage/gas
	name = "\improper Atmospherics Gas Storage"
	icon_state = "atmos_storage_gas"

/area/station/engineering/atmos/office
	name = "\improper Atmospherics Office"
	icon_state = "atmos_office"

/area/station/engineering/atmos/hfr_room
	name = "\improper Atmospherics HFR Room"
	icon_state = "atmos_HFR"

/area/station/engineering/atmospherics_engine
	name = "\improper Atmospherics Engine"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	camera_networks = list(CAMERA_NETWORK_ENGINEERING)
	disable_air_alarm_automation = TRUE

/area/station/engineering/lobby
	name = "\improper Engineering Lobby"
	icon_state = "engi_lobby"

/area/station/engineering/supermatter
	name = "\improper Supermatter Engine"
	icon_state = "engine_sm"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	camera_networks = list(CAMERA_NETWORK_ENGINEERING)
	disable_air_alarm_automation = TRUE
	//Supermatter chamber always has direct power.
	//requires_power = FALSE

/area/station/engineering/supermatter/room
	name = "\improper Supermatter Engine Room"
	icon_state = "engine_sm_room"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	//requires_power = TRUE

/area/station/engineering/supermatter/room/upper
	name = "\improper Upper Supermatter Engine Room"
	icon_state = "engine_sm_room_upper"

/area/station/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engine_foyer"
	mood_bonus = 2
	mood_message = span_nicegreen("Ahhh, time to take a break.\n")
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/gravity_generator
	name = "\improper Gravity Generator Room"
	icon_state = "grav_gen"
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The gravitons generated here could throw off your warp's destination and possibly throw you into deep space."
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	camera_networks = list(CAMERA_NETWORK_ENGINEERING)
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage
	name = "\improper Engineering Storage"
	icon_state = "engine_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage_shared
	name = "Shared Engineering Storage"
	icon_state = "engine_storage_shared"

/area/station/engineering/transit_tube
	name = "\improper Transit Tube"
	icon_state = "transit_tube"

/area/station/engineering/storage/tech
	name = "Technical Storage"
	icon_state = "tech_storage"

/area/station/engineering/storage/tcomms
	name = "Telecomms Storage"
	icon_state = "tcom"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	camera_networks = list(CAMERA_NETWORK_ENGINEERING, CAMERA_NETWORK_TCOMMS)

//Engineering - Construction

/area/station/construction
	name = "\improper Construction Area"
	icon_state = "construction"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_NONE
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_ENGINEERING)

/area/station/construction/mining/aux_base
	name = "Auxiliary Base Construction"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	camera_networks = list(CAMERA_NETWORK_AUXBASE)

/area/station/construction/storage_wing
	name = "\improper Storage Wing"
	icon_state = "storage_wing"

//Solars

/area/station/solars
	requires_power = FALSE
	//always_unpowered = TRUE
	area_flags = UNIQUE_AREA | NO_GRAVITY
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	sound_environment = SOUND_AREA_SPACE
	default_gravity = ZERO_GRAVITY

/area/station/solars/fore
	name = "\improper Fore Solar Array"
	icon_state = "panelsF"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/solars/aft
	name = "\improper Aft Solar Array"
	icon_state = "panelsAF"

/area/station/solars/aux/port
	name = "\improper Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/station/solars/aux/starboard
	name = "\improper Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/station/solars/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "panelsS"

/area/station/solars/starboard/aft
	name = "\improper Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/station/solars/starboard/fore
	name = "\improper Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/station/solars/port
	name = "\improper Port Solar Array"
	icon_state = "panelsP"

/area/station/solars/port/aft
	name = "\improper Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/station/solars/port/fore
	name = "\improper Port Bow Solar Array"
	icon_state = "panelsFP"

/area/station/solars/aisat
	name = "\improper AI Satellite Solars"
	icon_state = "panelsAI"


//Solar Maint

/area/station/maintenance/solars
	name = "Solar Maintenance"
	icon_state = "yellow"
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_ENGINEERING)

/area/station/maintenance/solars/port
	name = "Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/station/maintenance/solars/port/aft
	name = "Port Quarter Solar Maintenance"
	icon_state = "SolarcontrolAP"

/area/station/maintenance/solars/port/fore
	name = "Port Bow Solar Maintenance"
	icon_state = "SolarcontrolFP"

/area/station/maintenance/solars/starboard
	name = "Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/station/maintenance/solars/starboard/aft
	name = "Starboard Quarter Solar Maintenance"
	icon_state = "SolarcontrolAS"

/area/station/maintenance/solars/starboard/fore
	name = "Starboard Bow Solar Maintenance"
	icon_state = "SolarcontrolFS"

//MedBay

/area/station/medical
	name = "Medical"
	icon_state = "medbay"
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	ambience_index = AMBIENCE_MEDICAL
	sound_environment = SOUND_AREA_STANDARD_STATION
	mood_bonus = 2
	mood_message = span_nicegreen("I feel safe in here!\n")
	lighting_colour_tube = "#e7f8ff"
	lighting_colour_bulb = "#d5f2ff"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE
	color_correction = /datum/client_colour/area_color/cold_ish
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_MEDICAL)

/area/station/medical/abandoned
	name = "\improper Abandoned Medbay"
	icon_state = "abandoned_medbay"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/medbay/balcony
	name = "Medbay Balcony"
	icon_state = "medbay"

/area/station/medical/medbay/central
	name = "Medbay Central"
	icon_state = "med_central"

/area/station/medical/medbay/lobby
	name = "\improper Medbay Lobby"
	icon_state = "med_lobby"

//Medbay is a large area, these additional areas help level out APC load.

/area/station/medical/medbay/aft
	name = "Medbay Aft"
	icon_state = "med_aft"

/area/station/medical/storage
	name = "Medbay Storage"
	icon_state = "med_storage"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/medical/paramedic
	name = "Paramedic Dispatch"
	icon_state = "paramedic"

/area/station/medical/office
	name = "\improper Medical Office"
	icon_state = "med_office"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/medical/break_room
	name = "\improper Medical Break Room"
	icon_state = "med_break"

/area/station/medical/coldroom
	name = "\improper Medical Cold Room"
	icon_state = "kitchen_cold"

/area/station/medical/patients_rooms
	name = "\improper Patients' Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms/room_a
	name = "Patient Room A"
	icon_state = "patients"

/area/station/medical/patients_rooms/room_b
	name = "Patient Room B"
	icon_state = "patients"

/area/station/medical/patients_rooms/room_c
	name = "Patient Room C"
	icon_state = "patients"

/area/station/medical/virology
	name = "Virology"
	icon_state = "virology"
	ambience_index = AMBIENCE_VIROLOGY
	flags_1 = NONE
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -2
	mood_message = span_warning("It smells like death in here!\n")
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/station/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/medical/chemistry/upper
	name = "Upper Chemistry"
	icon_state = "chem"

/area/station/medical/pharmacy
	name = "\improper Pharmacy"
	icon_state = "pharmacy"

/area/station/medical/surgery
	name = "\improper Operating Room"
	icon_state = "surgery"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/medical/surgery/fore
	name = "\improper Fore Operating Room"
	icon_state = "foresurgery"

/area/station/medical/surgery/aft
	name = "\improper Aft Operating Room"
	icon_state = "aftsurgery"

/area/station/medical/surgery/theatre
	name = "\improper Grand Surgery Theatre"
	icon_state = "surgerytheatre"

/area/station/medical/booth
	name = "Medical Booth"

/area/station/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/station/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/medical/genetics/cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/station/medical/treatment_center
	name = "\improper Medbay Treatment Center"
	icon_state = "exam_room"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

//Security
///When adding a new area to the security areas, make sure to add it to /datum/bounty/item/security/paperwork as well!

/area/station/security
	name = "Security"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_AREA_STANDARD_STATION
	lighting_colour_tube = "#ffeee2"
	lighting_colour_bulb = "#ffdfca"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	color_correction = /datum/client_colour/area_color/warm_ish

/area/station/security/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/security/office
	name = "\improper Security Office"
	icon_state = "security"

/area/station/security/lockers
	name = "\improper Security Locker Room"
	icon_state = "securitylockerroom"

/area/station/security/brig
	name = "\improper Brig"
	icon_state = "brig"
	mood_bonus = -3
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN,JOB_NAME_SECURITYOFFICER,JOB_NAME_BRIGPHYSICIAN,JOB_NAME_DETECTIVE)
	mood_job_reverse = TRUE

	mood_message = span_warning("I hate cramped brig cells.\n")

/area/station/security/brig/dock
	name = "\improper Brig Dock"

/area/station/security/medical
	name = "\improper Security Medical"
	icon_state = "security_medical"

/area/station/security/brig/upper
	name = "\improper Brig Overlook"
	icon_state = "upperbrig"

/area/station/security/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_COURT)

/area/station/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"
	mood_bonus = -4
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN, JOB_NAME_SECURITYOFFICER)  // JUSTICE!
	mood_job_reverse = TRUE
	mood_message = span_warning("I'm trapped here with little hope of escape!\n")
	camera_networks = list(CAMERA_NETWORK_PRISON)

//Rad proof
/area/station/security/prison/toilet
	name = "\improper Prison Toilet"
	icon_state = "sec_prison_safe"

// Rad proof
/area/station/security/prison/safe
	name = "\improper Prison Wing Cells"
	icon_state = "sec_prison_safe"

/area/station/security/prison/upper
	name = "\improper Upper Prison Wing"
	icon_state = "prison_upper"

/area/station/security/prison/visit
	name = "\improper Prison Visitation Area"
	icon_state = "prison_visit"

/area/station/security/prison/rec
	name = "\improper Prison Rec Room"
	icon_state = "prison_rec"

/area/station/security/prison/mess
	name = "\improper Prison Mess Hall"
	icon_state = "prison_mess"

/area/station/security/prison/work
	name = "\improper Prison Work Room"
	icon_state = "prison_work"

/area/station/security/prison/shower
	name = "\improper Prison Shower"
	icon_state = "prison_shower"

/area/station/security/prison/workout
	name = "\improper Prison Gym"
	icon_state = "prison_workout"

/area/station/security/prison/garden
	name = "\improper Prison Garden"
	icon_state = "prison_garden"

/area/station/security/processing
	name = "\improper Labor Shuttle Dock"
	icon_state = "sec_processing"
	camera_networks = list(CAMERA_NETWORK_PRISON, CAMERA_NETWORK_LABOR)

/area/station/security/processing/cremation
	name = "\improper Security Crematorium"
	icon_state = "sec_cremation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/interrogation
	name = "\improper Interrogation Room"
	icon_state = "interrogation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/interrogation/Exited(atom/movable/a, atom/oldloc)
	..()
	if (!isliving(a))
		return

	var/mob/living/living_a = a
	if(!(HAS_TRAIT(living_a, TRAIT_NOIR)))
		return

	REMOVE_TRAIT(living_a, TRAIT_NOIR, TRAIT_GENERIC)
	if(ishuman(a))
		var/mob/living/carbon/human/human_a = a
		if (human_a.has_quirk(/datum/quirk/monochromatic))
			return

	living_a.remove_client_colour(/datum/client_colour/monochrome)

/area/station/security/warden
	name = "Brig Control"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	camera_networks = list(CAMERA_NETWORK_PRISON)

/area/station/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg','sound/ambience/ambidet3.ogg','sound/ambience/ambidet4.ogg')

/area/station/security/detectives_office/Exited(atom/movable/a, atom/oldloc)
	..()
	if (!isliving(a))
		return

	var/mob/living/living_a = a
	if(!(HAS_TRAIT(living_a, TRAIT_NOIR)))
		return

	REMOVE_TRAIT(living_a, TRAIT_NOIR, TRAIT_GENERIC)
	if(ishuman(a))
		var/mob/living/carbon/human/human_a = a
		if (human_a.has_quirk(/datum/quirk/monochromatic))
			return

	living_a.remove_client_colour(/datum/client_colour/monochrome)

/area/station/security/detectives_office/private_investigators_office
	name = "\improper Private Investigator's Office"
	icon_state = "investigate_office"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

/area/station/security/execution
	icon_state = "execution_room"
	mood_bonus = -5
	mood_message = span_warning("I feel a sense of impending doom.\n")

/area/station/security/execution/transfer
	name = "\improper Transfer Centre"
	icon_state = "sec_processing"

/area/station/security/execution/education
	name = "\improper Prisoner Education Chamber"

/area/station/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint"

/area/station/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

/area/station/security/checkpoint/escape
	icon_state = "checkpoint_esc"

/area/station/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint_supp"

/area/station/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint_engi"

/area/station/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint_med"

/area/station/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint_sci"

/area/station/security/checkpoint/science/research
	name = "Security Post - Research Division"
	icon_state = "checkpoint_res"

/area/station/security/checkpoint/customs
	name = "Customs"
	icon_state = "customs_point"

/area/station/security/checkpoint/customs/auxiliary
	icon_state = "customs_point_aux"

/area/station/security/checkpoint/customs/fore
	name = "Fore Customs"
	icon_state = "customs_point_fore"

/area/station/security/checkpoint/customs/aft
	name = "Aft Customs"
	icon_state = "customs_point_aft"

/area/station/security/prison/vip
	name = "VIP Prison Wing"
	icon_state = "sec_prison"

/area/station/security/prison/asteroid
	name = "Outer Asteroid Prison Wing"
	icon_state = "sec_prison"

/area/station/security/prison/asteroid/service
	name = "Outer Asteroid Prison Wing Services"
	icon_state = "sec_prison"

/area/station/security/prison/asteroid/arrival
	name = "Outer Asteroid Prison Wing Arrival"
	icon_state = "sec_prison"

/area/station/security/prison/asteroid/Abandoned
	name = "Outer Asteroid Prison Wing Abandoned maintenance"
	icon_state = "sec_prison"
	mood_bonus = -2
	mood_message = span_warning("This place gives me the creeps...\n")

/area/station/security/prison/asteroid/shielded
	name = "Outer Asteroid Prison Wing Shielded area"
	icon_state = "sec_prison"

//Cargo

/area/station/cargo
	name = "Quartermasters"
	icon_state = "quart"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE
	color_correction = /datum/client_colour/area_color/warm_yellow

/area/station/cargo/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/cargo/sorting
	name = "\improper Delivery Office"
	icon_state = "cargo_delivery"

/area/station/cargo/warehouse
	name = "\improper Warehouse"
	icon_state = "cargo_warehouse"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/cargo/warehouse/upper
	name = "\improper Upper Warehouse"

/area/station/cargo/drone_bay
	name = "\improper Drone Bay"
	icon_state = "cargo_drone"

/area/station/cargo/office
	name = "\improper Cargo Office"
	icon_state = "cargo_office"

/area/station/cargo/storage
	name = "\improper Cargo Bay"
	icon_state = "cargo_bay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/cargo/lobby
	name = "\improper Cargo Lobby"
	icon_state = "cargo_lobby"

/area/station/cargo/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quart_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/station/cargo/qm_bedroom
	name = "\improper Quartermaster's Bedroom"
	icon_state = "quart_private"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/station/cargo/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining_dock"

/area/station/cargo/miningdock/cafeteria
	name = "\improper Mining Cafeteria"
	icon_state = "mining_cafe"

/area/station/cargo/miningdock/oresilo
	name = "\improper Mining Ore Silo Storage"
	icon_state = "mining_silo"

/area/station/cargo/miningoffice
	name = "\improper Mining Office"
	icon_state = "mining"

/area/station/cargo/meeting_room
	name = "\improper Supply Meeting Room"
	icon_state = "quart_perch"

/area/station/cargo/exploration_prep
	name = "\improper Exploration Preparation Room"
	icon_state = "mining"

/area/station/cargo/exploration_dock
	name = "\improper Exploration Dock"
	icon_state = "mining"

//Science

/area/station/science
	name = "\improper Science Division"
	icon_state = "science"
	lighting_colour_tube = "#f0fbff"
	lighting_colour_bulb = "#e4f7ff"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	color_correction = /datum/client_colour/area_color/cold_ish
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_RESEARCH)

/area/station/science/lobby
	name = "\improper Science Lobby"
	icon_state = "science_lobby"

/area/station/science/lower
	name = "\improper Lower Science Division"
	icon_state = "lower_science"

/area/station/science/breakroom
	name = "\improper Science Break Room"
	icon_state = "science_breakroom"

/area/station/science/lab
	name = "Research and Development"
	icon_state = "research"

/area/station/science/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenobio"

/area/station/science/xenobiology/hallway
	name = "\improper Xenobiology Hallway"
	icon_state = "xenobio_hall"

/area/station/science/shuttle
	name = "Shuttle Construction"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"

/area/station/science/storage
	name = "Ordnance Storage"
	icon_state = "ord_storage"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/station/science/test_area
	name = "\improper Ordnance Test Area"
	icon_state = "ord_test"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | NO_GRAVITY | CULT_PERMITTED
	lights_always_start_on = TRUE
	always_unpowered = TRUE

/area/station/science/test_area/planet
	name = "Planetary Toxins Test Area"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/science/mixing
	name = "\improper Ordnance Mixing Lab"
	icon_state = "ord_mix"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/station/science/mixing/chamber
	name = "\improper Ordnance Mixing Chamber"
	icon_state = "ord_mix_chamber"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	disable_air_alarm_automation = TRUE

/area/station/science/mixing/hallway
	name = "\improper Ordnance Mixing Hallway"
	icon_state = "ord_mix_hallway"

/area/station/science/mixing/launch
	name = "\improper Ordnance Mixing Launch Site"
	icon_state = "ord_mix_launch"

/area/station/science/misc_lab
	name = "\improper Testing Lab"
	icon_state = "ord_misc"

/area/station/science/misc_lab/range
	name = "\improper Research Testing Range"
	icon_state = "ord_range"

/area/station/science/server
	name = "\improper Research Division Server Room"
	icon_state = "server"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/station/science/explab
	name = "\improper Experimentation Lab"
	icon_state = "exp_lab"

/area/station/science/robotics
	name = "Robotics"
	icon_state = "robotics"

/area/station/science/robotics/get_area_textures()
	return GLOB.turf_texture_hallway

/area/station/science/robotics/mechbay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/station/science/robotics/lab
	name = "\improper Robotics Lab"
	icon_state = "ass_line"

/area/station/science/research
	name = "\improper Research Division"
	icon_state = "science"

/area/station/science/research/abandoned
	name = "\improper Abandoned Research Lab"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/science/nanite
	name = "Nanite Lab"
	icon_state = "nanite_lab"

/area/station/science/shuttledock
	name = "Science Shuttle Dock"
	icon_state = "sci_dock"

// Telecommunications Satellite

/area/station/tcommsat
	icon_state = "tcomsatcham"
	ambientsounds = list(
		'sound/ambience/ambisin2.ogg',
		'sound/ambience/signal.ogg',
		'sound/ambience/signal.ogg',
		'sound/ambience/ambigen10.ogg',
		'sound/ambience/ambitech.ogg',
		'sound/ambience/ambitech2.ogg',
		'sound/ambience/ambitech3.ogg',
		'sound/ambience/ambimystery.ogg'
	)
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "For safety reasons, warping here is disallowed; the radio and bluespace noise could cause catastrophic results."
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	camera_networks = list(CAMERA_NETWORK_MINISAT, CAMERA_NETWORK_ENGINEERING, CAMERA_NETWORK_TCOMMS)

/area/station/tcommsat/computer
	name = "\improper Telecomms Control Room"
	icon_state = "tcomsatcomp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	mood_job_allowed = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER)
	mood_bonus = 2
	mood_message = span_nicegreen("It's good to see these in working order.\n")

/area/station/tcommsat/server
	name = "\improper Telecomms Server Room"
	icon_state = "tcomsatcham"

/area/station/tcommsat/server/upper
	name = "\improper Upper Telecomms Server Room"

/area/station/tcommsat/relay
	name = "\improper Telecommunications Relay"
	icon_state = "tcom_sat_cham"

//Telecommunications - On Station

/area/station/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"
	lighting_colour_tube = "#e2feff"
	lighting_colour_bulb = "#d5fcff"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = TRUE
	disable_air_alarm_automation = TRUE
	camera_networks = list(CAMERA_NETWORK_ENGINEERING)

/area/station/server
	name = "\improper Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = TRUE
	disable_air_alarm_automation = TRUE
	camera_networks = list(CAMERA_NETWORK_ENGINEERING)

//External Hull Access
/area/station/maintenance/external
	name = "\improper External Hull Access"
	icon_state = "amaint"

/area/station/maintenance/external/aft
	name = "\improper Aft External Hull Access"

/area/station/maintenance/external/port
	name = "\improper Port External Hull Access"

/area/station/maintenance/external/port/bow
	name = "\improper Port Bow External Hull Access"
