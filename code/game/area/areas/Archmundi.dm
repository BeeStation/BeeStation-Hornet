

//This file is mostly a copy of Space_Station_13_area.dm with the area pathing slightly altered to prevent unwanted interactions with the station areas
//To be used on the Archmundi/Ruin
//Halloween event asset

/area/archmundi
	has_gravity = STANDARD_GRAVITY //We're not changing space, nor do we intend to utilize the gravity generator, so permanent gravity is OK
	teleport_restriction = TELEPORT_ALLOW_NONE //Teleportation would be extremely problematic for this event
	ambientsounds = list('sound/ambience/ice_event/AHum1.ogg','sound/ambience/ice_event/AHum2.ogg','sound/ambience/ice_event/AHum3.ogg', \
	'sound/ambience/ice_event/AHum4.ogg',)
	rare_ambient_sounds = list('sound/ambience/ice_event/AWhisper1.ogg', 'sound/ambience/ice_event/AWhisper2.ogg', 'sound/ambience/ice_event/AWhisper3.ogg', \
	'sound/ambience/ice_event/AWhisper4.ogg', 'sound/ambience/ice_event/AWhisper5.ogg', 'sound/ambience/ice_event/AWhisper6.ogg')
	rare_ambient_sound_chance = 30
	min_ambience_cooldown = 60 SECONDS
	max_ambience_cooldown = 240 SECONDS


/area/archmundi/ai_monitored	//stub defined ai_monitored.dm

/area/archmundi/ai_monitored/turret_protected

//STATION13


//Unique

/area/archmundi/ritual_hall
	name = "ritual hall"
	icon_state = "iceland_shaded"
	always_unpowered = TRUE
	ambience_index = AMBIENCE_CREEPY
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	color_correction = /datum/client_colour/area_color/cold_ish
	mood_bonus = -3
	mood_message = "<span class='warning'>You know better than to linger here.\n</span>"
	mood_job_allowed = list(JOB_NAME_CHAPLAIN)
	mood_job_reverse = TRUE

/area/archmundi/ritual_site
	name = "ritual site"
	icon_state = "iceland_lavacave"
	always_unpowered = TRUE
	ambience_index = AMBIENCE_CREEPY
	color_correction = /datum/client_colour/area_color/cold_purple
	mood_bonus = -1 //As much as I want to make this a massive penalty - it would be unwise to debuff the crew's speed during the finale
	mood_message = "<span class='warning'>So *THIS* is what they were working towards...\n</span>"
	mood_job_allowed = list(JOB_NAME_CHAPLAIN)
	mood_job_reverse = TRUE



//Docking Areas

/area/archmundi/docking
	ambience_index = AMBIENCE_MAINT
	mood_bonus = -1
	mood_message = "<span class='warning'>You feel that you shouldn't stay here with such shuttle traffic...\n</span>"
	lighting_colour_tube = "#1c748a"
	lighting_colour_bulb = "#1c748a"
	lights_always_start_on = TRUE

/area/archmundi/docking/arrival
	name = "Arrival Docking Area (Archmundi)"
	icon_state = "arrivaldockarea"

/area/archmundi/docking/arrivalaux
	name = "Auxiliary Arrival Docking Area (Archmundi)"
	icon_state = "arrivalauxdockarea"

/area/archmundi/docking/bridge
	name = "Bridge Docking Area (Archmundi)"
	icon_state = "bridgedockarea"

//Dry Dock

/area/archmundi/drydock
	name = "Shuttle drydock (Archmundi)"
	icon_state = "drydock"
	ambience_index = AMBIENCE_MAINT
	lighting_colour_tube = "#1c748a"
	lighting_colour_bulb = "#1c748a"
	lights_always_start_on = TRUE

/area/archmundi/drydock/security
	name = "Security Shuttle drydock (Archmundi)"
	icon_state = "drydock_sec"

//Maintenance

/area/archmundi/maintenance
	ambience_index = AMBIENCE_MAINT
	ambient_buzz = 'sound/ambience/source_corridor2.ogg'
	ambient_buzz_vol = 20
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
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
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	mood_bonus = -1
	mood_message = "<span class='warning'>It's kind of cramped in here!\n</span>"
	// assistants are associated with maints, jani closet is in maints, engis have to go into maints often
	mood_job_allowed = list(JOB_NAME_ASSISTANT, JOB_NAME_JANITOR, JOB_NAME_STATIONENGINEER, JOB_NAME_CHIEFENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)
	mood_job_reverse = TRUE
	lighting_colour_tube = "#ffe5cb"
	lighting_colour_bulb = "#ffdbb4"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE
	lights_always_start_on = TRUE
	color_correction = /datum/client_colour/area_color/cold_ish

//Maintenance - Departmental

/area/archmundi/maintenance/department/chapel
	name = "Chapel Maintenance (Archmundi)"
	icon_state = "maint_chapel"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/maintenance/department/chapel/monastery
	name = "Monastery Maintenance (Archmundi)"
	icon_state = "maint_monastery"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/maintenance/department/crew_quarters/bar
	name = "Bar Maintenance (Archmundi)"
	icon_state = "maint_bar"
	sound_environment = SOUND_AREA_WOODFLOOR
	color_correction = /datum/client_colour/area_color/warm_ish

/area/archmundi/maintenance/department/crew_quarters/dorms
	name = "Dormitory Maintenance (Archmundi)"
	icon_state = "maint_dorms"

/area/archmundi/maintenance/department/eva
	name = "EVA Maintenance (Archmundi)"
	icon_state = "maint_eva"

/area/archmundi/maintenance/department/electrical
	name = "Electrical Maintenance (Archmundi)"
	icon_state = "maint_electrical"

/area/archmundi/maintenance/department/engine/atmos
	name = "Atmospherics Maintenance (Archmundi)"
	icon_state = "maint_atmos"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/maintenance/department/security
	name = "Security Maintenance (Archmundi)"
	icon_state = "maint_sec"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/maintenance/department/security/brig
	name = "Brig Maintenance (Archmundi)"
	icon_state = "maint_brig"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/maintenance/department/medical
	name = "Medbay Maintenance (Archmundi)"
	icon_state = "medbay_maint"

