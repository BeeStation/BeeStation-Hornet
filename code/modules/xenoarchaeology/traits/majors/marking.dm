/*
	Marking
	Colors the target
*/
/datum/xenoartifact_trait/major/color
	label_name = "Marking"
	label_desc = "Marking: The artifact seems to contain colorizing components. Triggering these components will color the target."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///Possible colors
	var/list/possible_colors = list(COLOR_RED, COLOR_GREEN, COLOR_BLUE, COLOR_PURPLE, COLOR_ORANGE, COLOR_YELLOW, COLOR_CYAN, COLOR_PINK)
	///Choosen color
	var/color

/datum/xenoartifact_trait/major/color/New(atom/_parent)
	. = ..()
	color = pick(possible_colors)

/datum/xenoartifact_trait/major/color/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		target.add_atom_colour(color, WASHABLE_COLOUR_PRIORITY)
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/major/color/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("apply a set color to the target"))

//Random variant
/datum/xenoartifact_trait/major/color/random
	label_name = "Marking Δ"
	label_desc = "Marking Δ: The artifact seems to contain colorizing components. Triggering these components will color the target."
	conductivity = 3

/datum/xenoartifact_trait/major/color/random/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("apply a random color to the target"))

/datum/xenoartifact_trait/major/color/trigger(datum/source, _priority, atom/override)
	color = pick(possible_colors)
	return ..()
