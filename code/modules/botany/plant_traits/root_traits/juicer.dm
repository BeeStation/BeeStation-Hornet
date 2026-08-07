#define JUICE_MULTI 2.3

/*
	This is pretty similar to parasitic
	Keep them seperate though, so we can make them more unqiue in the future if we need to
	Code is dupe-y but it don't mattah, none of this mattas
*/

/datum/plant_trait/roots/parasitic/juicer
	name = "Fermenting"
	desc = "This gene causes roots to parasitically feed off a plant's fruit, depositing their juiced reagents into their environment. \
	Juiced reagents correlate to the fruit type."
	scales = "Reagent volume is multiplied by trait power."
	blacklist = list(/datum/plant_trait/roots/parasitic)

/datum/plant_trait/roots/parasitic/juicer/deposit(obj/item/fruit)
	var/list/available_reagents = list()
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_REQUEST_REAGENTS, available_reagents, parent)
	// Flight checks
	if(!istype(fruit))
		return
	if(!length(available_reagents))
		return
	if(QDELETED(fruit))
		return
	// Deposit
	var/divided_reagents = (fruit?.reagents.total_volume || 1) / length(available_reagents)
	if(fruit?.reagents.total_volume)
		fruit.reagents.convert_reagent(/datum/reagent, fruit.juice_typepath, include_source_subtypes = TRUE) // We juice ANY reagent, which makes us an upgrade to the grinder and barrel
		for(var/datum/reagents/reagents as anything in available_reagents)
			if(fruit.reagents.total_volume == fruit.reagents.maximum_volume)
				fruit.reagents.remove_any(JUICE_MULTI*parent.trait_power)
			fruit.reagents.trans_to(reagents, divided_reagents, JUICE_MULTI*parent.trait_power)
	qdel(fruit)

#undef JUICE_MULTI
