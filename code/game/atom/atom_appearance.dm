/atom
	/// Overlays managed by [/atom/proc/update_overlays] to prevent removing overlays that weren't added by the same proc.
	var/list/managed_overlays

	/// Vis overlays managed by SSvis_overlays to automaticaly turn them like other overlays
	var/list/managed_vis_overlays

	/// A very temporary list of overlays to remove
	var/list/remove_overlays
	/// A very temporary list of overlays to add
	var/list/add_overlays

/**
 * Updates the appearance of the icon
 *
 * Mostly delegates to update_name, update_desc, and update_icon
 *
 * Arguments:
 * - updates: A set of bitflags dictating what should be updated. Defaults to [ALL]
 */
/atom/proc/update_appearance(updates=ALL)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_APPEARANCE, updates)
	if(updates & UPDATE_NAME)
		. |= update_name(updates)
	if(updates & UPDATE_DESC)
		. |= update_desc(updates)
	if(updates & UPDATE_ICON)
		. |= update_icon(updates)

	if (ismovable(src))
		UPDATE_OO_IF_PRESENT

/// Updates the name of the atom
/atom/proc/update_name(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME, updates)

/// Updates the description of the atom
/atom/proc/update_desc(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_DESC, updates)

/// Updates the icon of the atom
/atom/proc/update_icon(updates=ALL)
	// SHOULD_CALL_PARENT(TRUE) this should eventually be set when all update_icons() are updated. As of current this makes zmimic sometimes not catch updates
	SIGNAL_HANDLER

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON, updates)
	if(updates & UPDATE_ICON_STATE)
		update_icon_state()
		. |= UPDATE_ICON_STATE

	if(updates & UPDATE_OVERLAYS)
		if(LAZYLEN(managed_vis_overlays))
			SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

		// Clear the luminosity sources for our managed overlays
		REMOVE_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
		// Update the overlays where any luminous things get added again
		var/list/new_overlays = update_overlays(updates)
		if(managed_overlays)
			cut_overlay(managed_overlays)
			managed_overlays = null
		if(length(new_overlays))
			if (length(new_overlays) == 1)
				managed_overlays = new_overlays[1]
			else
				managed_overlays = new_overlays
			add_overlay(new_overlays)
		. |= UPDATE_OVERLAYS

	. |= SEND_SIGNAL(src, COMSIG_ATOM_UPDATED_ICON, updates, .)
	if (ismovable(src)) // need to update here as well since update_appearance() is not always called
		UPDATE_OO_IF_PRESENT

/// Updates the icon state of the atom
/atom/proc/update_icon_state()
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

/// Updates the overlays of the atom
/atom/proc/update_overlays()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)

/**
 * Checks the atom's loc and calls update_held_items on it if it is a mob.
 *
 * This should only be used in situations when you are unable to use /datum/element/update_icon_updates_onmob for whatever reason.
 * Check code/datums/elements/update_icon_updates_onmob.dm before using this. Adding that to the atom and calling update_appearance will work for most cases.
 *
 * Arguments:
 * * mob/target - The mob to update the icons of. Optional argument, use if the atom's loc is not the mob you want to update.
 */
/atom/proc/update_inhand_icon(mob/target = loc)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(target))
		return

	target.update_held_items()

	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_INHAND_ICON, target)
