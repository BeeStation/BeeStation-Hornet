#define SHOCK_DAMAGE 3

/*
	Shocks the victim, nothing too special here
*/

/datum/plant_trait/fruit/shock
	name = "Electrical Activity"
	desc = "The fruit exhibits electrical activity. Triggering the fruit will shock the target."
	genetic_cost = 3

/datum/plant_trait/fruit/shock/setup_fruit_parent()
	. = ..()
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))


/datum/plant_trait/fruit/shock/catch_activate(datum/source, datum/plant_trait/trait, mob/living/target)
	. = ..()
	if(QDELING(src))
		return
	var/turf/T = get_turf(target)
	do_sparks(3, FALSE, T)
//Cell case
	if(istype(target, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = target
		C.give(C.maxcharge*(trait_power*0.1))
		qdel(fruit_parent)
		return
//Mob case
	if(!target || !isliving(target))
		return
	var/damage = SHOCK_DAMAGE*trait_power
	target.electrocute_act(damage, T, 1, 1)
	//logging
	if(target?.ckey == fruit_parent.fingerprintslast) //Dont log self harm
		return
	if(isliving(target))
		log_combat(fruit_parent.thrownby, target, "hit", fruit_parent, "at [AREACOORD(T)] shocking them for [damage] damage!")
		target.investigate_log("has been hit by an eletric plant at [AREACOORD(T)] shocking them for [damage] damage. Last fingerprint: [fruit_parent.fingerprintslast].", INVESTIGATE_BOTANY)
	qdel(fruit_parent)

#undef SHOCK_DAMAGE
