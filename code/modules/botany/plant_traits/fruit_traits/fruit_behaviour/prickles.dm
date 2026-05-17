//Percentage of reagents transfered on prick
#define BASE_REAGENT_TRANSFER 20

/*
	Stings mobs, imparts a % of fruit chems
*/
/datum/plant_trait/fruit/prickles
	name = "Prickles"
	desc = "The fruit develops hypodermic prickles that inject targets with a % reagents contained in the fruit."
	blacklist = list(/datum/plant_trait/fruit/liquid_contents)

/datum/plant_trait/fruit/prickles/setup_fruit_parent()
	. = ..()
	//We're chill to re-use the catch impact and qdel procs, the argument line up fine
	RegisterSignal(fruit_parent, COMSIG_MOVABLE_IMPACT, PROC_REF(catch_impact))
	RegisterSignal(fruit_parent, COMSIG_ATOM_INTERACT, PROC_REF(catch_impact))
	RegisterSignal(fruit_parent, COMSIG_ITEM_ATTACK, PROC_REF(catch_impact))

	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))

/datum/plant_trait/fruit/prickles/catch_activate(datum/source, mob/victim)
	. = ..()
	if(QDELING(src))
		return
	prick(victim)

/datum/plant_trait/fruit/prickles/proc/catch_impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(QDELING(src))
		return
	prick(hit_atom)

/datum/plant_trait/fruit/prickles/proc/prick(mob/living/victim)
	if(!isliving(victim))
		return
//Logging
	var/turf/T = get_turf(victim)
	victim.investigate_log("has activated [fruit_parent] at [AREACOORD(T)] injecting themselves with [trait_power*BASE_REAGENT_TRANSFER] % of [fruit_parent.reagents.log_list()]. \
	Last fingerprint: [fruit_parent.fingerprintslast].", INVESTIGATE_BOTANY)
	log_combat(victim, fruit_parent, "activated the", null, "injecting them with [trait_power*BASE_REAGENT_TRANSFER] % of [fruit_parent.reagents.log_list()]. Last fingerprint: [fruit_parent.fingerprintslast].")
//Reagents
	if(!victim.reagents || !victim.can_inject(null, 0))
		return FALSE
	var/injecting_amount = (trait_power*BASE_REAGENT_TRANSFER)*0.01
	var/fraction = max(fruit_parent.reagents.maximum_volume*injecting_amount, 1)
	fruit_parent.reagents.expose(victim, INJECT, fraction)
	fruit_parent.reagents.trans_to(victim, injecting_amount)
	to_chat(victim, span_danger("You are pricked by [fruit_parent]!"))
	return TRUE

#undef BASE_REAGENT_TRANSFER