/area/archmundi/maintenance/department/medical/central
	name = "Central Medbay Maintenance (Archmundi)"
	icon_state = "medbay_maint_central"

/area/archmundi/maintenance/department/medical/morgue
	name = "Morgue Maintenance (Archmundi)"
	icon_state = "morgue_maint"

/area/archmundi/maintenance/department/science
	name = "Science Maintenance (Archmundi)"
	icon_state = "maint_sci"

/area/archmundi/maintenance/department/science/central
	name = "Central Science Maintenance (Archmundi)"
	icon_state = "maint_sci_central"

/area/archmundi/maintenance/department/cargo
	name = "Cargo Maintenance (Archmundi)"
	icon_state = "maint_cargo"

/area/archmundi/maintenance/department/bridge
	name = "Bridge Maintenance (Archmundi)"
	icon_state = "maint_bridge"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/maintenance/department/engine
	name = "Engineering Maintenance (Archmundi)"
	icon_state = "maint_engi"

/area/archmundi/maintenance/department/science/xenobiology
	name = "Xenobiology Maintenance (Archmundi)"
	icon_state = "xenomaint"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE


//Maintenance - Generic

/area/archmundi/maintenance/aft
	name = "Aft Maintenance (Archmundi)"
	icon_state = "aftmaint"

/area/archmundi/maintenance/aft/secondary
	name = "Aft Maintenance (Archmundi)"
	icon_state = "aftmaint"

/area/archmundi/maintenance/central
	name = "Central Maintenance (Archmundi)"
	icon_state = "centralmaint"

/area/archmundi/maintenance/central/secondary
	name = "Central Maintenance (Archmundi)"
	icon_state = "centralmaint"

/area/archmundi/maintenance/fore
	name = "Fore Maintenance (Archmundi)"
	icon_state = "foremaint"

/area/archmundi/maintenance/fore/secondary
	name = "Fore Maintenance (Archmundi)"
	icon_state = "foremaint"

/area/archmundi/maintenance/starboard
	name = "Starboard Maintenance (Archmundi)"
	icon_state = "starboardmaint"

/area/archmundi/maintenance/starboard/central
	name = "Central Starboard Maintenance (Archmundi)"
	icon_state = "starboardmaint"

/area/archmundi/maintenance/starboard/secondary
	name = "Secondary Starboard Maintenance (Archmundi)"
	icon_state = "starboardmaint"

/area/archmundi/maintenance/starboard/aft
	name = "Starboard Quarter Maintenance (Archmundi)"
	icon_state = "asmaint"

/area/archmundi/maintenance/starboard/aft/secondary
	name = "Secondary Starboard Quarter Maintenance (Archmundi)"
	icon_state = "asmaint"

/area/archmundi/maintenance/starboard/fore
	name = "Starboard Bow Maintenance (Archmundi)"
	icon_state = "fsmaint"

/area/archmundi/maintenance/port
	name = "Port Maintenance (Archmundi)"
	icon_state = "portmaint"

/area/archmundi/maintenance/port/central
	name = "Central Port Maintenance (Archmundi)"
	icon_state = "centralmaint"

/area/archmundi/maintenance/port/aft
	name = "Port Quarter Maintenance (Archmundi)"
	icon_state = "apmaint"

/area/archmundi/maintenance/port/fore
	name = "Port Bow Maintenance (Archmundi)"
	icon_state = "fpmaint"

/area/archmundi/maintenance/disposal
	name = "Waste Disposal (Archmundi)"
	icon_state = "disposal"

/area/archmundi/maintenance/disposal/incinerator
	name = "Incinerator (Archmundi)"
	icon_state = "incinerator"

//Maintenance - Upper

/area/archmundi/maintenance/upper/aft
	name = "Upper Aft Maintenance (Archmundi)"
	icon_state = "aftmaint"

/area/archmundi/maintenance/upper/aft/secondary
	name = "Upper Aft Maintenance (Archmundi)"
	icon_state = "aftmaint"

/area/archmundi/maintenance/upper/central
	name = "Upper Central Maintenance (Archmundi)"
	icon_state = "centralmaint"

/area/archmundi/maintenance/upper/central/secondary
	name = "Upper Central Maintenance (Archmundi)"
	icon_state = "centralmaint"

/area/archmundi/maintenance/upper/fore
	name = "Upper Fore Maintenance (Archmundi)"
	icon_state = "foremaint"

/area/archmundi/maintenance/upper/fore/secondary
	name = "Upper Fore Maintenance (Archmundi)"
	icon_state = "foremaint"

/area/archmundi/maintenance/upper/starboard
	name = "Upper Starboard Maintenance (Archmundi)"
	icon_state = "starboardmaint"

/area/archmundi/maintenance/upper/starboard/central
	name = "Upper Central Starboard Maintenance (Archmundi)"
	icon_state = "starboardmaint"

/area/archmundi/maintenance/upper/starboard/secondary
	name = "Upper Secondary Starboard Maintenance (Archmundi)"
	icon_state = "starboardmaint"

/area/archmundi/maintenance/upper/starboard/aft
	name = "Upper Starboard Quarter Maintenance (Archmundi)"
	icon_state = "asmaint"

/area/archmundi/maintenance/upper/starboard/aft/secondary
	name = "Upper Secondary Starboard Quarter Maintenance (Archmundi)"
	icon_state = "asmaint"

/area/archmundi/maintenance/upper/starboard/fore
	name = "Upper Starboard Bow Maintenance (Archmundi)"
	icon_state = "fsmaint"

/area/archmundi/maintenance/upper/port
	name = "Upper Port Maintenance (Archmundi)"
	icon_state = "pmaint"

/area/archmundi/maintenance/upper/port/central
	name = "Upper Central Port Maintenance (Archmundi)"
	icon_state = "centralmaint"

