/*
	Delicate
	The artifact has limited uses
*/
/datum/xenoartifact_trait/minor/delicate
	material_desc = "delicate"
	label_name = "Delicate"
	label_desc = "Delicate: The artifact's design seems to delicate cooling elements. This will cause the artifact to potentially break."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = -5
	incompatabilities = TRAIT_INCOMPATIBLE_MOB
	///Max amount of uses
	var/max_uses
	///How many uses we have left
	var/current_uses

/datum/xenoartifact_trait/minor/delicate/New(atom/_parent)
	. = ..()
	//Generate uses
	max_uses = pick(list(3, 6, 9))
	current_uses = max_uses

/datum/xenoartifact_trait/minor/delicate/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	playsound(get_turf(component_parent?.parent), 'sound/effects/glass_step.ogg', 50, TRUE)
	if(current_uses)
		current_uses -= 1
	else if(prob(50)) //After we run out of uses, there is a 50% on use for it to break
		component_parent.calcify()
		playsound(get_turf(component_parent?.parent), 'sound/effects/glassbr1.ogg', 50, TRUE)

/datum/xenoartifact_trait/minor/delicate/generate_trait_appearance(atom/target)
	. = ..()
	target.alpha *= 0.7

/datum/xenoartifact_trait/minor/delicate/cut_trait_appearance(atom/target)
	. = ..()
	target.alpha /= 0.7

/datum/xenoartifact_trait/minor/delicate/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_APPEARANCE("This trait will make the artifact noticeably transparent."))
