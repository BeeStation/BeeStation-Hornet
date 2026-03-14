/*
	Slippery, guess what this does asshole
*/
/datum/plant_trait/fruit/slippery
	name = "Slippery"
	desc = "The fruit becomes slippery. Slipping a mob will trigger the fruit."
	examine_line = span_info("It has a very slippery skin.")
	///Ref to our slip component
	var/datum/component/slippery/slip_component

/datum/plant_trait/fruit/slippery/setup_fruit_parent()
	. = ..()
	if(is_type_in_typecache(fruit_parent, SSbotany.fruit_blacklist))
		return
	slip_component = fruit_parent.AddComponent(/datum/component/slippery, 60, NONE, CALLBACK(src, PROC_REF(handle_slip), fruit_parent))

/datum/plant_trait/fruit/slippery/Destroy(force, ...)
	QDEL_NULL(slip_component)
	return ..()

/datum/plant_trait/fruit/slippery/proc/handle_slip(obj/item/fruit, mob/M)
	if(QDELING(src))
		return
	log_game("[M] slipped on [fruit_parent] at [AREACOORD(fruit_parent)] and activated a plant trigger.")
	SEND_SIGNAL(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, src, M)

