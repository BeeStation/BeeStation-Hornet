/mob/living/simple_animal/hostile/holoparasite
	/// The alert showing that a holoparasite is anchored to its summoner.
	var/atom/movable/screen/alert/holoparasite/anchored/anchored_alert
	/// A simple cooldown preventing balloon alert spam for range-related alerts.
	COOLDOWN_DECLARE(range_balloon_cooldown)

/mob/living/simple_animal/hostile/holoparasite/Move(atom/new_loc)
	// Not manifested? Can't move.
	if(!is_manifested())
		return FALSE
	// You get force-recalled if you can't be manifested anyways.
	if(!can_be_manifested())
		recall(forced = TRUE)
		return FALSE
	// If you got no range, you shouldn't be able to move
	if(stats?.range == 1)
		return FALSE
	// You can't move out of your range yourself.
	if(is_in_range() && !is_in_range(new_loc))
		if(COOLDOWN_FINISHED(src, range_balloon_cooldown))
			balloon_alert(src, "can't move out of range", show_in_chat = FALSE)
			COOLDOWN_START(src, range_balloon_cooldown, 1 SECONDS)
		return FALSE
	if(attached_to_summoner)
		detach_from_summoner()
	update_summoner_attachment()
	. = ..()
	snapback()
	setup_barriers()

/**
 * Updates the "attached" effect, which is used to make the holoparasite appear to be attached to its summoner.
 * This is used by holoparasites with minimum range.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/update_summoner_attachment()
	if(!is_attached_to_summoner(check_manifested = FALSE))
		return FALSE
	alpha = 128
	forceMove(summoner.current.loc)
	setDir(summoner.current.dir)
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	layer = initial(layer)
	if(!anchored_alert)
		anchored_alert = throw_alert("holoparasite-anchored", /atom/movable/screen/alert/holoparasite/anchored)
	switch(dir)
		if(NORTH)
			pixel_y = -16
			layer = summoner.current.layer + 0.1
		if(SOUTH)
			pixel_y = 16
			layer = summoner.current.layer - 0.1
		if(EAST)
			pixel_x = -16
			layer = summoner.current.layer
		if(WEST)
			pixel_x = 16
			layer = summoner.current.layer
	return TRUE

/**
 * 'Detaches' the holoparasite from its summoner, resetting its alpha, offset, and layer.
 * Does nothing if the holoparasite is permanently attached, i.e if it is a holoparasite with minimum range.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/detach_from_summoner()
	if(is_attached_to_summoner(permanently = TRUE))
		return FALSE
	attached_to_summoner = FALSE
	if(alpha == 128)
		alpha = initial(alpha)
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	layer = initial(layer)
	if(anchored_alert)
		clear_alert("holoparasite-anchored")
		anchored_alert = null
	return TRUE

/**
 * Snap the holoparasite back to its summoner, if it is too far away.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/snapback()
	if(nullspace_if_dead())
		return
	if(summoner.current)
		if(!can_be_manifested())
			recall(forced = TRUE)
			return
		if(update_summoner_attachment() || is_in_range())
			return
		var/old_loc = loc
		SEND_SIGNAL(src, COMSIG_HOLOPARA_PRE_SNAPBACK)
		to_chat(src, span_holoparasite("You moved out of range, and were pulled back! You can only move [range] meters from [span_name("[summoner.name]")]!"))
		visible_message(span_danger("[color_name] jumps back to its user."))
		new /obj/effect/temp_visual/holoparasite/phase/out(loc)
		forceMove(summoner.current.loc)
		new /obj/effect/temp_visual/holoparasite/phase(loc)
		SEND_SIGNAL(src, COMSIG_HOLOPARA_SNAPBACK, old_loc)
		if(COOLDOWN_FINISHED(src, range_balloon_cooldown))
			balloon_alert(src, "left range", show_in_chat = FALSE)
			COOLDOWN_START(src, range_balloon_cooldown, 1 SECONDS)

/**
 * Ensure the holoparasite is ghosted before being nullspaced, to ensure it doesn't get sent to the error room.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/nullspace_if_dead(forced = FALSE)
	if(!forced && stat != DEAD && !is_summoner_dead())
		return FALSE
	ghostize(can_reenter_corpse = FALSE)
	moveToNullspace()
	return TRUE
