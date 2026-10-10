/*
	FYI, this 'secretly' densifies the chemicals involved
*/
/datum/plant_trait/fruit/gaseous
	name = "Gaseous Decomposition"
	desc = "The fruit releases its reagents as smoke when triggered."
	scales = "Smoke cloud area scales with trait power"
	///How much smoke do we make, size
	var/smoke_amount = 1.4

/datum/plant_trait/fruit/gaseous/setup_fruit_parent()
	. = ..()
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))

/datum/plant_trait/fruit/gaseous/catch_activate(datum/source)
	. = ..()
	if(QDELING(src))
		return
	var/smoke_delta = smoke_amount*trait_power
// Smoke
	// Create a densified reagent pool
	var/datum/reagents/cloud_reagents = new(fruit_parent.reagents.maximum_volume*(smoke_delta*smoke_delta))
	fruit_parent.reagents.copy_to(cloud_reagents, cloud_reagents.maximum_volume, smoke_delta*smoke_delta)
	fruit_parent.reagents.clear_reagents() // Stop cheeky reagent dupes
	// imabouttoblow
	var/datum/effect_system/smoke_spread/chem/S = new
	var/turf/T = get_turf(fruit_parent)
	S.attach(T)
	S.set_up(cloud_reagents, round(smoke_delta), T, 0)
	S.start()
	qdel(cloud_reagents)
// Logging
	log_admin_private("[fruit_parent.fingerprintslast] has caused a plant to create smoke containing [fruit_parent.reagents.log_list()] at [AREACOORD(T)]")
	message_admins("[fruit_parent.fingerprintslast] has caused a plant to create smoke containing [fruit_parent.reagents.log_list()] at [ADMIN_VERBOSEJMP(T)]")
	fruit_parent.investigate_log(" has created a smoke containing [fruit_parent.reagents.log_list()] at [AREACOORD(T)]. Last fingerprint: [fruit_parent.fingerprintslast].", INVESTIGATE_BOTANY)
