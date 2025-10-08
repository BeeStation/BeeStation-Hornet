/atom
	/// If non-null, overrides a/an/some in all cases
	var/article

/**
 * Called when a mob examines (shift click or verb) this atom
 *
 * Default behaviour is to get the name and icon of the object and it's reagents where
 * the TRANSPARENT flag is set on the reagents holder
 *
 * Produces a signal COMSIG_ATOM_EXAMINE
 */
/atom/proc/examine(mob/user)
	var/examine_string = get_examine_string(user, thats = TRUE)
	if(examine_string)
		. = list("[examine_string].")
	else
		. = list()

	if(desc)
		. += desc

	if(z && user.z != z) // Z-mimic
		var/diff = abs(user.z - z)
		. += span_boldnotice("[p_theyre(TRUE)] [diff] level\s below you.")

	var/list/tags_list = examine_tags(user)
	if (length(tags_list))
		var/tag_string = list()
		for (var/atom_tag in tags_list)
			tag_string += (isnull(tags_list[atom_tag]) ? atom_tag : span_tooltip(tags_list[atom_tag], atom_tag))
		// Weird bit but ensures that if the final element has its own "and" we don't add another one
		tag_string = english_list(tag_string, and_text = (findtext(tag_string[length(tag_string)], " and ")) ? ", " : " and ")
		var/post_descriptor = examine_post_descriptor(user)
		. += "[p_They()] [p_are()] a [tag_string] [examine_descriptor(user)][length(post_descriptor) ? " [jointext(post_descriptor, " ")]" : ""]."

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
		var/list/souls = return_souls()
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
 * COMSIG_ATOM_GET_EXAMINE_NAME signal
 */
/atom/proc/get_examine_name(mob/user)
	. = "\a <b>[src]</b>"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] <b>[src]</b>"
		override[EXAMINE_POSITION_ARTICLE] = article
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

/// Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(src, user)] [thats? "That's ":""][get_examine_name(user)]"
