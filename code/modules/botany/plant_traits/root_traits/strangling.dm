/*
	Pauses progress on all neighbour plants
*/

/datum/plant_trait/roots/strangling
	name = "Strangling"
	desc = "Impedes the growth of other plants, and their fruit."
	genetic_cost = -1
	///Quick reference to the plant item
	var/obj/item/plant_item
	///Remember our old tray for signal cleanup
	var/atom/strangle_loc

/datum/plant_trait/roots/strangling/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	plant_item = parent.parent.plant_item
	//Strangle our loc
	setup_strangle()
	//Reset our strangle loc
	RegisterSignal(plant_item, COMSIG_MOVABLE_MOVED, PROC_REF(setup_strangle))

/datum/plant_trait/roots/strangling/proc/setup_strangle(datum/source)
	SIGNAL_HANDLER

	if(strangle_loc)
		UnregisterSignal(strangle_loc, COMSIG_PLANT_NEEDS_PAUSE)
		UnregisterSignal(strangle_loc, COMSIG_QDELETING)
	strangle_loc = plant_item.loc
	RegisterSignal(strangle_loc, COMSIG_QDELETING, PROC_REF(catch_qdel))
	RegisterSignal(strangle_loc, COMSIG_PLANT_NEEDS_PAUSE, PROC_REF(catch_pause))

/datum/plant_trait/roots/strangling/proc/catch_pause(datum/source, datum/component/plant/_plant, list/problem_list)
	SIGNAL_HANDLER

	var/obj/item/plant_tray/tray = source
	if(SEND_SIGNAL(tray, COMSIG_PLANTER_PAUSE_PLANT))
		return
	if(istype(tray) && problem_list)
		tray.add_feature_indicator(src, parent, problem_list)
	else if(problem_list) //Shouldn't happen, but I don't know how people will use it in a few years
		problem_list |= parent
	//Avoid strangling ourselves or our brothers & sisters
	if(_plant == parent.parent || _plant?.species_id == parent.parent.species_id)
		return
	return TRUE

/datum/plant_trait/roots/strangling/proc/catch_qdel(datum/source)
	SIGNAL_HANDLER

	strangle_loc = null
