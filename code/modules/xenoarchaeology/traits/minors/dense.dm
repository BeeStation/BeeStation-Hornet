/*
	Dense
	Makes the artifact behave like a structure
*/
/datum/xenoartifact_trait/minor/dense
	material_desc = "dense"
	label_name = "Dense"
	label_desc = "Dense: The artifact's design seems to incorporate dense elements. This will cause the artifact to be much heavier than usual."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/sharp, /datum/xenoartifact_trait/minor/ringed, /datum/xenoartifact_trait/minor/shielded,
	/datum/xenoartifact_trait/minor/aerodynamic, /datum/xenoartifact_trait/minor/slippery, /datum/xenoartifact_trait/minor/ringed/attack)
	weight = 30
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Old value tracker
	var/old_density
	var/old_atom_flag
	var/old_item_flag

/datum/xenoartifact_trait/minor/dense/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/obj/item/item_parent = component_parent.parent
	//Density
	old_density = item_parent.density
	item_parent.density = TRUE
	//Atom flag
	old_atom_flag = item_parent.interaction_flags_atom
	item_parent.interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	//Item flag
	if(isitem(item_parent))
		old_item_flag = item_parent.interaction_flags_item
		item_parent.interaction_flags_item = INTERACT_ATOM_ATTACK_HAND

/datum/xenoartifact_trait/minor/dense/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	var/obj/item/item_parent = component_parent.parent
	item_parent.density = old_density
	item_parent.interaction_flags_atom = old_atom_flag
	if(isitem(item_parent))
		item_parent.interaction_flags_item = old_item_flag
	return ..()

/datum/xenoartifact_trait/minor/dense/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)
