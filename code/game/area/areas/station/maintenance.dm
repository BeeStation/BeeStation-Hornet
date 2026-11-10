//Maintenance

/area/station/maintenance
	abstract_type = /area/station/maintenance
	name = "Generic Maintenance"
	icon = 'icons/area/station/maintenance.dmi'
	icon_state = "maintenance"

	ambience_index = AMBIENCE_MAINT
	ambient_buzz = 'sound/ambience/maintenance/source_corridor2.ogg'
	ambient_buzz_vol = 20
	min_ambience_cooldown = 20 SECONDS
	max_ambience_cooldown = 35 SECONDS
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

	rare_ambient_sounds = list(
		'sound/machines/airlock.ogg',
		'sound/effects/snap.ogg',
		'sound/effects/clownstep1.ogg',
		'sound/effects/clownstep2.ogg',
		'sound/items/welder.ogg',
		'sound/items/welder2.ogg',
		'sound/items/crowbar.ogg',
		'sound/items/deconstruct.ogg',
		'sound/ambience/maintenance/source_holehit3.ogg',
		'sound/ambience/misc/cavesound3.ogg',
	)

	area_flags = HIDDEN_STASH_LOCATION | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | XENOBIOLOGY_CONSOLE_DISALLOWED

	mood_bonus = -1
	mood_message = span_warning("It's kind of cramped in here!\n")
	/// assistants are associated with maints, jani closet is in maints, engis have to go into maints often
	mood_job_allowed = list(JOB_NAME_ASSISTANT, JOB_NAME_JANITOR, JOB_NAME_STATIONENGINEER, JOB_NAME_CHIEFENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)
	mood_job_reverse = TRUE

	lighting_colour_tube = "#ffe5cb"
	lighting_colour_bulb = "#ffdbb4"

	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_NONE
	lights_always_start_on = TRUE

	color_correction = /datum/client_colour/area_color/cold_ish
	/// Maintenance shouldn't have cameras, it's a blind place
	camera_networks = list(CAMERA_NETWORK_STATION)

/area/station/maintenance/get_area_textures()
	return GLOB.turf_texture_maint

/// Maintenance - Departmental

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

/area/station/maintenance/department/crew_quarters/bar/club
	name = "Abandoned Club"
	icon_state = "maint_club"

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
	icon_state = "maint_sci_xeno"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE | CULT_PERMITTED
	camera_networks = list(CAMERA_NETWORK_STATION)

/// Maintenance - Generic Tunnels

/area/station/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "maint_aft"

/area/station/maintenance/aft/upper
	name = "Upper Aft Maintenance"
	icon_state = "maint_upperaft"

/area/station/maintenance/aft/greater
/// use greater variants of area definitions for when the station has two different sections of maintenance on the same z-level.
/// Can stand alone without "lesser". This one means that this goes more fore/north than the "lesser" maintenance area.
	name = "Greater Aft Maintenance"
	icon_state = "maint_greater_aft"

/area/station/maintenance/aft/lesser
/// use lesser variants of area definitions for when the station has two different sections of maintenance on the same z-level.
/// In conjunction with "greater" (just because it follows better). This one means that this goes more aft/south than the "greater" maintenance area.
	name = "Lesser Aft Maintenance"
	icon_state = "maint_lesser_aft"

/area/station/maintenance/central
	name = "Central Maintenance"
	icon_state = "maint_central"

/area/station/maintenance/central/greater
	name = "Greater Central Maintenance"
	icon_state = "maint_greater_central"

/area/station/maintenance/central/lesser
	name = "Lesser Central Maintenance"
	icon_state = "maint_lesser_central"

/area/station/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "maint_fore"

/area/station/maintenance/fore/greater
	name = "Greater Fore Maintenance"
	icon_state = "maint_greater_fore"

/area/station/maintenance/fore/lesser
	name = "Lesser Fore Maintenance"
	icon_state = "maint_lesser_fore"

/area/station/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "maint_starboard"

/area/station/maintenance/starboard/central
	name = "Central Starboard Maintenance"
	icon_state = "maint_central_starboard"

