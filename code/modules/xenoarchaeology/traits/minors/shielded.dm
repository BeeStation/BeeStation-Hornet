/*
	Shielded
	Makes the artifact act like a shield
*/
/datum/xenoartifact_trait/minor/shielded
	material_desc = "shielded"
	label_name = "Shielded"
	label_desc = "Shielded: The artifact's design seems to incorporate shielded elements. This will allow the artifact to be used like a shield."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = 15
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///old block power
	var/old_block_power
	var/max_block_power = 75

/datum/xenoartifact_trait/minor/shielded/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/obj/item/item_parent = component_parent.parent
	if(isitem(item_parent))
		//canblock
		item_parent.canblock = TRUE
		item_parent.block_flags = BLOCKING_ACTIVE
		//power
		old_block_power = item_parent.block_power
		item_parent.block_power = ROUND_UP(max_block_power * (component_parent.trait_strength/100))

/datum/xenoartifact_trait/minor/shielded/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	var/obj/item/item_parent = component_parent.parent
	if(isitem(item_parent))
		item_parent.canblock = initial(item_parent.canblock)
		item_parent.block_power = old_block_power
	return ..()

/datum/xenoartifact_trait/minor/shielded/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_RANDOMISED)
