/atom
	/// If non-null, overrides a/an/some in all cases
	var/article
	/// Text that appears preceding the name in examine()
	var/examine_thats = "That's"

/mob/living/carbon/human
	examine_thats = "This is"

/mob/living/silicon/robot
	examine_thats = "This is"

/**
 * Produces the base of examination. This returns a list containing
 * the basic examination info that can be determined when inspecting
 * an item.
 *
 * mob/user: The user inspecting the item
 * is_external_examination (bool): If true, then someone else is examining this
 * 								   item via a worn item external examination.
 */
/atom/proc/examine_base(mob/user, is_external_examination)
	. = list()
	if(desc)
		. += "<i>[desc]</i>"

	if(z && user.z != z) // Z-mimic
		var/diff = abs(user.z - z)
		. += span_boldnotice("[p_Theyre()] [diff] level\s below you.")

	var/list/tags_list = examine_tags(user)
	if (length(tags_list))
		var/tag_string = list()
		for (var/atom_tag in tags_list)
			tag_string += (isnull(tags_list[atom_tag]) ? atom_tag : span_tooltip(tags_list[atom_tag], atom_tag))
		// Weird bit but ensures that if the final element has its own "and" we don't add another one
		tag_string = english_list(tag_string, and_text = (findtext(tag_string[length(tag_string)], " and ")) ? ", " : " and ")
		var/post_descriptor = examine_post_descriptor(user)
		. += "[p_They()] [p_are()] a [tag_string] [examine_descriptor(user)][length(post_descriptor) ? " [jointext(post_descriptor, " ")]" : ""]."

/**
 * Called when a mob examines (shift click or verb) this atom
 *
 * Default behaviour is to get the name and icon of the object and it's reagents where
 * the TRANSPARENT flag is set on the reagents holder
 *
 * Produces a signal COMSIG_ATOM_EXAMINE
 */
/atom/proc/examine(mob/user)
	. = examine_base(user, FALSE)

	if(reagents)
		var/user_sees_reagents = user.can_see_reagents()
		var/reagent_sigreturn = SEND_SIGNAL(src, COMSIG_PARENT_REAGENT_EXAMINE, user, ., user_sees_reagents)
		if(!(reagent_sigreturn & STOP_GENERIC_REAGENT_EXAMINE))
			if(reagents.flags & TRANSPARENT)
				if(reagents.total_volume > 0)
					. += "It contains <b>[round(reagents.total_volume, 0.01)]</b> units of various reagents[user_sees_reagents ? ":" : "."]"
					if(user_sees_reagents) //Show each individual reagent
						for(var/datum/reagent/current_reagent as anything in reagents.reagent_list)
							. += "&bull; [round(current_reagent.volume, 0.01)] units of [current_reagent.name]"

					//-------- Beer goggles ---------
					if(user.can_see_boozepower())
						var/total_boozepower = 0
						var/list/taste_list = list()

						// calculates the total booze power from all 'ethanol' reagents
						for(var/datum/reagent/consumable/ethanol/B in reagents.reagent_list)
							total_boozepower += B.volume * max(B.boozepwr, 0) // minus booze power is reversed to light drinkers, but is actually 0 to normal drinkers.

						// gets taste results from all reagents
						for(var/datum/reagent/R in reagents.reagent_list)
							if(istype(R, /datum/reagent/consumable/ethanol/fruit_wine) && !(user.stat == DEAD) && !(HAS_TRAIT(src, TRAIT_BARMASTER)) ) // taste of fruit wine is mysterious, but can be known by ghosts/some special bar master trait holders
								taste_list += "<br/>   - unexplored taste of the winery (from [R.name])"
							else
								taste_list += "<br/>   - [R.taste_description] (from [R.name])"
						if(reagents.total_volume)
							. += span_notice("Booze Power: total [total_boozepower], average [round(total_boozepower/reagents.total_volume, 0.1)] ([get_boozepower_text(total_boozepower/reagents.total_volume, user)])")
							. += span_notice("It would taste like: [english_list(taste_list, comma_text="", and_text="")].")
					//-------------------------------
				else
					. += "It contains:<br>Nothing."
			else if(reagents.flags & AMOUNT_VISIBLE)
				if(reagents.total_volume)
					. += span_notice("It has [reagents.total_volume] unit\s left.")
				else
					. += span_danger("It's empty.")

	if(HAS_TRAIT(user, TRAIT_PSYCHIC_SENSE))
		var/list/souls = GET_ATOM_SOULS(src)
		if(!length(souls))
			return
		to_chat(user, span_notice("You sense a presence here..."))
		//Count of souls
		var/list/present_souls = list()
		for(var/soul in souls)
			present_souls[soul] += 1
		//Display the total soul count
		for(var/soul in present_souls)
			if(!present_souls[soul] || !GLOB.soul_glimmer_colors[soul])
				continue
			to_chat(user, "\t[span_notice("<span class='[GLOB.soul_glimmer_cfc_list[soul]]'>[soul]")], [present_souls[soul] > 1 ? "[present_souls[soul]] times" : "once"].</span>")

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE, user, .)