/area/archmundi/maintenance/upper/port/aft
	name = "Upper Port Quarter Maintenance (Archmundi)"
	icon_state = "apmaint"

/area/archmundi/maintenance/upper/port/fore
	name = "Upper Port Bow Maintenance (Archmundi)"
	icon_state = "fpmaint"


//Hallway
/area/archmundi/hallway

/area/archmundi/hallway
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_STANDARD_STATION
	lights_always_start_on = TRUE
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8

/area/archmundi/hallway/primary
	name = "Primary Hallway (Archmundi)"

/area/archmundi/hallway/primary/aft
	name = "Aft Primary Hallway (Archmundi)"
	icon_state = "hallA"

/area/archmundi/hallway/primary/fore
	name = "Fore Primary Hallway (Archmundi)"
	icon_state = "hallF"

/area/archmundi/hallway/primary/starboard
	name = "Starboard Primary Hallway (Archmundi)"
	icon_state = "hallS"

/area/archmundi/hallway/primary/port
	name = "Port Primary Hallway (Archmundi)"
	icon_state = "hallP"

/area/archmundi/hallway/primary/central
	name = "Central Primary Hallway (Archmundi)"
	icon_state = "hallC"

/area/archmundi/hallway/secondary/command
	name = "Command Hallway (Archmundi)"
	icon_state = "bridge_hallway"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/hallway/secondary/construction
	name = "Construction Area (Archmundi)"
	icon_state = "construction"

/area/archmundi/hallway/secondary/exit
	name = "Escape Shuttle Hallway (Archmundi)"
	icon_state = "escape"

/area/archmundi/hallway/secondary/exit/departure_lounge
	name = "Departure Lounge (Archmundi)"
	icon_state = "escape_lounge"

/area/archmundi/hallway/secondary/entry
	name = "Arrival Shuttle Hallway (Archmundi)"
	icon_state = "entry"

/area/archmundi/hallway/secondary/service
	name = "Service Hallway (Archmundi)"
	icon_state = "hall_service"

/area/archmundi/hallway/secondary/law
	name = "Law Hallway (Archmundi)"
	icon_state = "security"

/area/archmundi/hallway/secondary/asteroid
	name = "Asteroid Hallway (Archmundi)"
	icon_state = "construction"

/area/archmundi/hallway/upper/primary/aft
	name = "Upper Aft Primary Hallway (Archmundi)"
	icon_state = "hallA"

/area/archmundi/hallway/upper/primary/fore
	name = "Upper Fore Primary Hallway (Archmundi)"
	icon_state = "hallF"

/area/archmundi/hallway/upper/primary/starboard
	name = "Upper Starboard Primary Hallway (Archmundi)"
	icon_state = "hallS"

/area/archmundi/hallway/upper/primary/port
	name = "Upper Port Primary Hallway (Archmundi)"
	icon_state = "hallP"

/area/archmundi/hallway/upper/primary/central
	name = "Upper Central Primary Hallway (Archmundi)"
	icon_state = "hallC"

/area/archmundi/hallway/upper/secondary/command
	name = "Upper Command Hallway (Archmundi)"
	icon_state = "bridge_hallway"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/hallway/upper/secondary/construction
	name = "Upper Construction Area (Archmundi)"
	icon_state = "construction"

/area/archmundi/hallway/upper/secondary/exit
	name = "Upper Escape Shuttle Hallway (Archmundi)"
	icon_state = "escape"

/area/archmundi/hallway/upper/secondary/exit/departure_lounge
	name = "Upper Departure Lounge (Archmundi)"
	icon_state = "escape_lounge"

/area/archmundi/hallway/upper/secondary/entry
	name = "Upper Arrival Shuttle Hallway (Archmundi)"
	icon_state = "entry"

/area/archmundi/hallway/upper/secondary/service
	name = "Upper Service Hallway (Archmundi)"
	icon_state = "hall_service"

//Command

/area/archmundi/bridge
	name = "Bridge (Archmundi)"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION

	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

	color_correction = /datum/client_colour/area_color/cold_ish

/area/archmundi/bridge/meeting_room
	name = "Heads of Staff Meeting Room (Archmundi)"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/archmundi/bridge/meeting_room/council
	name = "Council Chamber (Archmundi)"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/archmundi/bridge/showroom/corporate
	name = "Corporate Showroom (Archmundi)"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/archmundi/crew_quarters
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/crew_quarters/heads/captain
	name = "Captain's Office (Archmundi)"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM
	lights_always_start_on = FALSE

/area/archmundi/crew_quarters/heads/captain/private
	name = "Captain's Quarters (Archmundi)"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM
	lights_always_start_on = FALSE

/area/archmundi/crew_quarters/heads/chief
	name = "Chief Engineer's Office (Archmundi)"
	icon_state = "ce_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = FALSE

/area/archmundi/crew_quarters/heads/cmo
	name = "Chief Medical Officer's Office (Archmundi)"
	icon_state = "cmo_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = FALSE

/area/archmundi/crew_quarters/heads/hop
	name = "Head of Personnel's Office (Archmundi)"
	icon_state = "hop_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = FALSE
	color_correction = /datum/client_colour/area_color/cold_ish

/area/archmundi/crew_quarters/heads/hos
	name = "Head of Security's Office (Archmundi)"
	icon_state = "hos_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = FALSE

/area/archmundi/crew_quarters/heads/hor
	name = "Research Director's Office (Archmundi)"
	icon_state = "rd_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = FALSE

/area/archmundi/comms
	name = "Communications Relay (Archmundi)"
	icon_state = "tcom_sat_cham"
	lighting_colour_tube = "#e2feff"
	lighting_colour_bulb = "#d5fcff"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = TRUE

/area/archmundi/server
	name = "Messaging Server Room (Archmundi)"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = TRUE

//Crew

/area/archmundi/crew_quarters
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION
	lights_always_start_on = TRUE
	color_correction = /datum/client_colour/area_color/warm_ish

/area/archmundi/crew_quarters/dorms
	name = "Dormitories (Archmundi)"
	icon_state = "dorms"
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>There's no place like the dorms!\n</span>"

