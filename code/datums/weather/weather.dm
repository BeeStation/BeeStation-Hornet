//The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.

/datum/weather
	var/name = "space wind"
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."

	var/telegraph_message = "<span class='warning'>The wind begins to pick up.</span>" //The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_duration = 300 //In deciseconds, how long from the beginning of the telegraph until the weather begins
	var/telegraph_sound //The sound file played to everyone on an affected z-level
	var/telegraph_overlay //The overlay applied to all tiles on the z-level

	var/weather_message = "<span class='userdanger'>The wind begins to blow ferociously!</span>" //Displayed in chat once the weather begins in earnest
	var/weather_duration = 1200 //In deciseconds, how long the weather lasts once it begins
	var/weather_duration_lower = 1200 //See above - this is the lowest possible duration
	var/weather_duration_upper = 1500 //See above - this is the highest possible duration
	var/weather_sound
	var/weather_overlay
	var/weather_color = null

	var/end_message = "<span class='danger'>The wind relents its assault.</span>" //Displayed once the weather is over
	var/end_duration = 300 //In deciseconds, how long the "wind-down" graphic will appear before vanishing entirely
	var/end_sound
	var/end_overlay

	var/area_type = /area/space //Types of area to affect
	var/protect_indoors = FALSE // set to TRUE to protect indoor areas
	///Areas to be affected by the weather, calculated when the weather begins
	VAR_PRIVATE/list/impacted_areas = list() // If you need to update this list outside of this datum, you might be doing wrong. use update_areas()
	var/list/protected_areas = list()//Areas that are protected and excluded from the affected areas.
	var/impacted_z_levels // The list of z-levels that this weather is actively affecting

	var/overlay_layer = AREA_LAYER //Since it's above everything else, this is the layer used by default. TURF_LAYER is below mobs and walls if you need to use that.
	var/overlay_plane = AREA_PLANE
	var/aesthetic = FALSE //If the weather has no purpose other than looks
	var/immunity_type = "storm" //Used by mobs to prevent them from being affected by the weather

	var/stage = END_STAGE //The stage of the weather, from 1-4
	var/overlay_stage // takes the same value as stage. Used to prevent overlay error

	// These are read by the weather subsystem and used to determine when and where to run the weather.
	var/probability = 0 // Weight amongst other eligible weather. If zero, will never happen randomly.
	var/target_trait = ZTRAIT_STATION // The z-level trait to affect when run randomly or when not overridden.

	var/barometer_predictable = FALSE
	var/next_hit_time = 0 //For barometers to know when the next storm will hit
	/// This causes the weather to only end if forced to
	var/perpetual = FALSE

	// cached sprites to go on area overlays.
	var/mutable_appearance/cached_weather_sprite_start
	var/mutable_appearance/cached_weather_sprite_process
	var/mutable_appearance/cached_weather_sprite_end
	var/mutable_appearance/cached_current_overlay // a quick access variable

/datum/weather/New(z_levels)
	..()
	impacted_z_levels = z_levels
	generate_cached_weather_sprites()

/datum/weather/proc/generate_cached_weather_sprites()
	if(telegraph_overlay)
		cached_weather_sprite_start = mutable_appearance('icons/effects/weather_effects.dmi', telegraph_overlay, overlay_layer, overlay_plane, color = weather_color)
	if(weather_overlay)
		cached_weather_sprite_process = mutable_appearance('icons/effects/weather_effects.dmi', weather_overlay, overlay_layer, overlay_plane, color = weather_color)
	if(end_overlay)
		cached_weather_sprite_end = mutable_appearance('icons/effects/weather_effects.dmi', end_overlay, overlay_layer, overlay_plane, color = weather_color)

/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(type))
	stage = STARTUP_STAGE
	var/list/affectareas = list()
	for(var/V in get_areas(area_type))
		affectareas += V
	for(var/V in protected_areas)
		affectareas -= get_areas(V)
	for(var/V in affectareas)
		var/area/A = V
		if(protect_indoors && !A.outdoors)
			continue
		if(A.z in impacted_z_levels)
			impacted_areas |= A
	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	START_PROCESSING(SSweather, src)
	update_areas()
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			var/turf/mob_turf = get_turf(player)
			if(!mob_turf)
				continue
			if(telegraph_message)
				to_chat(player, telegraph_message)
			if(telegraph_sound)
				SEND_SOUND(player, sound(telegraph_sound))
	addtimer(CALLBACK(src, PROC_REF(start)), telegraph_duration)

/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_START(type))
	stage = MAIN_STAGE
	update_areas()
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			var/turf/mob_turf = get_turf(player)
			if(!mob_turf)
				continue
			if(weather_message)
				to_chat(player, weather_message)
			if(weather_sound)
				SEND_SOUND(player, sound(weather_sound))
	if(!perpetual)
		addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)

