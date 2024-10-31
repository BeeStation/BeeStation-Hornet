/*
	Destabilizing
	Send the target to the shadow realm
*/
/datum/xenoartifact_trait/major/shadow_realm
	label_name = "Destabilizing"
	label_desc = "Destabilizing: The artifact seems to contain destabilizing components. Triggering these components will cause the artifact transport the target to another realm."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	rarity = XENOA_TRAIT_WEIGHT_EPIC
	weight = 36
	conductivity = 36

/datum/xenoartifact_trait/major/shadow_realm/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	GLOB.destabliization_exits += component_parent?.parent

/datum/xenoartifact_trait/major/shadow_realm/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	GLOB.destabliization_exits -= component_parent.parent
	return ..()

/datum/xenoartifact_trait/major/shadow_realm/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/movable/target in focus)
		if(target.anchored)
			continue
		//handle being held
		var/atom/movable/movable = component_parent.parent
		if(!isturf(movable.loc) && locate(movable.loc) in focus)
			if(isliving(movable.loc))
				var/mob/living/L = movable.loc
				L.dropItemToGround(movable, TRUE)
			else
				movable.forceMove(get_turf(movable.loc))
		//Banish target
		target.forceMove(pick(GLOB.destabilization_spawns))
	dump_targets()
	clear_focus()