/area/archmundi/commons
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/commons/dorms/barracks
	name = "Sleep Barracks (Archmundi)"

/area/archmundi/commons/dorms/barracks/male
	name = "Male Sleep Barracks (Archmundi)"
	icon_state = "dorms_male"

/area/archmundi/commons/dorms/barracks/female
	name = "Female Sleep Barracks (Archmundi)"
	icon_state = "dorms_female"

/area/archmundi/commons/dorms/laundry
	name = "Laundry Room (Archmundi)"
	icon_state = "laundry_room"

/area/archmundi/crew_quarters/dorms/upper
	name = "Upper Dorms (Archmundi)"

/area/archmundi/crew_quarters/cryopods
	name = "Cryopod Room (Archmundi)"
	icon_state = "cryopod"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"

/area/archmundi/crew_quarters/toilet
	name = "Dormitory Toilets (Archmundi)"
	icon_state = "toilet"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/archmundi/crew_quarters/toilet/auxiliary
	name = "Auxiliary Restrooms (Archmundi)"
	icon_state = "toilet"

/area/archmundi/crew_quarters/toilet/locker
	name = "Locker Toilets (Archmundi)"
	icon_state = "toilet"

/area/archmundi/crew_quarters/toilet/restrooms
	name = "Restrooms (Archmundi)"
	icon_state = "toilet"

/area/archmundi/crew_quarters/locker
	name = "Locker Room (Archmundi)"
	icon_state = "locker"

/area/archmundi/crew_quarters/lounge
	name = "Lounge (Archmundi)"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/archmundi/crew_quarters/fitness
	name = "Fitness Room (Archmundi)"
	icon_state = "fitness"

/area/archmundi/crew_quarters/fitness/locker_room
	name = "Unisex Locker Room (Archmundi)"
	icon_state = "fitness"

/area/archmundi/crew_quarters/fitness/recreation
	name = "Recreation Area (Archmundi)"
	icon_state = "fitness"

/area/archmundi/crew_quarters/fitness/recreation/upper
	name = "Upper Recreation Area (Archmundi)"
	icon_state = "fitness"

/area/archmundi/crew_quarters/park
	name = "Recreational Park (Archmundi)"
	icon_state = "fitness"
	lighting_colour_bulb = "#80aae9"
	lighting_colour_tube = "#80aae9"
	lighting_brightness_bulb = 9

/area/archmundi/crew_quarters/cafeteria
	name = "Cafeteria (Archmundi)"
	icon_state = "cafeteria"
	color_correction = /datum/client_colour/area_color/warm_ish

/area/archmundi/crew_quarters/kitchen
	name = "Kitchen (Archmundi)"
	icon_state = "kitchen"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"
	lights_always_start_on = FALSE
	color_correction = /datum/client_colour/area_color/cold_ish

/area/archmundi/crew_quarters/kitchen/coldroom
	name = "Kitchen Cold Room (Archmundi)"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	color_correction = /datum/client_colour/area_color/cold

/area/archmundi/crew_quarters/bar
	name = "Bar (Archmundi)"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "<span class='nicegreen'>I love being in the bar!\n</span>"
	lights_always_start_on = TRUE
	lighting_colour_tube = "#fff4d6"
	lighting_colour_bulb = "#ffebc1"
	sound_environment = SOUND_AREA_WOODFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE
	color_correction = /datum/client_colour/area_color/warm_ish

/area/archmundi/crew_quarters/bar/mood_check(mob/living/carbon/subject)
	if(istype(subject) && HAS_TRAIT(subject, TRAIT_LIGHT_DRINKER))
		return FALSE
	return ..()

/area/archmundi/crew_quarters/bar/lounge
	name = "Bar Lounge (Archmundi)"
	icon_state = "lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/archmundi/crew_quarters/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/archmundi/crew_quarters/bar/atrium
	name = "Atrium (Archmundi)"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/archmundi/crew_quarters/electronic_marketing_den
	name = "Electronic Marketing Den (Archmundi)"
	icon_state = "bar"

/area/archmundi/crew_quarters/abandoned_gambling_den
	name = "Abandoned Gambling Den (Archmundi)"
	icon_state = "abandoned_g_den"

/area/archmundi/crew_quarters/abandoned_gambling_den/secondary
	icon_state = "abandoned_g_den_2 (Archmundi)"

/area/archmundi/crew_quarters/theatre
	name = "Theatre (Archmundi)"
	icon_state = "theatre"
	sound_environment = SOUND_AREA_WOODFLOOR
	color_correction = /datum/client_colour/area_color/clown

/area/archmundi/crew_quarters/theatre/backstage
	name = "Backstage (Archmundi)"
	icon_state = "theatre_back"
	sound_environment = SOUND_AREA_WOODFLOOR
	lights_always_start_on = FALSE

/area/archmundi/crew_quarters/theatre/abandoned
	name = "Abandoned Theatre (Archmundi)"
	icon_state = "theatre"
	lights_always_start_on = FALSE

/area/archmundi/library
	name = "Library (Archmundi)"
	icon_state = "library"
	flags_1 = NONE
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE
	color_correction = /datum/client_colour/area_color/warm_ish

/area/archmundi/library/lounge
	name = "Library Lounge (Archmundi)"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	icon_state = "library"

/area/archmundi/library/abandoned
	name = "Abandoned Library (Archmundi)"
	icon_state = "library"
	flags_1 = NONE

/area/archmundi/chapel
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
	flags_1 = NONE
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The consecration here prevents you from warping in."
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/archmundi/chapel/main
	name = "Chapel (Archmundi)"

/area/archmundi/chapel/main/monastery
	name = "Monastery (Archmundi)"

/area/archmundi/chapel/office
	name = "Chapel Office (Archmundi)"
	icon_state = "chapeloffice"

/area/archmundi/chapel/asteroid
	name = "Chapel Asteroid (Archmundi)"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/archmundi/chapel/asteroid/monastery
	name = "Monastery Asteroid (Archmundi)"