/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_WINDDOWN(type))
	stage = WIND_DOWN_STAGE
	update_areas()
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			var/turf/mob_turf = get_turf(player)
			if(!mob_turf)
				continue
			if(end_message)
				to_chat(player, end_message)
			if(end_sound)
				SEND_SOUND(player, sound(end_sound))
	addtimer(CALLBACK(src, PROC_REF(end)), end_duration)

/datum/weather/proc/end()
	if(stage == END_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(type))
	stage = END_STAGE
	STOP_PROCESSING(SSweather, src)
	update_areas()

/datum/weather/proc/can_weather_act(mob/living/act_on) //Can this weather impact a mob?
	var/turf/mob_turf = get_turf(act_on)
	if(mob_turf && !(mob_turf.z in impacted_z_levels))
		return
	if(immunity_type in act_on.weather_immunities)
		return
	if(!(get_area(act_on) in impacted_areas))
		return
	return TRUE

/datum/weather/proc/weather_act(mob/living/L) //What effect does this weather have on the hapless mob?
	return


/// list/new_areas_to_impact exists because of void heretic's weather
/datum/weather/proc/update_areas(list/new_areas_to_impact = null)
	if(overlay_stage == stage && isnull(new_areas_to_impact))
		CRASH("update_areas() is called again while weather overlay is already set (and list/new_areas_to_impact doesn't exist). stage:[stage] / overlay_stage:[overlay_stage]")
	overlay_stage = stage

	var/new_overlay = null
	switch(stage)
		if(STARTUP_STAGE)
			if(cached_weather_sprite_start)
				new_overlay = cached_weather_sprite_start
		if(MAIN_STAGE)
			if(cached_weather_sprite_process)
				new_overlay = cached_weather_sprite_process
		if(WIND_DOWN_STAGE)
			if(cached_weather_sprite_end)
				new_overlay = cached_weather_sprite_end
	var/is_overlay_same = (cached_current_overlay == new_overlay)
	if(is_overlay_same && isnull(cached_current_overlay) && isnull(new_overlay)) // changing null? meaningless
		if(new_areas_to_impact)
			CRASH("Are you sure updating overlays through null_overlay? list/new_areas_to_impact exists, but there's nothing to update overlay. this seems to be wrong.")
			// NOTE: if you think this is right...
			// remove this `CRASH`, and put `impacted_areas = new_areas_to_impact.Copy()`
		return

	// Standard update_areas
	if(isnull(new_areas_to_impact))
		if(is_overlay_same) // we don't have to iterate
			return

		for(var/area/each_area as anything in impacted_areas)
			if(cached_current_overlay)
				each_area.cut_overlay(cached_current_overlay)
			if(new_overlay)
				each_area.add_overlay(new_overlay)
		cached_current_overlay = new_overlay // remembers previous one
		return

	if(!islist(new_areas_to_impact))
		CRASH("lsit/new_areas_to_impact has been given, but it's not a list()")

	///// I hate this, but something dynamic is changing weather overlays
	if(is_overlay_same)
	// overlays are the same, and then we'll only check impacted areas are changed
	// * Calculate list
	// * Early return if there's no list to iterate
	// * If old_areas_to_remove exists, cut_overlay() for those
	// * If new_areas_to_add exists, add_overlay() for those
		var/list/old_areas_to_remove
		var/list/new_areas_to_add
		if(length(new_areas_to_impact))
			old_areas_to_remove = impacted_areas - new_areas_to_impact
			new_areas_to_add = new_areas_to_impact - impacted_areas
			/*
				impacted_areas = list(A, B, C, D)
				new_areas_to_impact =  list(C, D, E, F)

				old_areas_to_remove = list(A, B) // we want to remove already existing overlay from this
				new_areas_to_add = list(E, F)    // and add the existing overlay to this
			*/

		if(!length(new_areas_to_add) && !length(old_areas_to_remove)) // nope
			return

		for(var/area/each_old_area as anything in old_areas_to_remove)
			each_old_area.cut_overlay(cached_current_overlay)
		for(var/area/each_new_area as anything in new_areas_to_add)
			each_new_area.add_overlay(cached_current_overlay)
		impacted_areas = new_areas_to_impact.Copy() // this is now our new team
		return

	else
	// overlays should be changed extremely dynamically
	// * Removing old overlays from current areas and old areas
	// * Adding new overlays to current areas and new areas
		for(var/area/each_old_area as anything in impacted_areas)
			if(cached_current_overlay)
				each_old_area.cut_overlay(cached_current_overlay)
		for(var/area/each_new_area as anything in new_areas_to_impact)
			if(new_overlay)
				each_new_area.add_overlay(new_overlay)
		cached_current_overlay = new_overlay
		impacted_areas = new_areas_to_impact.Copy() // this is now our new team
		return
