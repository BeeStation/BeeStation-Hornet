SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING

	var/duplicate_shadow_updates_in_init = 0
	var/total_shadow_calculations = 0

	var/list/queued_shadow_updates = list()

	var/total_calculations = list()
	var/total_time_spent_processing = list()

	var/started = FALSE
	var/list/sources_that_need_updating = list()
	var/list/light_sources = list()

/client/verb/get_lighting_speed()
	set name = "light speed"
	set category = "lighting"

	for(var/range in SSlighting.total_calculations)
		var/total_amount = SSlighting.total_calculations[range]
		var/total_time = SSlighting.total_time_spent_processing[range]
		to_chat(usr, "[range] - [total_time / total_amount] ms")

/datum/controller/subsystem/lighting/Initialize(timeofday)
	started = TRUE
	if(!initialized)
		//Handle fancy lighting
		to_chat(world, "<span class='boldannounce'>Generating shadows on [sources_that_need_updating.len] light sources.</span>")
		var/timer = TICK_USAGE
		for(var/atom/movable/lighting_mask/mask as() in sources_that_need_updating)
			mask.calculate_lighting_shadows()
		sources_that_need_updating = null
		to_chat(world, "<span class='boldannounce'>Initial lighting conditions built successfully in [TICK_USAGE_TO_MS(timer)]ms.</span>")
		initialized = TRUE
	fire(FALSE, TRUE)
	. = ..()

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()

/datum/controller/subsystem/lighting/proc/build_shadows()
	var/timer = TICK_USAGE
	message_admins("Building [light_sources.len] shadows, its been an honour mrs obama")
	for(var/datum/light_source/light as() in light_sources)
		light.our_mask.calculate_lighting_shadows()
	message_admins("Shadows built in [TICK_USAGE_TO_MS(timer)]ms ([light_sources.len] shadows)")

/datum/controller/subsystem/lighting/proc/queue_shadow_render(mask_to_queue)
	LAZYOR(queued_shadow_updates, mask_to_queue)

/datum/controller/subsystem/lighting/proc/draw_shadows()
	for(var/atom/movable/lighting_mask/mask as() in queued_shadow_updates)
		mask.calculate_lighting_shadows(TRUE)
	LAZYCLEARLIST(queued_shadow_updates)

/datum/controller/subsystem/lighting/stat_entry()
	. = ..("Sources: [light_sources.len], ShCalcs: [total_shadow_calculations]")
