//maneater variant
/datum/xenoartifact_trait/activator/sturdy/hungry/maneater
	material_desc = null
	label_name = "Hungry Δ"
	label_desc = "Hungry Δ: The artifact seems to be made of a semi-living, hungry, material. This material seems to be triggered by feeding interactions."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	maneater = TRUE
	conductivity = 8

/datum/xenoartifact_trait/activator/sturdy/hungry/maneater/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("eat food items, and mobs"))
