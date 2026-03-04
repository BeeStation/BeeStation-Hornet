#define CANNIBAL_MULTI 1.5

/datum/plant_trait/roots/parasitic
	name = "Parasitic"
	desc = "This gene causes roots to parasitically feed of a plant's fruit, depositing their reagents into their environment."

/datum/plant_trait/roots/parasitic/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_BUILT_POST, PROC_REF(catch_fruit))

/datum/plant_trait/roots/parasitic/proc/catch_fruit(datum/source, obj/fruit)
	SIGNAL_HANDLER

	if(SEND_SIGNAL(parent.parent.plant_item.loc, COMSIG_PLANTER_PAUSE_PLANT))
		return
//get ever available fruit and transfer its reagents to the tray
	var/list/available_reagents = list()
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_REQUEST_REAGENTS, available_reagents, parent)
	if(!length(available_reagents))
		return
	if(QDELETED(fruit))
		return
	var/divided_reagents = (fruit?.reagents.total_volume || 1) / length(available_reagents)
	if(!fruit?.reagents.total_volume)
		qdel(fruit)
		return
	for(var/datum/reagents/reagents as anything in available_reagents)
		fruit.reagents.trans_to(reagents, divided_reagents, CANNIBAL_MULTI*parent.trait_power)
	qdel(fruit)
//handle body harvest stuff
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_ACTION_HARVEST)

#undef CANNIBAL_MULTI