/area/archmundi/chapel/dock
	name = "Chapel Dock (Archmundi)"
	icon_state = "construction"

/area/archmundi/lawoffice
	name = "Law Office (Archmundi)"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA


//Engineering

/area/archmundi/engine
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	lighting_colour_tube = "#ffce93"
	lighting_colour_bulb = "#ffbc6f"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	color_correction = /datum/client_colour/area_color/warm_yellow

/area/archmundi/engine/engine_smes
	name = "Engineering SMES (Archmundi)"
	icon_state = "engine_smes"

/area/archmundi/engine/engineering
	name = "Engineering (Archmundi)"
	icon_state = "engine"

/area/archmundi/engineering/hallway
	name = "Engineering Hallway (Archmundi)"
	icon_state = "engine_hallway"

/area/archmundi/engine/atmos
	name = "Atmospherics (Archmundi)"
	icon_state = "atmos"
	flags_1 = NONE

/area/archmundi/engine/atmospherics_engine
	name = "Atmospherics Engine (Archmundi)"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/engine/engine_room
	name = "Engine Room (Archmundi)"
	icon_state = "engine_sm"

/area/archmundi/engine/engine_room/external
	name = "Supermatter External Access (Archmundi)"
	icon_state = "engine_foyer"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/engine/supermatter
	name = "Supermatter Engine (Archmundi)"
	icon_state = "engine_sm_room"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/engine/break_room
	name = "Engineering Foyer (Archmundi)"
	icon_state = "engine_foyer"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>Ahhh, time to take a break.\n</span>"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/archmundi/engine/gravity_generator
	name = "Gravity Generator Room (Archmundi)"
	icon_state = "grav_gen"
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The gravitons generated here could throw off your warp's destination and possibly throw you into deep space."
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/engine/storage
	name = "Engineering Storage (Archmundi)"
	icon_state = "engine_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/archmundi/engine/storage_shared
	name = "Shared Engineering Storage (Archmundi)"
	icon_state = "engine_storage_shared"

/area/archmundi/engine/transit_tube
	name = "Transit Tube (Archmundi)"
	icon_state = "transit_tube"


//Solars

/area/archmundi/solar
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	area_flags = UNIQUE_AREA
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_SPACE

/area/archmundi/solar/fore
	name = "Fore Solar Array (Archmundi)"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/archmundi/solar/aft
	name = "Aft Solar Array (Archmundi)"
	icon_state = "yellow"

/area/archmundi/solar/aux/port
	name = "Port Bow Auxiliary Solar Array (Archmundi)"
	icon_state = "panelsA"

/area/archmundi/solar/aux/starboard
	name = "Starboard Bow Auxiliary Solar Array (Archmundi)"
	icon_state = "panelsA"

/area/archmundi/solar/starboard
	name = "Starboard Solar Array (Archmundi)"
	icon_state = "panelsS"

/area/archmundi/solar/starboard/aft
	name = "Starboard Quarter Solar Array (Archmundi)"
	icon_state = "panelsAS"

/area/archmundi/solar/starboard/fore
	name = "Starboard Bow Solar Array (Archmundi)"
	icon_state = "panelsFS"

/area/archmundi/solar/port
	name = "Port Solar Array (Archmundi)"
	icon_state = "panelsP"

/area/archmundi/solar/port/aft
	name = "Port Quarter Solar Array (Archmundi)"
	icon_state = "panelsAP"

/area/archmundi/solar/port/fore
	name = "Port Bow Solar Array (Archmundi)"
	icon_state = "panelsFP"



//Solar Maint

/area/archmundi/maintenance/solars
	name = "Solar Maintenance (Archmundi)"
	icon_state = "yellow"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/maintenance/solars/port
	name = "Port Solar Maintenance (Archmundi)"
	icon_state = "SolarcontrolP"

/area/archmundi/maintenance/solars/port/aft
	name = "Port Quarter Solar Maintenance (Archmundi)"
	icon_state = "SolarcontrolAP"

/area/archmundi/maintenance/solars/port/fore
	name = "Port Bow Solar Maintenance (Archmundi)"
	icon_state = "SolarcontrolFP"

/area/archmundi/maintenance/solars/starboard
	name = "Starboard Solar Maintenance (Archmundi)"
	icon_state = "SolarcontrolS"

/area/archmundi/maintenance/solars/starboard/aft
	name = "Starboard Quarter Solar Maintenance (Archmundi)"
	icon_state = "SolarcontrolAS"

/area/archmundi/maintenance/solars/starboard/fore
	name = "Starboard Bow Solar Maintenance (Archmundi)"
	icon_state = "SolarcontrolFS"

//Teleporter

/area/archmundi/teleporter
	name = "Teleporter Room (Archmundi)"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/gateway
	name = "Gateway (Archmundi)"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED

//MedBay

/area/archmundi/medical
	name = "Medical (Archmundi)"
	icon_state = "medbay"
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
	ambience_index = AMBIENCE_MEDICAL
	sound_environment = SOUND_AREA_STANDARD_STATION
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>I feel safe in here!\n</span>"
	lighting_colour_tube = "#e7f8ff"
	lighting_colour_bulb = "#d5f2ff"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE
	color_correction = /datum/client_colour/area_color/cold_ish

/area/archmundi/medical/medbay/zone2
	name = "Medbay (Archmundi)"
	icon_state = "medbay2"

/area/archmundi/medical/abandoned
	name = "Abandoned Medbay (Archmundi)"
	icon_state = "abandoned_medbay"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/archmundi/medical/medbay/balcony
	name = "Medbay Balcony (Archmundi)"
	icon_state = "medbay"

/area/archmundi/medical/medbay/central
	name = "Medbay Central (Archmundi)"
	icon_state = "med_central"

/area/archmundi/medical/medbay/lobby
	name = "Medbay Lobby (Archmundi)"
	icon_state = "med_lobby"

	//Medbay is a large area, these additional areas help level out APC load.

/area/archmundi/medical/medbay/aft
	name = "Medbay Aft (Archmundi)"
	icon_state = "med_aft"

