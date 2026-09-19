#define CANNIBAL_MULTI 1.5

/datum/plant_trait/roots/parasitic
	name = "Parasitic"
	desc = "This gene causes roots to parasitically feed off a plant's fruit, depositing their reagents into their environment."
	scales = "Reagent volume is multiplied by trait power."
	blacklist = list(/datum/plant_trait/roots/parasitic/juicer)
	/// Timer stuff for deposit action
	var/feed_timer
	var/feed_delay = 1.5 SECONDS // Gives people a chance to harvest the fruit before it gets chopped - secretly a way to deal with race conditions
	/// List of fruits we're about to deposit
	var/list/fruits = list()

/datum/plant_trait/roots/parasitic/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_BUILT_POST, PROC_REF(catch_fruit))
	// In the scenario someone harvests the fruits before we do
	RegisterSignal(parent.parent, COMSIG_PLANT_ACTION_HARVEST, PROC_REF(catch_harvest))

/datum/plant_trait/roots/parasitic/catch_component_qdel(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_FRUIT_BUILT_POST)
	UnregisterSignal(source, COMSIG_PLANT_ACTION_HARVEST)

/datum/plant_trait/roots/parasitic/proc/catch_harvest()
	SIGNAL_HANDLER

	if(feed_timer)
		deltimer(feed_timer)
	for(var/fruit as anything in fruits)
		fruits -= fruit
		UnregisterSignal(fruit, COMSIG_QDELETING)

/datum/plant_trait/roots/parasitic/proc/catch_fruit(datum/source, obj/item/fruit, datum/plant_feature/fruit/fruit_feature)
	SIGNAL_HANDLER

	if(SEND_SIGNAL(parent.parent.plant_item.loc, COMSIG_PLANTER_PAUSE_PLANT))
		return
	// Track fruits and setup a timer to nom
	fruits += fruit
	RegisterSignal(fruit, COMSIG_QDELETING, PROC_REF(catch_fruit_qdel))
	if(feed_timer)
		deltimer(feed_timer)
	feed_timer = addtimer(CALLBACK(src, PROC_REF(feed), fruit_feature), feed_delay, TIMER_STOPPABLE)

/datum/plant_trait/roots/parasitic/proc/feed(datum/plant_feature/fruit/fruit_feature)
	feed_timer = null
	for(var/fruit as anything in fruits)
		deposit(fruit)
	// Handle body harvest stuff
	if(!length(fruit_feature?.fruits))
		SEND_SIGNAL(parent.parent, COMSIG_PLANT_ACTION_HARVEST)

/datum/plant_trait/roots/parasitic/proc/deposit(obj/item/fruit)
	var/list/available_reagents = list()
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_REQUEST_REAGENTS, available_reagents, parent)
	// Flight checks
	if(!istype(fruit)) // This is future proofing- but why wouldn't fruit be an item?
		return
	if(!length(available_reagents))
		return
	if(QDELETED(fruit))
		return
	// Deposit
	var/divided_reagents = (fruit?.reagents.total_volume || 1) / length(available_reagents)
	if(fruit?.reagents.total_volume)
		for(var/datum/reagents/reagents as anything in available_reagents)
			if(fruit.reagents.total_volume == fruit.reagents.maximum_volume)
				fruit.reagents.remove_any(CANNIBAL_MULTI*parent.trait_power)
			fruit.reagents.trans_to(reagents, divided_reagents, CANNIBAL_MULTI*parent.trait_power)
	qdel(fruit)

/datum/plant_trait/roots/parasitic/proc/catch_fruit_qdel(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_QDELETING)
	fruits -= source

#undef CANNIBAL_MULTI
