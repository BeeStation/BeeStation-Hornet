GLOBAL_LIST_EMPTY(lighting_update_lights) // List of lighting sources  queued for update.
GLOBAL_LIST_EMPTY(lighting_update_objects) // List of lighting objects queued for update.

SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER

	var/list/light_sources = list()

/datum/controller/subsystem/lighting/stat_entry()
	. = ..("L:[GLOB.lighting_update_lights.len]|O:[GLOB.lighting_update_objects.len]")

/datum/controller/subsystem/lighting/Initialize(timeofday)
	fire(FALSE, TRUE)
	return ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	return


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()

/datum/controller/subsystem/lighting/proc/build_shadows()
	var/timer = TICK_USAGE
	message_admins("Building [light_sources.len] shadows, its been an honour mrs obama")
	for(var/datum/light_source/light as() in light_sources)
		light.our_mask.calculate_lighting_shadows()
	message_admins("Shadows built in [TICK_USAGE_TO_MS(timer)]ms ([light_sources.len] shadows)")
