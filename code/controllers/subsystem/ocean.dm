SUBSYSTEM_DEF(ocean)
	name = "Ocean"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_OCEAN

	///Our ocean
	var/datum/reagents/ocean_reagents
	///Reagents within our ocean - if you want this to be different for your map, make a mapping helper
	var/list/ocean_composition = list(/datum/reagent/expired_blood = INFINITY)
	///Ocean temperature
	var/ocean_temp = T20C

/datum/controller/subsystem/ocean/Initialize(timeofday)
	ocean_reagents = new /datum/reagents(INFINITY) //You *might* be able to drain the ocean
	//Add ocean reagents to the ocean
	change_ocean(ocean_reagents)

	return ..()

//Change what our ocean is made of - admin fuckery ahead
/datum/controller/subsystem/ocean/proc/change_ocean(list/reagent_list)
	//Add ocean reagents to the ocean
	ocean_reagents.add_reagent_list(ocean_composition)
	SEND_SIGNAL(src, COMSIG_GLOB_OCEAN_UPDATE)
