////////////////////
/////BODYPARTS/////
////////////////////

/obj/item/bodypart/proc/bee_species()
	var/list/bee_races = list(
		"squid",
	)
	if(species_id in bee_races)
		return TRUE
	else if (findtext(species_id, "golem"))  // they all have different species IDs
		return TRUE
	else
		return FALSE