/area/archmundi/medical/storage
	name = "Medbay Storage (Archmundi)"
	icon_state = "med_storage"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/medical/office
	name = "Medical Office (Archmundi)"
	icon_state = "med_office"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/medical/break_room
	name = "Medical Break Room (Archmundi)"
	icon_state = "med_break"

/area/archmundi/medical/patients_rooms
	name = "Patients' Rooms (Archmundi)"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/archmundi/medical/patients_rooms/room_a
	name = "Patient Room A (Archmundi)"
	icon_state = "patients"

/area/archmundi/medical/patients_rooms/room_b
	name = "Patient Room B (Archmundi)"
	icon_state = "patients"

/area/archmundi/medical/patients_rooms/room_c
	name = "Patient Room C (Archmundi)"
	icon_state = "patients"

/area/archmundi/medical/virology
	name = "Virology (Archmundi)"
	icon_state = "virology"
	ambience_index = AMBIENCE_VIROLOGY
	flags_1 = NONE
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/medical/morgue
	name = "Morgue (Archmundi)"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -2
	mood_message = "<span class='warning'>It smells like death in here!\n</span>"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED

/area/archmundi/medical/chemistry
	name = "Chemistry (Archmundi)"
	icon_state = "chem"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/medical/chemistry/upper
	name = "Upper Chemistry (Archmundi)"
	icon_state = "chem"

/area/archmundi/medical/apothecary
	name = "Apothecary (Archmundi)"
	icon_state = "apothecary"

/area/archmundi/medical/surgery
	name = "Surgery (Archmundi)"
	icon_state = "surgery"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/medical/surgery/aux
	name = "Auxillery Surgery (Archmundi)"
	icon_state = "surgery"

/area/archmundi/medical/cryo
	name = "Cryogenics (Archmundi)"
	icon_state = "cryo"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/medical/exam_room
	name = "Exam Room (Archmundi)"
	icon_state = "exam_room"

/area/archmundi/medical/genetics
	name = "Genetics Lab (Archmundi)"
	icon_state = "genetics"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

/area/archmundi/medical/genetics/cloning
	name = "Cloning Lab (Archmundi)"
	icon_state = "cloning"

/area/archmundi/medical/sleeper
	name = "Medbay Treatment Center (Archmundi)"
	icon_state = "exam_room"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA


//Security

/area/archmundi/security
	name = "Security (Archmundi)"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_AREA_STANDARD_STATION
	lighting_colour_tube = "#ffeee2"
	lighting_colour_bulb = "#ffdfca"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	color_correction = /datum/client_colour/area_color/warm_ish

/area/archmundi/security/main
	name = "Security Office (Archmundi)"
	icon_state = "security"

/area/archmundi/security/brig
	name = "Brig (Archmundi)"
	icon_state = "brig"
	mood_bonus = -3
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN,JOB_NAME_SECURITYOFFICER,JOB_NAME_BRIGPHYSICIAN,JOB_NAME_DETECTIVE)
	mood_job_reverse = TRUE

	mood_message = "<span class='warning'>I hate cramped brig cells.\n</span>"

/area/archmundi/security/courtroom
	name = "Courtroom (Archmundi)"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED

/area/archmundi/security/prison
	name = "Prison Wing (Archmundi)"
	icon_state = "sec_prison"
	mood_bonus = -4
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN, JOB_NAME_SECURITYOFFICER)  // JUSTICE!
	mood_job_reverse = TRUE
	mood_message = "<span class='warning'>I'm trapped here with little hope of escape!\n</span>"

/area/archmundi/security/prison/shielded
	name = "Prison Wing Shielded area (Archmundi)"
	icon_state = "sec_prison"

/area/archmundi/security/processing
	name = "Labor Shuttle Dock (Archmundi)"
	icon_state = "sec_prison"

/area/archmundi/security/processing/cremation
	name = "Security Crematorium (Archmundi)"
	icon_state = "sec_prison"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/archmundi/security/warden
	name = "Brig Control (Archmundi)"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/archmundi/security/detectives_office
	name = "Detective's Office (Archmundi)"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg','sound/ambience/ambidet3.ogg','sound/ambience/ambidet4.ogg')

/area/archmundi/security/detectives_office/private_investigators_office
	name = "Private Investigator's Office (Archmundi)"
	icon_state = "detective"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/archmundi/security/range
	name = "Firing Range (Archmundi)"
	icon_state = "firingrange"

/area/archmundi/security/execution
	icon_state = "execution_room (Archmundi)"
	mood_bonus = -5
	mood_message = "<span class='warning'>I feel a sense of impending doom.\n</span>"

/area/archmundi/security/execution/transfer
	name = "Transfer Centre (Archmundi)"

/area/archmundi/security/execution/education
	name = "Prisoner Education Chamber (Archmundi)"

/area/archmundi/security/nuke_storage
	name = "Vault (Archmundi)"
	icon_state = "nuke_storage"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/archmundi/ai_monitored/nuke_storage
	name = "Vault (Archmundi)"
	icon_state = "nuke_storage"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/archmundi/security/checkpoint
	name = "Security Checkpoint (Archmundi)"
	icon_state = "checkpoint"

/area/archmundi/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

/area/archmundi/security/checkpoint/escape
	icon_state = "checkpoint_esc"

/area/archmundi/security/checkpoint/supply
	name = "Security Post - Cargo Bay (Archmundi)"
	icon_state = "checkpoint_supp"

/area/archmundi/security/checkpoint/engineering
	name = "Security Post - Engineering (Archmundi)"
	icon_state = "checkpoint_engi"

/area/archmundi/security/checkpoint/medical
	name = "Security Post - Medbay (Archmundi)"
	icon_state = "checkpoint_med"

/area/archmundi/security/checkpoint/science
	name = "Security Post - Science (Archmundi)"
	icon_state = "checkpoint_sci"

/area/archmundi/security/checkpoint/science/research
	name = "Security Post - Research Division (Archmundi)"
	icon_state = "checkpoint_res"

