/*
	Hollow
	Captures the target for an amount of time
*/
/datum/xenoartifact_trait/major/hollow
	material_desc = "hollow"
	label_name = "Hollow"
	label_desc = "Hollow: The artifact seems to contain hollow components. Triggering these components will capture the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = -15
	///Maximum time we hold people for
	var/hold_time = 15 SECONDS

/datum/xenoartifact_trait/major/hollow/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		if(ismovable(target))
			var/atom/movable/M = target
			if(M.anchored)
				unregister_target(target)
				continue
			var/atom/movable/movable = component_parent.parent
			//handle being held
			if(!isturf(movable.loc) && locate(movable.loc) in focus)
				if(isliving(movable.loc))
					var/mob/living/L = movable.loc
					L.dropItemToGround(movable, TRUE)
				else
					movable.forceMove(get_turf(movable.loc))
			M.forceMove(movable)
			//Buckle targets to artifact
			movable.buckle_mob(M)
			//Paralyze so they don't break shit, I know they would if they were able to move
			if(isliving(M))
				var/mob/living/L = M
				L.Paralyze(hold_time*(component_parent.trait_strength/100), ignore_canstun = TRUE)
			//Add timer to undo this - becuase the hold time is longer than an actual artifact cooldown, we need to do this per-mob
			addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/xenoartifact_trait, un_trigger), M), hold_time*(component_parent.trait_strength/100))
		else
			unregister_target(target)
	clear_focus()

/datum/xenoartifact_trait/major/hollow/un_trigger(atom/override, handle_parent = FALSE, did_cuff)
	focus = override ? list(override) : targets
	if(!length(focus))
		return ..()
	var/atom/movable/movable = component_parent.parent
	movable.unbuckle_all_mobs()
	for(var/atom/movable/target in focus)
		if(target.loc == movable) //If they somehow get out
			target.forceMove(get_turf(movable))
			if(isliving(target))
				var/mob/living/L = target
				L.Knockdown(2 SECONDS)
	return ..()

/datum/xenoartifact_trait/major/hollow/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)
