/*
	Haunted
	Allows the artifact to be controlled by ghosts
*/
/datum/xenoartifact_trait/minor/haunted
	label_name = "Haunted"
	label_desc = "Haunted: The artifact's design seems to incorporate incorporeal elements. This will cause the artifact to move unexpectedly."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 35
	blacklist_traits = list(/datum/xenoartifact_trait/minor/haunted/instant)
	incompatabilities = TRAIT_INCOMPATIBLE_MOB
	can_pearl = FALSE
	///Refernce to move component for later cleanup
	var/datum/component/deadchat_control/controller
	///How long between moves
	var/move_delay = 8 SECONDS

/datum/xenoartifact_trait/minor/haunted/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/atom/atom_parent = component_parent.parent
	controller = atom_parent._AddComponent(list(/datum/component/deadchat_control, "democracy", list(
			"up" = CALLBACK(src, PROC_REF(haunted_step), atom_parent, NORTH),
			"down" = CALLBACK(src, PROC_REF(haunted_step), atom_parent, SOUTH),
			"left" = CALLBACK(src, PROC_REF(haunted_step), atom_parent, WEST),
			"right" = CALLBACK(src, PROC_REF(haunted_step), atom_parent, EAST),
			"activate" = CALLBACK(src, PROC_REF(activate_parent), atom_parent)), move_delay))
	addtimer(CALLBACK(src, PROC_REF(do_wail)), 35 SECONDS)
	//Landmark
	component_parent?.parent.AddElement(/datum/element/point_of_interest)

/datum/xenoartifact_trait/minor/haunted/Destroy(force, ...)
	QDEL_NULL(controller)
	return ..()

/datum/xenoartifact_trait/minor/haunted/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/storage/book/bible))
		to_chat(user, "<span class='warning'>[item] upsets the sprits of [component_parent?.parent]!</span>")
		return ..()

/datum/xenoartifact_trait/minor/haunted/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_DETECT("bible"),
	XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("allow the artifact to be moved, by ghosts, every 8 seconds"),
	XENOA_TRAIT_HINT_SOUND("ghost moaning"))

/datum/xenoartifact_trait/minor/haunted/proc/do_wail(repeat = TRUE)
	if(QDELETED(src))
		return
	var/atom/atom_parent = component_parent.parent
	if(isturf(atom_parent.loc))
		playsound(get_turf(component_parent?.parent), 'sound/spookoween/ghost_whisper_short.ogg', 30, TRUE)
	addtimer(CALLBACK(src, PROC_REF(do_wail)), 35 SECONDS)


/datum/xenoartifact_trait/minor/haunted/proc/haunted_step(atom/movable/target, dir)
	if(component_parent.calcified)
		return
	//Make any mobs drop this before it moves
	if(isliving(target.loc))
		var/mob/living/M = target.loc
		M.dropItemToGround(target)
	playsound(get_turf(target), 'sound/effects/magic.ogg', 50, TRUE)
	step(target, dir)

/datum/xenoartifact_trait/minor/haunted/proc/activate_parent()
	if(component_parent.calcified)
		return
	//Find a target
	for(var/atom/target in oview(component_parent.target_range, get_turf(component_parent?.parent)))
		component_parent.register_target(target, TRUE)
		component_parent.trigger(TRUE)
		return

//Instant variant, no move delay. Can only move when not seen
/datum/xenoartifact_trait/minor/haunted/instant
	label_name = "Haunted Δ"
	label_desc = "Haunted Δ: The artifact's design seems to incorporate incorporeal elements. This will cause the artifact to move unexpectedly, when not observed."
	move_delay = 1 SECONDS
	blacklist_traits = list(/datum/xenoartifact_trait/minor/haunted)
	conductivity = 5
	///Cooldown for the use action
	var/action_cooldown
	var/action_cooldown_time = 8 SECONDS
	///How far we look for mobs
	var/seek_distance = 9

/datum/xenoartifact_trait/minor/haunted/instant/haunted_step(atom/movable/target, dir)
	if(component_parent.calcified)
		return
	//This may seem scary, and expensive, but it's only called WHEN ghosts try to move the artifact
	var/list/mobs = oview(seek_distance, component_parent.parent)
	for(var/mob/living/M in mobs)
		if(!M.stat && M.ckey)
			return
	return ..()

/datum/xenoartifact_trait/minor/haunted/instant/activate_parent()
	if(!action_cooldown)
		action_cooldown = addtimer(CALLBACK(src, PROC_REF(reset_action_timer)), action_cooldown_time, TIMER_STOPPABLE)
		return ..()

/datum/xenoartifact_trait/minor/haunted/instant/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_DETECT("bible"),
	XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("allow the artifact to be moved, by ghosts, when no-one is looking"),
	XENOA_TRAIT_HINT_SOUND("ghost moaning"))

/datum/xenoartifact_trait/minor/haunted/instant/proc/reset_action_timer()
	if(action_cooldown)
		deltimer(action_cooldown)
	action_cooldown = null