/area/archmundi/security/checkpoint/customs
	name = "Customs (Archmundi)"
	icon_state = "customs_point"

/area/archmundi/security/checkpoint/customs/auxiliary
	icon_state = "customs_point_aux"

/area/archmundi/security/prison/vip
	name = "VIP Prison Wing (Archmundi)"
	icon_state = "sec_prison"

//Cargo

/area/archmundi/quartermaster
	name = "Quartermasters (Archmundi)"
	icon_state = "quart"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	color_correction = /datum/client_colour/area_color/warm_yellow

/area/archmundi/quartermaster/sorting
	name = "Delivery Office (Archmundi)"
	icon_state = "cargo_delivery"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/archmundi/quartermaster/warehouse
	name = "Warehouse (Archmundi)"
	icon_state = "cargo_warehouse"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/archmundi/quartermaster/office
	name = "Cargo Office (Archmundi)"
	icon_state = "cargo_office"

/area/archmundi/quartermaster/storage
	name = "Cargo Bay (Archmundi)"
	icon_state = "cargo_bay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/archmundi/cargo/lobby
	name = "\improper Cargo Lobby (Archmundi)"
	icon_state = "cargo_lobby"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	color_correction = /datum/client_colour/area_color/warm_yellow

/area/archmundi/quartermaster/qm
	name = "Quartermaster's Office (Archmundi)"
	icon_state = "quart_office"

/area/archmundi/quartermaster/qm_bedroom
	name = "Quartermaster's Bedroom (Archmundi)"
	icon_state = "quart_private"

/area/archmundi/quartermaster/miningdock
	name = "Mining Dock (Archmundi)"
	icon_state = "mining_dock"

/area/archmundi/quartermaster/miningoffice
	name = "Mining Office (Archmundi)"
	icon_state = "mining"

/area/archmundi/quartermaster/meeting_room
	name = "Supply Meeting Room (Archmundi)"
	icon_state = "quart_perch"

/area/archmundi/quartermaster/exploration_prep
	name = "Exploration Preparation Room (Archmundi)"
	icon_state = "mining"

/area/archmundi/quartermaster/exploration_dock
	name = "Exploration Dock (Archmundi)"
	icon_state = "mining"

//Service

/area/archmundi/janitor
	name = "Custodial Closet (Archmundi)"
	icon_state = "janitor"
	flags_1 = NONE
	mood_bonus = -1
	mood_message = "<span class='warning'>It feels dirty in here!\n</span>"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/archmundi/janitor/custodian
	name = "Custodial Closet (Archmundi)"
	icon_state = "janitor"

/area/archmundi/hydroponics
	name = "Hydroponics (Archmundi)"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE
	color_correction = /datum/client_colour/area_color/cold_ish

/area/archmundi/hydroponics/garden
	name = "Garden (Archmundi)"
	icon_state = "garden"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>It's so peaceful in here!\n</span>"

/area/archmundi/hydroponics/garden/abandoned
	name = "Abandoned Garden (Archmundi)"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/archmundi/hydroponics/garden/monastery
	name = "Monastery Garden (Archmundi)"
	icon_state = "hydro"


//Science

/area/archmundi/science
	name = "Science Division (Archmundi)"
	icon_state = "science"
	lighting_colour_tube = "#f0fbff"
	lighting_colour_bulb = "#e4f7ff"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	color_correction = /datum/client_colour/area_color/cold_ish

/area/archmundi/science/lobby
	name = "\improper Science Lobby (Archmundi)"
	icon_state = "science_lobby"

/area/archmundi/science/breakroom
	name = "\improper Science Break Room (Archmundi)"
	icon_state = "science_breakroom"

/area/archmundi/science/lab
	name = "Research and Development (Archmundi)"
	icon_state = "research"

/area/archmundi/science/xenobiology
	name = "Xenobiology Lab (Archmundi)"
	icon_state = "xenobio"

/area/archmundi/science/shuttle
	name = "Shuttle Construction (Archmundi)"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"

/area/archmundi/science/storage
	name = "Toxins Storage (Archmundi)"
	icon_state = "tox_storage"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/science/test_area
	name = "Toxins Test Area (Archmundi)"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "tox_test"
	lights_always_start_on = TRUE

/area/archmundi/science/mixing
	name = "Toxins Mixing Lab (Archmundi)"
	icon_state = "tox_mix"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/science/mixing/chamber
	name = "Toxins Mixing Chamber (Archmundi)"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "tox_mix_chamber"

/area/archmundi/science/misc_lab
	name = "Testing Lab (Archmundi)"
	icon_state = "tox_misc"

/area/archmundi/science/misc_lab/range
	name = "Research Testing Range (Archmundi)"
	icon_state = "tox_range"

/area/archmundi/science/server
	name = "Research Division Server Room (Archmundi)"
	icon_state = "server"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/science/explab
	name = "Experimentation Lab (Archmundi)"
	icon_state = "exp_lab"

/area/archmundi/science/robotics
	name = "Robotics (Archmundi)"
	icon_state = "robotics"

/area/archmundi/science/robotics/mechbay
	name = "Mech Bay (Archmundi)"
	icon_state = "mechbay"

/area/archmundi/science/robotics/lab
	name = "Robotics Lab (Archmundi)"
	icon_state = "ass_line"

/area/archmundi/science/research
	name = "Research Division (Archmundi)"
	icon_state = "science"

/area/archmundi/science/research/abandoned
	name = "Abandoned Research Lab (Archmundi)"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/archmundi/science/nanite
	name = "Nanite Lab (Archmundi)"
	icon_state = "nanite_lab"

/area/archmundi/science/shuttledock
	name = "Science Shuttle Dock (Archmundi)"
	icon_state = "sci_dock"

//Storage
/area/archmundi/storage
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
	lights_always_start_on = TRUE
	color_correction = /datum/client_colour/area_color/warm_yellow

/area/archmundi/storage/tools
	name = "Auxiliary Tool Storage (Archmundi)"
	icon_state = "tool_storage"

