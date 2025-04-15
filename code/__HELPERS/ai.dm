///returns if something can be consumed, drink or food
/proc/IsEdible(obj/item/thing)
	if(!istype(thing))
		return FALSE
	if(IS_EDIBLE(thing))
		return TRUE
	if(istype(thing, /obj/item/reagent_containers/cup/glass/drinkingglass))
		var/obj/item/reagent_containers/cup/glass/drinkingglass/glass = thing
		if(glass.reagents.total_volume) // The glass has something in it, time to drink the mystery liquid!
			return TRUE
	return FALSE
