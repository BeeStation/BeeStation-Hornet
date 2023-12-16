///This component allows something to be when crossed, for example for cockroaches.
/datum/component/squashable
	///Chance on crossed to be squashed
	var/squash_chance = 50
	///How much brute is applied when mob is squashed
	var/squash_damage = 1
	///Squash flags, for extra checks etcetera.
	var/squash_flags = NONE
	///Special callback to call on squash instead, for things like hauberoach
	var/datum/callback/on_squash_callback
	///signal list given to connect_loc
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

/datum/component/squashable/Initialize(squash_chance, squash_damage, squash_flags, squash_callback)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(squash_chance)
		src.squash_chance = squash_chance
	if(squash_damage)
		src.squash_damage = squash_damage
	if(squash_flags)
		src.squash_flags = squash_flags
	if(!src.on_squash_callback && squash_callback)
		on_squash_callback = CALLBACK(parent, squash_callback)

	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/squashable/UnregisterFromParent()
	. = ..()
	qdel(GetComponent(/datum/component/connect_loc_behalf))


///Handles the squashing of the mob
/datum/component/squashable/proc/on_entered(datum/source, atom/movable/crossing_movable, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(parent == crossing_movable)
		return

	var/mob/living/parent_as_living = parent

	if(squash_flags & SQUASHED_SHOULD_BE_DOWN && parent_as_living.resting)
		return

	var/should_squash = prob(squash_chance)

	if(should_squash && on_squash_callback)
		if(on_squash_callback.Invoke(parent_as_living, crossing_movable))
			return //Everything worked, we're done!

	if(isliving(crossing_movable))
		var/mob/living/crossing_mob = crossing_movable
		if(crossing_mob.mob_size > MOB_SIZE_SMALL && !(crossing_mob.movement_type & FLYING))
			if(HAS_TRAIT(crossing_mob, TRAIT_PACIFISM))
				crossing_mob.visible_message("<span class='notice'>[crossing_mob] carefully steps over [parent_as_living].</span>", "<span class='notice'>You carefully step over [parent_as_living] to avoid hurting it.</span>")
				return
			if(should_squash)
				crossing_mob.visible_message("<span class='notice'>[crossing_mob] squashed [parent_as_living].</span>", "<span class='notice'>You squashed [parent_as_living].</span>")
				Squish(parent_as_living)
			else
				parent_as_living.visible_message("<span class='notice'>[parent_as_living] avoids getting crushed.</span>")

	if(isstructure(crossing_movable) && !crossing_movable.anchored)
		if(should_squash)
			crossing_movable.visible_message("<span class='notice'>[parent_as_living] is crushed under [crossing_movable].</span>")
			Squish(parent_as_living)
		else
			parent_as_living.visible_message("<span class='notice'>[parent_as_living] avoids getting crushed.</span>")

/datum/component/squashable/proc/Squish(mob/living/target)
	if(squash_flags & SQUASHED_SHOULD_BE_GIBBED)
		target.gib()
	else
		target.adjustBruteLoss(squash_damage)