/area/station/maintenance/starboard/greater
	name = "Greater Starboard Maintenance"
	icon_state = "maint_greater_starboard"

/area/station/maintenance/starboard/lesser
	name = "Lesser Starboard Maintenance"
	icon_state = "maint_lesser_starboard"

/area/station/maintenance/starboard/aft
	name = "Aft Starboard Maintenance"
	icon_state = "maint_as"

/area/station/maintenance/starboard/fore
	name = "Fore Starboard Maintenance"
	icon_state = "maint_fs"

/area/station/maintenance/port
	name = "Port Maintenance"
	icon_state = "maint_port"

/area/station/maintenance/port/central
	name = "Central Port Maintenance"
	icon_state = "maint_central_port"

/area/station/maintenance/port/greater
	name = "Greater Port Maintenance"
	icon_state = "maint_greater_port"

/area/station/maintenance/port/lesser
	name = "Lesser Port Maintenance"
	icon_state = "maint_lesser_port"

/area/station/maintenance/port/aft
	name = "Aft Port Maintenance"
	icon_state = "maint_ap"

/area/station/maintenance/port/fore
	name = "Fore Port Maintenance"
	icon_state = "maint_fp"

/// Maintenance - Discrete Areas

/area/station/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "maint_disposal"

/area/station/maintenance/disposal/incinerator
	name = "\improper Incinerator"
	icon_state = "maint_incinerator"
	disable_air_alarm_automation = TRUE

/// Maintenance - External Hull Access

/area/station/maintenance/external
	name = "\improper External Hull Access"
	icon_state = "maint_external"

/area/station/maintenance/external/aft
	name = "\improper Aft External Hull Access"
	icon_state = "maint_external_aft"

/area/station/maintenance/external/port
	name = "\improper Port External Hull Access"
	icon_state = "maint_external_port"

/area/station/maintenance/external/port/bow
	name = "\improper Port Bow External Hull Access"
	icon_state = "maint_external_pb"

/// Maintenance - Radiation storm shelter
/area/station/maintenance/radshelter
	name = "\improper Radiation Storm Shelter"
	icon_state = "radstorm_shelter"

/area/station/maintenance/radshelter/medical
	name = "\improper Medical Radiation Storm Shelter"
	icon_state = "radstorm_shelter_med"

/area/station/maintenance/radshelter/sec
	name = "\improper Security Radiation Storm Shelter"
	icon_state = "radstorm_shelter_sec"

/area/station/maintenance/radshelter/service
	name = "\improper Service Radiation Storm Shelter"
	icon_state = "radstorm_shelter_service"

/area/station/maintenance/radshelter/civil
	name = "\improper Civilian Radiation Storm Shelter"
	icon_state = "radstorm_shelter_civ"

/area/station/maintenance/radshelter/sci
	name = "\improper Science Radiation Storm Shelter"
	icon_state = "radstorm_shelter_sci"

/area/station/maintenance/radshelter/cargo
	name = "\improper Cargo Radiation Storm Shelter"
	icon_state = "radstorm_shelter_cargo"

//Maintenance - Solars

/area/station/maintenance/solars
	name = "Solar Maintenance"
	icon_state = "maint_solar"
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_ENGINEERING)

/area/station/maintenance/solars/port
	name = "Port Solar Maintenance"
	icon_state = "Solarcontrol_port"

/area/station/maintenance/solars/port/aft
	name = "Port Quarter Solar Maintenance"
	icon_state = "Solarcontrol_ap"

/area/station/maintenance/solars/port/fore
	name = "Port Bow Solar Maintenance"
	icon_state = "Solarcontrol_fp"

/area/station/maintenance/solars/starboard
	name = "Starboard Solar Maintenance"
	icon_state = "Solarcontrol_starboard"

/area/station/maintenance/solars/starboard/aft
	name = "Starboard Quarter Solar Maintenance"
	icon_state = "Solarcontrol_as"

/area/station/maintenance/solars/starboard/fore
	name = "Starboard Bow Solar Maintenance"
	icon_state = "Solarcontrol_fs"



