GLOBAL_LIST_EMPTY(lighting_update_lights) // List of lighting sources  queued for update.
GLOBAL_LIST_EMPTY(lighting_update_objects) // List of lighting objects queued for update.

SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER

/datum/controller/subsystem/lighting/stat_entry()
	. = ..("L:[GLOB.lighting_update_lights.len]|O:[GLOB.lighting_update_objects.len]")


/datum/controller/subsystem/lighting/Initialize(timeofday)
	if(!initialized)
		create_all_lighting_objects()
		initialized = TRUE

	fire(FALSE, TRUE)

	return ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	return


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