/area/archmundi/storage/primary
	name = "Primary Tool Storage (Archmundi)"
	icon_state = "primarystorage"

/area/archmundi/storage/art
	name = "Art Supply Storage (Archmundi)"
	icon_state = "art_storage"

/area/archmundi/storage/tcom
	name = "Telecomms Storage (Archmundi)"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "green"

/area/archmundi/storage/eva
	name = "EVA Storage (Archmundi)"
	icon_state = "eva"
	clockwork_warp_allowed = FALSE
	color_correction = /datum/client_colour/area_color/cold_ish

/area/archmundi/storage/emergency/starboard
	name = "Starboard Emergency Storage (Archmundi)"
	icon_state = "emergencystorage"

/area/archmundi/storage/emergency/port
	name = "Port Emergency Storage (Archmundi)"
	icon_state = "emergencystorage"

/area/archmundi/storage/tech
	name = "Technical Storage (Archmundi)"
	icon_state = "tech_storage"

//Construction

/area/archmundi/construction
	name = "Construction Area (Archmundi)"
	icon_state = "yellow"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/archmundi/construction/mining/aux_base
	name = "Auxiliary Base Construction (Archmundi)"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/archmundi/construction/storage_wing
	name = "Storage Wing (Archmundi)"
	icon_state = "storage_wing"

// Vacant Rooms
/area/archmundi/vacant_room
	name = "Vacant Room (Archmundi)"
	icon_state = "yellow"
	ambience_index = AMBIENCE_MAINT
	icon_state = "vacant_room"

/area/archmundi/vacant_room/office
	name = "Vacant Office (Archmundi)"
	icon_state = "vacant_office"

/area/archmundi/vacant_room/commissary
	name = "Vacant Commissary (Archmundi)"
	icon_state = "vacant_commissary"

/area/archmundi/vacant_room/commissary/commissary1
	name = "Vacant Commissary #1 (Archmundi)"
	icon_state = "vacant_commissary"

/area/archmundi/vacant_room/commissary/commissary2
	name = "Vacant Commissary #2 (Archmundi)"
	icon_state = "vacant_commissary"

/area/archmundi/vacant_room/commissary/commissaryFood
	name = "Vacant Food Stall Commissary (Archmundi)"
	icon_state = "vacant_commissary"

/area/archmundi/vacant_room/commissary/commissaryRandom
	name = "Unique Commissary (Archmundi)"
	icon_state = "vacant_commissary"

//AI

/area/archmundi/ai_monitored
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = TRUE
	color_correction = /datum/client_colour/area_color/cold

/area/archmundi/ai_monitored/security/armory
	name = "Armory (Archmundi)"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	mood_job_allowed = list(JOB_NAME_WARDEN)
	mood_bonus = 1
	mood_message = "<span class='nicegreen'>It's good to be home.</span>"

/area/archmundi/ai_monitored/storage/eva
	name = "EVA Storage (Archmundi)"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER
	color_correction = /datum/client_colour/area_color/cold_ish

/area/archmundi/ai_monitored/storage/satellite
	name = "AI Satellite Maint (Archmundi)"
	icon_state = "storage"
	ambience_index = AMBIENCE_DANGER

	//Turret_protected

/area/archmundi/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/archmundi/ai_monitored/turret_protected/ai_upload
	name = "AI Upload Chamber (Archmundi)"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_job_allowed = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CAPTAIN)
	mood_bonus = 4
	mood_message = "<span class='nicegreen'>The AI will bend to my will!\n</span>"

/area/archmundi/ai_monitored/turret_protected/ai_upload_foyer
	name = "AI Upload Access (Archmundi)"
	icon_state = "ai_upload_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/archmundi/ai_monitored/turret_protected/ai
	name = "AI Chamber (Archmundi)"
	icon_state = "ai_chamber"

/area/archmundi/ai_monitored/turret_protected/aisat
	name = "AI Satellite (Archmundi)"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/archmundi/ai_monitored/turret_protected/aisat/atmos
	name = "AI Satellite Atmos (Archmundi)"
	icon_state = "ai"

/area/archmundi/ai_monitored/turret_protected/aisat/foyer
	name = "AI Satellite Foyer (Archmundi)"
	icon_state = "ai_foyer"

/area/archmundi/ai_monitored/turret_protected/aisat/service
	name = "AI Satellite Service (Archmundi)"
	icon_state = "ai"

/area/archmundi/ai_monitored/turret_protected/aisat/hallway
	name = "AI Satellite Hallway (Archmundi)"
	icon_state = "ai"

/area/archmundi/aisat
	name = "AI Satellite Exterior (Archmundi)"
	icon_state = "yellow"
	lights_always_start_on = TRUE

/area/archmundi/ai_monitored/turret_protected/aisat/maint
	name = "AI Satellite Maintenance (Archmundi)"
	icon_state = "ai_maint"

/area/archmundi/ai_monitored/turret_protected/aisat_interior
	name = "AI Satellite Antechamber (Archmundi)"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/archmundi/ai_monitored/turret_protected/AIsatextAS
	name = "AI Sat Ext (Archmundi)"
	icon_state = "ai_sat_east"

/area/archmundi/ai_monitored/turret_protected/AIsatextAP
	name = "AI Sat Ext (Archmundi)"
	icon_state = "ai_sat_west"


// Telecommunications Satellite

/area/archmundi/tcommsat
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "For safety reasons, warping here is disallowed; the radio and bluespace noise could cause catastrophic results."
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	network_root_id = STATION_NETWORK_ROOT	// They should of unpluged the router before they left
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/archmundi/tcommsat/computer
	name = "Telecomms Control Room (Archmundi)"
	icon_state = "tcom_sat_comp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	mood_job_allowed = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER)
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>It's good to see these in working order.\n</span>"

/area/archmundi/tcommsat/server
	name = "Telecomms Server Room (Archmundi)"
	icon_state = "tcom_sat_cham"

/area/archmundi/tcommsat/relay
	name = "Telecommunications Relay (Archmundi)"
	icon_state = "tcom_sat_cham"
