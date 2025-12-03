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
	/// The default state for being enabled or disabled
	var/default_enabled = TRUE

/// Creates an icon from the preview outfit.
/// Custom implementors of `get_preview_icon` should use this, as the
/// result of `get_preview_icon` is expected to be the completed version.
/datum/role_preference/proc/render_preview_outfit(datum/outfit/outfit, mob/living/carbon/human/dummy)
	dummy = dummy || new /mob/living/carbon/human/dummy/consistent
	dummy.equipOutfit(outfit, visuals_only = TRUE)
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

/// Includes roundstart antagonists
/datum/role_preference/roundstart
	category = ROLE_PREFERENCE_CATEGORY_ROUNDSTART
	abstract_type = /datum/role_preference/roundstart
	per_character = TRUE
	default_enabled = TRUE

/// Includes living dynamic midround assignments (does not apply to conversion antags).
/datum/role_preference/midround
	category = ROLE_PREFERENCE_CATEGORY_MIDROUND
	abstract_type = /datum/role_preference/midround
	per_character = TRUE
	default_enabled = TRUE

/// Includes roundstart antagonists
/datum/role_preference/supplementary
	category = ROLE_PREFERENCE_CATEGORY_SUPPLEMENTARY
	abstract_type = /datum/role_preference/supplementary
	per_character = TRUE
	default_enabled = TRUE
