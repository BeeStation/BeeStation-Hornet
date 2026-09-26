/**
 * Causes weather to occur on a z level in certain area types
 *
 * The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.
 * Weather always occurs on different z levels at different times, regardless of weather type.
 * Can have custom durations, targets, and can automatically protect indoor areas.
 */

/datum/weather
	/// name of weather
	var/name = "space wind"
	/// description of weather
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."
	/// The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_message = span_warning("The wind begins to pick up.")
	/// How long from the beginning of the telegraph until the weather begins
	var/telegraph_duration = 30 SECONDS
	/// The sound file played to everyone on an affected z-level
	var/telegraph_sound
	/// The overlay applied to all tiles on the z-level
	var/telegraph_overlay

	/// Displayed in chat once the weather begins in earnest
	var/weather_message = span_userdanger("The wind begins to blow ferociously!")
	/// How long the weather lasts once it begins
	var/weather_duration = 2 MINUTES
	/// See above - this is the lowest possible duration
	var/weather_duration_lower = 2 MINUTES
	/// See above - this is the highest possible duration
	var/weather_duration_upper = 2.5 MINUTES
	/// The sound played to everyone on an affected z-level when weather is occuring (does not loop)
	var/weather_sound
	/// Area overlay while the weather is occuring
	var/weather_overlay
	/// Color to apply to the area while weather is occuring
	var/weather_color

	/// Displayed once the weather is over
	var/end_message = span_danger("The wind relents its assault.")
	/// How long the "wind-down" graphic will appear before vanishing entirely
	var/end_duration = 30 SECONDS
	/// Sound that plays while weather is ending
	var/end_sound
	/// Area overlay while weather is ending
	var/end_overlay

	/// Types of area to affect
	var/area_type = /area/misc/space
	/// Areas to be affected by the weather, calculated when the weather begins
	VAR_FINAL/list/impacted_areas = list()
	/// Areas that are protected and excluded from the affected areas.
	var/list/protected_areas = list()
	/// The list of z-levels that this weather is actively affecting
	VAR_FINAL/impacted_z_levels

	/// Since it's above everything else, this is the layer used by default.
	var/overlay_layer = AREA_LAYER
	/// Plane for the overlay
	var/overlay_plane = AREA_PLANE
	/// Used by mobs (or movables containing mobs, such as enviro bags) to prevent them from being affected by the weather.
	var/immunity_type

	/// The stage of the weather, from 1-4
	var/stage = END_STAGE
	/// takes the same value as stage by update_areas(). Used to prevent overlay error.
	VAR_PRIVATE/overlay_stage

	/// Weight amongst other eligible weather. If zero, will never happen randomly.
	var/probability = 0
	/// The z-level trait to affect when run randomly or when not overridden.
	var/target_trait = ZTRAIT_STATION
	/// For barometers to know when the next storm will hit
	var/next_hit_time = 0

	/// List of weather bitflags that determines effects (see \code\__DEFINES\weather.dm)
	var/weather_flags = NONE

	// cached sprites to go on area overlays.
	var/mutable_appearance/cached_weather_sprite_start
	var/mutable_appearance/cached_weather_sprite_process
	var/mutable_appearance/cached_weather_sprite_end
	var/mutable_appearance/cached_current_overlay // a quick access variable

/datum/weather/New(z_levels)
	. = ..()
	impacted_z_levels = z_levels

	setup_weather_areas()
	generate_cached_weather_sprites()

/datum/weather/proc/setup_weather_areas()
	for(var/area/affected_area as anything in get_areas(area_type))
		if(is_type_in_list(affected_area, protected_areas))
			continue
		if(!(weather_flags & WEATHER_INDOORS) && !affected_area.outdoors)
			continue
		if(!(affected_area.z in impacted_z_levels))
			continue

		impacted_areas |= affected_area

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
	stage = STARTUP_STAGE
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(type))
	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	SSweather.processing |= src
	update_areas()
	if(telegraph_duration)
		send_alert(telegraph_message, telegraph_sound)
	addtimer(CALLBACK(src, PROC_REF(start)), telegraph_duration)

/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_START(type))
	stage = MAIN_STAGE
	update_areas()
	send_alert(weather_message, weather_sound)
	if(!(weather_flags & (WEATHER_ENDLESS)))
		addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)

/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_WINDDOWN(type))
	stage = WIND_DOWN_STAGE
	update_areas()
	send_alert(end_message, end_sound)
	addtimer(CALLBACK(src, PROC_REF(end)), end_duration)

/datum/weather/proc/end()
	if(stage == END_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(type))
	stage = END_STAGE
	SSweather.processing -= src
	update_areas()

/// handles sending all alerts
/datum/weather/proc/send_alert(alert_msg, alert_sfx)
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			if(!can_get_alert(player))
				continue
			if(alert_msg)
				to_chat(player, alert_msg)
			if(alert_sfx)
				player.client?.sound_channel_initial_volumes["[CHANNEL_WEATHER]"] = 100
				player.stop_sound_channel(CHANNEL_WEATHER)

				var/pref_volume = player.client?.prefs.read_player_preference(/datum/preference/numeric/volume/sound_weather_volume)
				SEND_SOUND(player, sound(alert_sfx, channel = CHANNEL_WEATHER, volume = pref_volume))

