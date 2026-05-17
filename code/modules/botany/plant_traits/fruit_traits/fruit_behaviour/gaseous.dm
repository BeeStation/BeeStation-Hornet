/datum/plant_trait/fruit/gaseous
	name = "Gaseous Decomposition"
	desc = "The fruit releases its reagents as smoke when triggered."
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
	var/datum/effect_system/smoke_spread/chem/S = new
	var/turf/T = get_turf(fruit_parent)
	S.attach(T)
	S.set_up(fruit_parent.reagents, round(smoke_amount*trait_power), T, 0)
	S.start()
	log_admin_private("[fruit_parent.fingerprintslast] has caused a plant to create smoke containing [fruit_parent.reagents.log_list()] at [AREACOORD(T)]")
	message_admins("[fruit_parent.fingerprintslast] has caused a plant to create smoke containing [fruit_parent.reagents.log_list()] at [ADMIN_VERBOSEJMP(T)]")
	fruit_parent.investigate_log(" has created a smoke containing [fruit_parent.reagents.log_list()] at [AREACOORD(T)]. Last fingerprint: [fruit_parent.fingerprintslast].", INVESTIGATE_BOTANY)
	fruit_parent.reagents.clear_reagents()
