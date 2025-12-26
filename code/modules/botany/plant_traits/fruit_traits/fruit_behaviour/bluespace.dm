/*
	Bluespace Activity, this trait makes the fruit teleport targets.
*/

/datum/plant_trait/fruit/bluespace
	name = "Bluespace Activity"
	desc = "The fruit exhibits bluespace activity. Triggering the fruit will teleport the target \
	to a random location nearby, or the fruit itself if there is no target."
	///How far we teleport, normally
	var/teleport_radius = 10

/datum/plant_trait/fruit/bluespace/setup_fruit_parent()
	. = ..()
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))


/datum/plant_trait/fruit/bluespace/catch_activate(datum/source, datum/plant_trait/trait, mob/living/target)
	. = ..()
	if(QDELING(src))
		return
	var/atom/movable/focus = target
	if(!target || !isliving(target))
		focus = fruit_parent //If there's nothing to TP, TP ourselves
	var/turf/T = get_turf(focus)
	new /obj/effect/decal/cleanable/molten_object(T) //Leave a pile of goo behind for dramatic effect...
	do_teleport(focus, T, teleport_radius*trait_power, channel = TELEPORT_CHANNEL_BLUESPACE)
	//logging
	if(target?.ckey == fruit_parent.fingerprintslast) //Dont log self harm
		return
	if(isliving(target))
		log_combat(fruit_parent.thrownby, target, "hit", fruit_parent, "at [AREACOORD(T)] teleporting them to [AREACOORD(target)]")
		target.investigate_log("has been hit by a bluespace plant at [AREACOORD(T)] teleporting them to [AREACOORD(target)]. Last fingerprint: [fruit_parent.fingerprintslast].", INVESTIGATE_BOTANY)
