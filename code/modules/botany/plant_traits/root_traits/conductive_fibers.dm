/datum/plant_trait/roots/conductive
	name = "Conductive Fibers"
	desc = "This gene causes roots to charge wires below this plant. This works through floor panels."
	genetic_cost = 1
	///Cable charge per sercond
	var/cable_charge = 25000 //TODO: Make sure this is balanced


/datum/plant_trait/roots/conductive/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_trait/roots/conductive/process(delta_time)
	var/datum/component/planter/plant_tray = parent.parent.plant_item.loc.GetComponent(/datum/component/planter)
	if(!plant_tray)
		return
	var/obj/structure/cable/C = locate(/obj/structure/cable) in get_turf(parent.parent.plant_item)
	C?.powernet?.newavail += cable_charge*parent.trait_power*delta_time
