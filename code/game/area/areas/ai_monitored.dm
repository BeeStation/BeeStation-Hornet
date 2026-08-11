// Specfic AI monitored areas

// Stub defined ai_monitored.dm
/area/station/ai_monitored

/area/station/ai_monitored/turret_protected

// AI
/area/station/ai_monitored
	icon_state = "ai"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ELITE
	lights_always_start_on = TRUE
	color_correction = /datum/client_colour/area_color/cold
	camera_networks = list(CAMERA_NETWORK_MINISAT)

/area/station/ai_monitored/aisat/exterior
	name = "\improper AI Satellite Exterior"
	icon_state = "ai"
	color_correction = null

/area/station/ai_monitored/command/storage/satellite
	name = "\improper AI Satellite Maint"
	icon_state = "ai_storage"
	ambience_index = AMBIENCE_DANGER

//AI - Turret_protected

/area/station/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	///Some sounds (like the space jam) are terrible when on loop. We use this varaible to add it to other AI areas, but override it to keep it from the AI's core.
	var/ai_will_not_hear_this = list('sound/ambience/ambimalf.ogg')

/area/station/ai_monitored/turret_protected/Initialize(mapload)
	. = ..()
	if(ai_will_not_hear_this)
		ambientsounds += ai_will_not_hear_this

/area/station/ai_monitored/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_job_allowed = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CAPTAIN)
	mood_bonus = 4
	mood_message = span_nicegreen("The AI will bend to my will!\n")
	camera_networks = list(CAMERA_NETWORK_MINISAT, CAMERA_NETWORK_AI_UPLOAD)

/area/station/ai_monitored/turret_protected/ai_upload_foyer
	name = "\improper AI Upload Access"
	icon_state = "ai_upload_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	camera_networks = list(CAMERA_NETWORK_MINISAT, CAMERA_NETWORK_AI_UPLOAD)

/area/station/ai_monitored/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ai_will_not_hear_this = null

/area/station/ai_monitored/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/ai_monitored/turret_protected/aisat/atmos
	name = "\improper AI Satellite Atmos"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/foyer
	name = "\improper AI Satellite Foyer"
	icon_state = "ai_foyer"

/area/station/ai_monitored/turret_protected/aisat/service
	name = "\improper AI Satellite Service"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/hallway
	name = "\improper AI Satellite Hallway"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/maint
	name = "\improper AI Satellite Maintenance"
	icon_state = "ai_maint"

/area/station/ai_monitored/turret_protected/aisat_interior
	name = "\improper AI Satellite Antechamber"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/ai_monitored/turret_protected/ai_sat_ext_as
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_east"

/area/station/ai_monitored/turret_protected/ai_sat_ext_ap
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_west"

//Command - AI Monitored

/area/station/ai_monitored/command/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER
	color_correction = /datum/client_colour/area_color/cold_ish
	camera_networks = list(CAMERA_NETWORK_STATION)

/area/station/ai_monitored/command/storage/eva/upper
	name = "Upper EVA Storage"

/area/station/ai_monitored/command/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM
	camera_networks = list(CAMERA_NETWORK_VAULT)

//Security - AI Monitored
/area/station/ai_monitored/security/armory
	name = "\improper Armory"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	mood_job_allowed = list(JOB_NAME_WARDEN)
	mood_bonus = 1
	mood_message = span_nicegreen("It's good to be home.")
	camera_networks = list(CAMERA_NETWORK_STATION)

/area/station/ai_monitored/security/armory/upper
	name = "Upper Armory"
