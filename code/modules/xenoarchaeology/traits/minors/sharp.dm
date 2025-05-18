/*
	Sharp
	Makes the artifact sharp
*/
/datum/xenoartifact_trait/minor/sharp
	material_desc = "sharp"
	label_name = "Sharp"
	label_desc = "Sharp: The artifact's design seems to incorporate sharp elements. This will cause the artifact to pbe sharper than usual."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///The artifact's old sharpness
	var/old_sharp
	///The artifact's old force
	var/old_force
	var/max_force = 10
	///The artifact's old attack verbs
	var/list/old_verbs
	var/list/attack_verbs = list("cleaved", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")

/datum/xenoartifact_trait/minor/sharp/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/obj/item/item_parent = component_parent.parent
	if(isitem(item_parent))
		//Sharpness
		old_sharp = item_parent.sharpness
		item_parent.sharpness = SHARP_DISMEMBER
		//Force
		old_force = item_parent.force
		item_parent.force = max_force * (component_parent.trait_strength/100)
		//Verbs
		old_verbs = item_parent.attack_verb_simple
		item_parent.attack_verb_simple = attack_verbs

/datum/xenoartifact_trait/minor/sharp/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return
	var/obj/item/item_parent = component_parent.parent
	if(isitem(item_parent))
		item_parent.sharpness = old_sharp
		item_parent.force = old_force
		item_parent.attack_verb_simple = old_verbs
	return ..()

/datum/xenoartifact_trait/minor/sharp/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)
