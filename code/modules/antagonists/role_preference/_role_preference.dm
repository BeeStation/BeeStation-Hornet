/datum/role_preference
	var/name
	/// A brief description of this role, to display in the preferences menu.
	var/description
	/// What heading to display this entry under in the preferences menu. Use ROLE_PREFERENCE_CATEGORY defines.
	var/category
	/// The base abstract path for this subtype.
	var/abstract_type = /datum/role_preference
	/// The Antagonist datum typepath for this entry, if there is one. Used to get data about the role for display (bans etc)
	var/datum/antagonist/antag_datum
	/// If this preference can vary between characters.
	var/per_character = FALSE
	/// The typepath for the outfit to show in the preview for the preferences menu.
	var/preview_outfit
	/// Role preference path to use the icon of, if we're duplicating another.
	var/use_icon

/// Creates an icon from the preview outfit.
/// Custom implementors of `get_preview_icon` should use this, as the
/// result of `get_preview_icon` is expected to be the completed version.
/datum/role_preference/proc/render_preview_outfit(datum/outfit/outfit, mob/living/carbon/human/dummy)
	dummy = dummy || new /mob/living/carbon/human/dummy/consistent
	dummy.equipOutfit(outfit, visualsOnly = TRUE)
	COMPILE_OVERLAYS(dummy)
	var/icon = getFlatIcon(dummy)

	// We don't want to qdel the dummy right away, since its items haven't initialized yet.
	SSatoms.prepare_deletion(dummy)

	return icon

/// Given an icon, will crop it to be consistent of those in the preferences menu.
/// Not necessary, and in fact will look bad if it's anything other than a human.
/datum/role_preference/proc/finish_preview_icon(icon/icon)
	// Zoom in on the top of the head and the chest
	// I have no idea how to do this dynamically.
	icon.Scale(115, 115)

	// This is probably better as a Crop, but I cannot figure it out.
	icon.Shift(WEST, 8)
	icon.Shift(SOUTH, 30)

	icon.Crop(1, 1, ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return icon

/// Returns the icon to show on the preferences menu.
/datum/role_preference/proc/get_preview_icon()
	if (isnull(preview_outfit))
		return null

	return finish_preview_icon(render_preview_outfit(preview_outfit))

/// Includes latejoin and roundstart antagonists
/datum/role_preference/antagonist
	category = ROLE_PREFERENCE_CATEGORY_ANAGONIST
	abstract_type = /datum/role_preference/antagonist
	per_character = TRUE

/// Includes autotraitor and gamemode midround assignments - being forced into an antagonist during a round (does not apply to conversion antags).
/datum/role_preference/midround_living
	category = ROLE_PREFERENCE_CATEGORY_MIDROUND_LIVING
	abstract_type = /datum/role_preference/midround_living
	per_character = TRUE

/// Includes anything polled from ghosts that does antagonist stuff
/datum/role_preference/midround_ghost
	category = ROLE_PREFERENCE_CATEGORY_MIDROUND_GHOST
	abstract_type = /datum/role_preference/midround_ghost
