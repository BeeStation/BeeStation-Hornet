/*
	Illuminating
	Toggles a light on the artifact
*/
/datum/xenoartifact_trait/major/illuminating
	label_name = "Illuminating"
	label_desc = "Illuminating: The artifact seems to contain illuminating components. Triggering these components will cause the artifact to illuminate."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 18
	///List of possible colors
	var/list/possible_colors = list(LIGHT_COLOR_FIRE, LIGHT_COLOR_BLUE, LIGHT_COLOR_GREEN, LIGHT_COLOR_RED, LIGHT_COLOR_ORANGE, LIGHT_COLOR_PINK)
	///Our actual color
	var/color
	///Are we currently lit?
	var/lit = FALSE

/datum/xenoartifact_trait/major/illuminating/New(atom/_parent)
	. = ..()
	color = pick(possible_colors)

/datum/xenoartifact_trait/major/illuminating/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	do_light()

/datum/xenoartifact_trait/major/illuminating/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("produce a randomly colored light"))

/datum/xenoartifact_trait/major/illuminating/proc/do_light(force = FALSE)
	if(!force)
		lit = !lit
	var/atom/light_source = component_parent.parent
	if(lit)
		light_source.set_light(component_parent.trait_strength*0.04, min(component_parent.trait_strength*0.1, 10), color)
	light_source.set_light_on(lit)
	light_source.update_light()

/datum/xenoartifact_trait/major/illuminating/catch_move(datum/source, atom/mover, dir)
	. = ..()
	var/atom/light_source = component_parent.parent
	if(!isturf(light_source.loc?.loc))
		lit = FALSE
		do_light(TRUE)

/datum/xenoartifact_trait/major/illuminating/shadow
	label_name = "Illuminating Δ"
	label_desc = "Illuminating Δ: The artifact seems to contain de-illuminating components. Triggering these components will cause the artifact to de-illuminate."
	conductivity = 3

/datum/xenoartifact_trait/major/illuminating/shadow/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("create a localised shadow"))

/datum/xenoartifact_trait/major/illuminating/shadow/do_light()
	lit = !lit
	var/atom/light_source = component_parent.parent
	if(lit)
		light_source.set_light(component_parent.trait_strength*0.04, min(component_parent.trait_strength*0.1, 10)*-1, color)
	else
		light_source.set_light(0, 0)
