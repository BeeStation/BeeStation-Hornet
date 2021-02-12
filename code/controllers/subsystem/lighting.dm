SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING
	flags = SS_NO_FIRE

	var/total_shadow_calculations = 0

	var/started = FALSE
	var/list/sources_that_need_updating = list()
	var/list/light_sources = list()

/datum/controller/subsystem/lighting/stat_entry()
	. = ..("Sources: [light_sources.len], ShCalcs: [total_shadow_calculations]")

/datum/controller/subsystem/lighting/Initialize(timeofday)
	started = TRUE
	to_chat(world, "<span class='boldannounce'>Generating shadows on [sources_that_need_updating.len] light sources.</span>")
	var/timer = TICK_USAGE
	for(var/atom/movable/lighting_mask/mask as() in sources_that_need_updating)
		mask.calculate_lighting_shadows()
	sources_that_need_updating = null
	to_chat(world, "<span class='boldannounce'>Initial lighting conditions built successfully in [TICK_USAGE_TO_MS(timer)]ms.</span>")
	. = ..()

/*/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	return*/

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()

/datum/controller/subsystem/lighting/proc/build_shadows()
	var/timer = TICK_USAGE
	message_admins("Building [light_sources.len] shadows, its been an honour mrs obama")
	for(var/datum/light_source/light as() in light_sources)
		light.our_mask.calculate_lighting_shadows()
	message_admins("Shadows built in [TICK_USAGE_TO_MS(timer)]ms ([light_sources.len] shadows)")