// the checks for if a mob should receive alerts, returns TRUE if can
/datum/weather/proc/can_get_alert(mob/player)
	var/turf/mob_turf = get_turf(player)
	if(isnull(mob_turf))
		return FALSE
	return TRUE

/datum/weather/proc/can_weather_act_mob(mob/living/mob_to_check)
	var/turf/mob_turf = get_turf(mob_to_check)

	if(!mob_turf)
		return FALSE

	if(!(mob_turf.z in impacted_z_levels))
		return FALSE

	if(!(mob_turf.loc in impacted_areas))
		return FALSE

	var/atom/to_check = mob_to_check
	while(!isturf(to_check))
		if(recursive_weather_protection_check(to_check))
			return FALSE
		to_check = to_check.loc
	return TRUE

/**
 * Returns TRUE if the atom should protect itself or its contents from weather
 */
/datum/weather/proc/recursive_weather_protection_check(atom/to_check)
	return HAS_TRAIT(to_check, TRAIT_WEATHER_IMMUNE) || (immunity_type && HAS_TRAIT(to_check, immunity_type))

/**
 * Affects the mob with whatever the weather does
 */
/datum/weather/proc/weather_act_mob(mob/living/living)
	return

/// * [Func A] If list/newly_given_areas = null, It will update area overlays to new weather stage overlay. Typically called by this datum itself.
/// * [Func B] If list/newly_given_areas is given + overlay is not changed, it will apply overlays to new areas, and remove old areas.
/// * [Func C] If list/newly_given_areas is given + overlay stage is changed, it will remove old overlay from old areas, and apply new overlay to new areas.
/datum/weather/proc/update_areas(list/newly_given_areas = null)
	if(overlay_stage == stage && isnull(newly_given_areas))
		CRASH("update_areas() is called again while weather overlay is already set (and list/newly_given_areas doesn't exist). stage:[stage] / overlay_stage:[overlay_stage]")
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
	if(is_overlay_same && isnull(newly_given_areas) && isnull(cached_current_overlay) && isnull(new_overlay)) // changing null? meaningless
		return

	//! [Func A] Standard update_areas. This will typically do the weather overlay change.
	if(isnull(newly_given_areas))
		if(is_overlay_same) // we don't have to iterate
			return

		// ugly if conditions, but optimisation. We don't want to do if() checks in for loop
		if(cached_current_overlay && new_overlay)
			for(var/area/each_area as anything in impacted_areas)
				each_area.cut_overlay(cached_current_overlay)
				each_area.add_overlay(new_overlay)
		else if(cached_current_overlay)
			for(var/area/each_area as anything in impacted_areas)
				each_area.cut_overlay(cached_current_overlay)
		else if(new_overlay)
			for(var/area/each_area as anything in impacted_areas)
				each_area.add_overlay(new_overlay)

		cached_current_overlay = new_overlay // remembers previous one
		return

	if(!islist(newly_given_areas))
		CRASH("list/newly_given_areas has been given, but it's not a list()")


	// From after this line, It means list/newly_given_areas has a list to update
	// This will remove old areas, and overlay from list/impacted_areas
	// and add a new overlay to new areas
	// And list/impacted_areas will be updated with the new list

	if(is_overlay_same)
	// * [Func B] overlays are the same, but we have new areas.
	// * Calculate list
	// * Early return if there's no list to iterate
	// * If old_areas_to_remove exists, cut_overlay() for those
	// * If new_areas_to_add exists, add_overlay() for those
		var/list/old_areas_to_remove
		var/list/new_areas_to_add
		if(length(newly_given_areas))
			old_areas_to_remove = impacted_areas - newly_given_areas
			new_areas_to_add = newly_given_areas - impacted_areas
			/*
				impacted_areas = list(A, B, C, D)
				newly_given_areas =  list(C, D, E, F)

				old_areas_to_remove = list(A, B) // we want to remove already existing overlay from this
				new_areas_to_add = list(E, F)    // and add the existing overlay to this
			*/

		if(!length(new_areas_to_add) && !length(old_areas_to_remove)) // nope
			return

		if(cached_current_overlay) // do the change only overlay exists. If there's no overlay, we'll just save list/newly_given_areas
			for(var/area/each_old_area as anything in old_areas_to_remove)
				each_old_area.cut_overlay(cached_current_overlay)
			for(var/area/each_new_area as anything in new_areas_to_add)
				each_new_area.add_overlay(cached_current_overlay)
		impacted_areas = newly_given_areas.Copy() // this is now our new team
		// Note: "new_areas_to_add" is not correct to copy. We just needed to apply cached overlay to new areas.
	else
	// * [Func C] different overlays, but also we have new areas
	// * Removing old overlays from impacted_areas
	// * Adding new overlays to new areas
		if(cached_current_overlay)
			for(var/area/each_old_area as anything in impacted_areas)
				each_old_area.cut_overlay(cached_current_overlay)
		if(new_overlay)
			for(var/area/each_new_area as anything in newly_given_areas)
				each_new_area.add_overlay(new_overlay)
		cached_current_overlay = new_overlay
		impacted_areas = newly_given_areas.Copy() // this is now our new team