/**
 * A list of "tags" displayed after atom's description in examine.
 * This should return an assoc list of tags -> tooltips for them. If item if null, then no tooltip is assigned.
 * For example:
 * list("small" = "This is a small size class item.", "fireproof" = "This item is impervious to fire.")
 * will result in
 * This is a small, fireproof item.
 * where "item" is pulled from examine_descriptor() proc
 */
/atom/proc/examine_tags(mob/user)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_TAGS, user, .)

/// What this atom should be called in examine tags
/atom/proc/examine_descriptor(mob/user)
	return "object"

/// Returns a list of strings to be displayed after the descriptor
/atom/proc/examine_post_descriptor(mob/user)
	. = list()
	if(!custom_materials)
		return
	var/mats_list = list()
	for(var/custom_material in custom_materials)
		var/datum/material/current_material = SSmaterials.GetMaterialRef(custom_material)
		mats_list += span_tooltip("It is made out of [current_material.name].", current_material.name)
	. += "made of [english_list(mats_list)]"


/**
 * Called when a mob examines (shift click or verb) this atom twice (or more) within EXAMINE_MORE_WINDOW (default 1 second)
 *
 * This is where you can put extra information on something that may be superfluous or not important in critical gameplay
 * moments, while allowing people to manually double-examine to take a closer look
 *
 * Produces a signal [COMSIG_ATOM_EXAMINE_MORE]
 */
/atom/proc/examine_more(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_MORE, user, .)
	SEND_SIGNAL(user, COMSIG_MOB_EXAMINING_MORE, src, .)

/**
 * Get the name of this object for examine
 *
 * You can override what is returned from this proc by registering to listen for the
 * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
 */
/atom/proc/get_examine_name(mob/user)
	var/list/override = list(article, null, "<em>[get_visible_name()]</em>")
	SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override)

	if(!isnull(override[EXAMINE_POSITION_ARTICLE]))
		override -= null // IF there is no "before", don't try to join it
		return jointext(override, " ")
	if(!isnull(override[EXAMINE_POSITION_BEFORE]))
		override -= null // There is no article, don't try to join it
		return "\a [jointext(override, " ")]"
	return "\a [src]"

/mob/living/get_examine_name(mob/user)
	var/visible_name = get_visible_name()
	var/list/name_override = list(visible_name)
	if(SEND_SIGNAL(user, COMSIG_LIVING_PERCEIVE_EXAMINE_NAME, src, visible_name, name_override) & COMPONENT_EXAMINE_NAME_OVERRIDEN)
		return name_override[1]
	return visible_name

/// Icon displayed in examine
/atom/proc/get_examine_icon(mob/user)
	return icon2html(src, user)

/**
 * Formats the atom's name into a string for use in examine (as the "title" of the atom)
 *
 * * user - the mob examining the atom
 * * thats - whether to include "That's", or similar (mobs use "This is") before the name
 */
/atom/proc/examine_title(mob/user, thats = FALSE)
	var/examine_icon = get_examine_icon(user)
	return "[examine_icon ? "[examine_icon] " : ""][thats ? "[examine_thats] ":""]<em>[get_examine_name(user)]</em>"

/**
 * Returns an extended list of examine strings for any contained ID cards.
 *
 * Arguments:
 * * user - The user who is doing the examining.
 */
/atom/proc/get_id_examine_strings(mob/user)
	. = list()

/**
 * Used by mobs to determine the name for someone wearing a mask, or with a disfigured or missing face.
 * By default just returns the atom's name.
 *
 * * add_id_name - If TRUE, ID information such as honorifics or name (if mismatched) are appended
 * * force_real_name - If TRUE, will always return real_name and add (as face_name/id_name) if it doesn't match their appearance
 */
/atom/proc/get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
	return name
