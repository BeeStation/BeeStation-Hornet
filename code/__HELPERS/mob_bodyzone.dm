
#define NOT_PRESENT_COLOUR "#0d0d0d"
#define FULL_HEALTH_COLOUR "#11ff00"
#define LOW_DAMAGE_COLOUR "#d9ff00"
#define POOR_HEALTH_COLOUR "#ff0000"

/// Displays a UI around the target allowing the user to select which bodypart
/// that they want to act on.
/// Target: The location to show the user interface.
/// Precise: Toggle to include groin, eyes and mouth. If true, implies hide_non_present will be forced to false.
/// Icon Callback: The callback to run in order to get the selection zone overlay.
/// If you want to wait for the result use: AWAIT(select_bodyzone(target))
/mob/proc/select_bodyzone_from_wheel(atom/target, precise = FALSE, datum/callback/icon_callback, override_zones = null)
	DECLARE_ASYNC
	if (!client || !client.prefs)
		ASYNC_RETURN(null)
	if (!icon_callback)
		icon_callback = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(select_bodyzone_limb_default))
	// Determine what parts we want to show
	var/list/bodyzone_options = list()
	var/list/parts = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_CHEST, BODY_ZONE_R_LEG, BODY_ZONE_R_ARM)
	if (override_zones)
		parts = override_zones
	for (var/bodyzone in parts)
		var/image/created_image = image(icon = ui_style2icon(client.prefs?.read_player_preference(/datum/preference/choiced/ui_style)), icon_state = "zone_sel")
		var/selection_overlay = icon_callback.Invoke(src, target, bodyzone, FALSE)
		created_image.overlays += selection_overlay
		bodyzone_options[bodyzone] = created_image
	var/result = show_radial_menu(src, target, bodyzone_options, radius = 40, require_near = TRUE, tooltips = TRUE)

	// Disconnected or no result
	if (!result || !client)
		ASYNC_RETURN(null)

	// Let the user choose more zones
	var/list/suboptions = null
	if (precise && result == BODY_ZONE_HEAD)
		suboptions = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH)
	else if (precise && result == BODY_ZONE_CHEST)
		suboptions = list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)

	if (suboptions)
		bodyzone_options = list()
		for (var/bodyzone in suboptions)
			var/image/created_image = image(icon = ui_style2icon(client.prefs?.read_player_preference(/datum/preference/choiced/ui_style)), icon_state = "zone_sel")
			var/selection_overlay = icon_callback.Invoke(src, target, bodyzone, !(bodyzone in parts))
			created_image.overlays += selection_overlay
			bodyzone_options[bodyzone] = created_image
		result = show_radial_menu(src, target, bodyzone_options, radius = 40, require_near = TRUE, tooltips = TRUE)

	// Disconnected or no result
	if (!result || !client)
		ASYNC_RETURN(null)
	if (!(result in parts) && !(result in suboptions))
		ASYNC_RETURN(null)
	ASYNC_RETURN(result)

/proc/select_bodyzone_limb_default( mob/user, atom/target, bodyzone, is_precise_part = FALSE)
	// Create the overlay
	var/image/selection_overlay = image(icon = 'icons/mob/zone_sel.dmi', icon_state = bodyzone)
	return selection_overlay

/proc/select_bodyzone_limb_health(accurate_health = FALSE, mob/user, atom/target, bodyzone, is_precise_part = FALSE)
	// Get the colours
	var/list/healthy = rgb2num(FULL_HEALTH_COLOUR)
	var/list/damaged = rgb2num(LOW_DAMAGE_COLOUR)
	var/list/unhealthy = rgb2num(POOR_HEALTH_COLOUR)
	var/list/not_present = rgb2num(NOT_PRESENT_COLOUR)
	// Create the overlay
	var/image/selection_overlay = image(icon = 'icons/mob/zone_sel.dmi', icon_state = bodyzone)
	// If the target is a mob, then colour the parts according to the part's health
	if (isliving(target))
		var/mob/living/living_target = target
		var/obj/item/bodypart/target_part = living_target.get_bodypart(bodyzone)
		// Determine what colour to make the indicator
		var/list/new_colour
		var/flash = FALSE
		if (!target_part)
			if (is_precise_part)
				new_colour = healthy
			else
				new_colour = not_present
		else
			// 0 = healthy, 1 = dead
			var/proportion = target_part.get_damage() / target_part.max_damage
			if (!accurate_health)
				proportion = proportion > 0 ? max(round(proportion, 1), 0.05) : 0
			else
				if (target_part.burn_dam > 0)
					var/image/dam_indicator = image(icon = 'icons/mob/zone_dam.dmi', icon_state = "burn")
					dam_indicator.appearance_flags = RESET_COLOR | RESET_ALPHA
					selection_overlay.overlays += dam_indicator
				if (target_part.brute_dam > 0)
					var/image/dam_indicator = image(icon = 'icons/mob/zone_dam.dmi', icon_state = "brute")
					dam_indicator.appearance_flags = RESET_COLOR | RESET_ALPHA
					selection_overlay.overlays += dam_indicator
			if (!living_target.can_inject(user, bodyzone, NONE))
				var/image/dam_indicator = image(icon = 'icons/mob/zone_dam.dmi', icon_state = "no_pierce")
				dam_indicator.appearance_flags = RESET_COLOR | RESET_ALPHA
				selection_overlay.overlays += dam_indicator
			if (proportion > 0)
				new_colour = list(
					proportion * unhealthy[1] + (1 - proportion) * damaged[1],
					proportion * unhealthy[2] + (1 - proportion) * damaged[2],
					proportion * unhealthy[3] + (1 - proportion) * damaged[3],
				)
			else
				new_colour = healthy
			flash = proportion >= 0.01
		// Set the colour
		selection_overlay.color = list(
			new_colour[1] / 255,
			new_colour[2] / 255,
			new_colour[3] / 255,
			0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1,
		)
		if (flash)
			animate(selection_overlay, time = 1 SECONDS, loop = -1, easing = SINE_EASING, color = list(
				new_colour[1] / 255,
				new_colour[2] / 255,
				new_colour[3] / 255,
				0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 2,
			))
			animate(time = 1 SECONDS, loop = -1, easing = SINE_EASING, color = list(
				new_colour[1] / 255,
				new_colour[2] / 255,
				new_colour[3] / 255,
				0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1,
			))
	return selection_overlay

/mob/proc/_is_holding(obj/item/item)
	return get_active_held_item() == item

#undef NOT_PRESENT_COLOUR
#undef FULL_HEALTH_COLOUR
#undef POOR_HEALTH_COLOUR
