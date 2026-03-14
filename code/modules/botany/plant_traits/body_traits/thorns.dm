//Percentage of reagents transfered on prick
#define BASE_REAGENT_TRANSFER 8

/*
	Transfers chems from the loc, tray, to mobs passing within 1 tile, deals a small small amount of damage
*/
/datum/plant_trait/body/thorns
	name = "Thorns"
	desc = "Injects  with a % of reagents from the plant's location. Wearing <i>thick</i> gloves will block this. "
	///Quick reference to the plant item
	var/obj/item/plant_item
	///List of turfs we thorn
	var/list/thorn_turfs = list()
	///Remember our old tray for signal cleanup
	var/atom/thorn_loc
	///Range of turfs we GAF about
	var/turf_range = 1

/datum/plant_trait/body/thorns/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	plant_item = parent.parent.plant_item
	//Reset our thorns loc
	RegisterSignal(plant_item, COMSIG_MOVABLE_MOVED, PROC_REF(setup_loc))
	setup_loc()

/datum/plant_trait/body/thorns/proc/setup_loc()
	if(thorn_loc)
		UnregisterSignal(thorn_loc, COMSIG_MOVABLE_MOVED)
	thorn_loc = plant_item.loc
	RegisterSignal(thorn_loc, COMSIG_MOVABLE_MOVED, PROC_REF(setup_thorns))
	setup_thorns()

/datum/plant_trait/body/thorns/proc/setup_thorns(datum/source)
	SIGNAL_HANDLER

//Fire old turfs
	for(var/turf/turf as anything in thorn_turfs)
		if(turf in _signal_procs) //Not having this makes the MC shit its gut out big time
			UnregisterSignal(turf, COMSIG_ATOM_ENTERED)
		thorn_turfs -= turf
//Employ new turfs
	var/list/turfs = orange(turf_range, get_turf(plant_item))
	for(var/turf/turf in turfs)
		RegisterSignal(turf, COMSIG_ATOM_ENTERED, PROC_REF(catch_entered))
		thorn_turfs |= turf

/datum/plant_trait/body/thorns/proc/catch_entered(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	if(!plant_item.loc.GetComponent(/datum/component/planter))
		return
	if(SEND_SIGNAL(plant_item.loc, COMSIG_PLANTER_PAUSE_PLANT))
		return
	var/mob/living/victim = entering
	if(!isliving(victim) || !victim.reagents || !victim.can_inject(null, 0))
		return
	var/datum/reagents/holder = plant_item.loc.reagents
	if(!holder)
		return
//Counters
	//Gloves will allow us to push past unharmed
	var/mob/living/carbon/C = victim
	if(istype(C) && C.gloves && HAS_TRAIT(C, TRAIT_PIERCEIMMUNE))
		return
//FX
	playsound(plant_item, 'sound/effects/prick.ogg', 60, TRUE)
	victim.apply_damage(1, BRUTE)
	var/matrix/o_transform = plant_item.transform
	animate(plant_item, time = 1.5, loop = 0, transform = matrix().Scale(1.07, 0.9))
	animate(time = 2, transform = o_transform)
//Logging
	var/turf/T = get_turf(victim)
	victim.investigate_log("has been pricked by [plant_item] at [AREACOORD(T)] injecting themselves with [parent.trait_power*BASE_REAGENT_TRANSFER] % of [holder.log_list()]. \
	Last fingerprint: [plant_item.fingerprintslast].", INVESTIGATE_BOTANY)
	log_combat(victim, plant_item, "activated the", null, "injecting them with [parent.trait_power*BASE_REAGENT_TRANSFER]% of [holder.log_list()]. Last fingerprint: [plant_item.fingerprintslast].")
//Reagents
	var/injecting_amount = (parent.trait_power*BASE_REAGENT_TRANSFER)*0.01
	var/fraction = max(holder.maximum_volume*injecting_amount, 1)
	holder.expose(victim, INJECT, fraction)
	holder.trans_to(victim, injecting_amount)
	to_chat(victim, span_danger("You are pricked by [plant_item]!"))

#undef BASE_REAGENT_TRANSFER
