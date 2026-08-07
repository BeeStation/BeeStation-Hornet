/*
	Obstructing
	Builds forcefields around the artifact
*/
/datum/xenoartifact_trait/major/forcefield
	label_name = "Obstructing"
	label_desc = "Obstructing: The artifact seems to contain obstructing components. Triggering these components will cause the artifact to build walls around itself."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 33
	///What wall size are we making?
	var/wall_size
	///Max time we keep walls around for
	var/wall_time = 8 SECONDS

/datum/xenoartifact_trait/major/forcefield/New(atom/_parent)
	. = ..()
	wall_size = pick(1, 2, 3)

/datum/xenoartifact_trait/major/forcefield/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/time = wall_time*(component_parent.trait_strength/100)
	//Don't use a switch case, we just pass through the ifs and add walls as we go
	if(wall_size >= 1)
		new /obj/effect/forcefield/xenoartifact_type(get_turf(component_parent.parent), time)
	if(wall_size >= 2)
		//If we're not making a symetrical design, pick a random orientation
		var/outcome = pick(0, 1)
		if(outcome || wall_size >= 3)
			new /obj/effect/forcefield/xenoartifact_type(get_step(component_parent.parent, NORTH), time)
			new /obj/effect/forcefield/xenoartifact_type(get_step(component_parent.parent, SOUTH), time)
		else
			new /obj/effect/forcefield/xenoartifact_type(get_step(component_parent.parent, EAST), time)
			new /obj/effect/forcefield/xenoartifact_type(get_step(component_parent.parent, WEST), time)
	if(wall_size >= 3)
		new /obj/effect/forcefield/xenoartifact_type(get_step(component_parent.parent, WEST), time)
		new /obj/effect/forcefield/xenoartifact_type(get_step(component_parent.parent, EAST), time)

/datum/xenoartifact_trait/major/forcefield/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED)

//Special wall type for artifact. Throw any extra code or special logic in here
/obj/effect/forcefield/xenoartifact_type
	desc = "An impenetrable artifact wall."
