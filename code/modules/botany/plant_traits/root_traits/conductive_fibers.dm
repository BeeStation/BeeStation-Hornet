/datum/plant_trait/roots/conductive
	name = "Conductive Fibers"
	desc = "This gene causes roots to charge wires below this plant. This works through floor panels."
	genetic_cost = 1
	scales = "Power production scales with trait power."
	///Cable charge per sercond
	var/cable_charge = 25000 //TODO: Make sure this is balanced - Racc


/datum/plant_trait/roots/conductive/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_trait/roots/conductive/process(delta_time)
	if(SEND_SIGNAL(parent.parent.plant_item.loc, COMSIG_PLANTER_PAUSE_PLANT))
		return
	var/obj/structure/cable/C = locate(/obj/structure/cable) in get_turf(parent.parent.plant_item)
	C?.powernet?.newavail += cable_charge*parent.trait_power*delta_time
