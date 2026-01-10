/////////////////////////////////// EYE_BLIND ////////////////////////////////////

/**
  * Adjust a mobs blindness by an amount
  *
  * Will apply the blind alerts if needed
  */
/mob/proc/adjust_blindness(amount, force)
	if(!force && HAS_TRAIT_FROM(src, TRAIT_BLIND, "uncurable"))
		return
	var/old_eye_blind = eye_blind
	eye_blind = max(eye_blind + amount, 0)
	if(!old_eye_blind || !eye_blind && !HAS_TRAIT(src, TRAIT_BLIND))
		update_blindness()

/**
  * Force set the blindness of a mob to some level
  */
/mob/proc/set_blindness(amount, force)
	if(!force && HAS_TRAIT_FROM(src, TRAIT_BLIND, "uncurable"))
		return
	var/old_eye_blind = eye_blind
	eye_blind = max(amount, 0)
	if(!old_eye_blind || !eye_blind && !HAS_TRAIT(src, TRAIT_BLIND))
		update_blindness()

/// proc that adds and removes blindness overlays when necessary
/mob/proc/update_blindness(overlay = /atom/movable/screen/fullscreen/blind, add_color = TRUE, can_see = TRUE)
	switch(stat)
		if(CONSCIOUS, SOFT_CRIT)
			if(HAS_TRAIT(src, TRAIT_BLIND) || eye_blind && istype(overlay, /atom/movable/screen/alert))
				throw_alert("blind", /atom/movable/screen/alert/blind)
				do_set_blindness(FALSE, overlay, add_color)
			else
				do_set_blindness(TRUE, overlay, add_color)
		if(UNCONSCIOUS, HARD_CRIT)
			do_set_blindness(FALSE, overlay, add_color)
		if(DEAD)
			do_set_blindness(TRUE, overlay, add_color)

///Proc that handles adding and removing the blindness overlays.
/mob/proc/do_set_blindness(can_see, overlay_setter, add_color_setter)
	if(!can_see)
		overlay_fullscreen("blind", overlay_setter)
		// You are blind why should you be able to make out details like color, only shapes near you
		if(add_color_setter)
			add_client_colour(/datum/client_colour/monochrome/blind)
		var/datum/component/blind_sense/B = GetComponent(/datum/component/blind_sense)
		if(!B && !QDELING(src) && !QDELETED(src))
			AddComponent(/datum/component/blind_sense)
	else
		clear_alert("blind")
		clear_fullscreen("blind")
		remove_client_colour(/datum/client_colour/monochrome/blind)
		var/datum/component/blind_sense/B = GetComponent(/datum/component/blind_sense)
		B?.ClearFromParent()

/**
  * Make the mobs vision blurry
  */
/mob/proc/blur_eyes(amount)
	if(amount>0)
		eye_blurry = max(amount, eye_blurry)
	update_eye_blur()

/**
  * Adjust the current blurriness of the mobs vision by amount
  */
/mob/proc/adjust_blurriness(amount)
	eye_blurry = max(eye_blurry+amount, 0)
	update_eye_blur()

///Set the mobs blurriness of vision to an amount
/mob/proc/set_blurriness(amount)
	eye_blurry = max(amount, 0)
	update_eye_blur()

///Apply the blurry overlays to a mobs clients screen
/mob/proc/update_eye_blur()
	if(!hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	if(eye_blurry)
		game_plane_master_controller.add_filter("eye_blur", 1, gauss_blur_filter(clamp(eye_blurry * 0.1, 0.6, 3)))
	else
		game_plane_master_controller.remove_filter("eye_blur")

///Adjust the drugginess of a mob
/mob/proc/adjust_drugginess(amount)
	return

///Set the drugginess of a mob
/mob/proc/set_drugginess(amount)
	return

///Adjust the disgust level of a mob
/mob/proc/adjust_disgust(amount)
	return

///Set the disgust level of a mob
/mob/proc/set_disgust(amount)
	return

///Adjust the body temperature of a mob, with min/max settings
/mob/proc/adjust_bodytemperature(amount,min_temp=0,max_temp=INFINITY)
	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount,min_temp,max_temp)
