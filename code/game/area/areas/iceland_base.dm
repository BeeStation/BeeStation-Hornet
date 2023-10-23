/area/iceland_base
	name = "iceland base areas"
	icon_state = "iceland_base" //Baka baka!
	has_gravity = STANDARD_GRAVITY
	lighting_colour_tube = "#d2ffe1"
	lighting_colour_bulb = "#b7e8ff"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED
	ambient_buzz = 'sound/ambience/icelandinside.ogg'
	ambient_buzz_vol = 10
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	teleport_restriction = TELEPORT_ALLOW_NONE
	outdoors = FALSE

///NOTE: this will containt all the Base zones, for the outpost and misc areas, look at ruins/iceland.dm!///

/area/iceland_base/command
	name = "Bridge (iceland)"
	icon_state = "iceland_bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/iceland_base/command/captain
	name = "Captain's Quarters (iceland)"
	icon_state = "iceland_cap_quart"
	sound_environment = SOUND_AREA_WOODFLOOR
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/iceland_base/command/hop
	name = "Head of Personnel's Office (iceland)"
	icon_state = "iceland_hop_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/iceland_base/command/chief
	name = "Chief Engineer's Office (iceland)"
	icon_state = "iceland_ce_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE

/area/iceland_base/command/hos
	name = "Head of Security's Office (iceland)"
	icon_state = "iceland_hos_office"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = FALSE

/area/iceland_base/command/council
	name = "Heads of Staff council Room (iceland)"
	icon_state = "iceland_meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/iceland_base/hallway_command
	name = "Command Hallway (iceland)"
	icon_state = "iceland_bridge_hall"

/area/iceland_base/tcomm
	name = "Telecommunications Relay (iceland)"
	icon_state = "iceland_telecomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')

/area/iceland_base/engine
	name = "Engineering (iceland)"
	icon_state = "iceland_engineering"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/iceland_base/engine/engine_smes
	name = "Engineering SMES (iceland)"
	icon_state = "iceland_smes"

/area/iceland_base/crew_quarters
	name = "Crew quarters (iceland)"
	icon_state = "iceland_dorms"
	sound_environment = SOUND_AREA_STANDARD_STATION
	lights_always_start_on = TRUE
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_SIMPLE

/area/iceland_base/crew_quarters/bar
	name = "Bar (iceland)"
	icon_state = "iceland_bar"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>A glimmer of hope in this wasteland!\n</span>"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/iceland_base/crew_quarters/kitchen
	name = "Kitchen (iceland)"
	icon_state = "iceland_kitchen"
	lights_always_start_on = FALSE

/area/iceland_base/crew_quarters/hydroponics
	name = "Hydroponics (iceland)"
	icon_state = "iceland_hydro"

/area/iceland_base/security
	name = "Brig (iceland)"
	icon_state = "iceland_brig"
	mood_bonus = -2
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN,JOB_NAME_SECURITYOFFICER,JOB_NAME_BRIGPHYSICIAN,JOB_NAME_DETECTIVE)
	mood_job_reverse = TRUE
	mood_message = "<span class='warning'>Even here, there's cramped cells...\n</span>"

/area/iceland_base/cargo
	name = "Cargo office (iceland)"
	icon_state = "iceland_cargo"

/area/iceland_base/cargo/mining
	name = "Mining base (iceland)"
	icon_state = "iceland_mining"

/area/iceland_base/science
	name = "Research Division (iceland)"
	icon_state = "iceland_science"

/area/iceland_base/science/lobby
	name = "Medical/Research lobby (iceland)"
	icon_state = "iceland_science_lobby"

/area/iceland_base/medical/
	name = "Medical (iceland)"
	icon_state = "iceland_medbay"
	ambience_index = AMBIENCE_MEDICAL
	sound_environment = SOUND_AREA_STANDARD_STATION
	mood_bonus = 1
	mood_message = "<span class='nicegreen'>I feel safe in here, I hope...\n</span>"

/area/iceland_base/medical/apothecary
	name = "Apothecary (iceland)"
	icon_state = "iceland_apothecary"

/area/iceland_base/chapel
	name = "chapel (iceland)"
	icon_state = "iceland_chapel"
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The consecration here prevents you from warping in."
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_PROTECTED
