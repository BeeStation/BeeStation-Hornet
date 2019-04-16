////////////////////
/////BODYPARTS/////
////////////////////

/obj/item/bodypart/proc/bee_species()
	var/list/bee_races = list(
		"squid"
	)
	if(species_id in bee_races)
		return TRUE
	else
		return FALSE