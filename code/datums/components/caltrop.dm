/datum/component/caltrop
	var/min_damage
	var/max_damage
	var/probability
	var/flags
	COOLDOWN_DECLARE(caltrop_cooldown)
	///given to connect_loc to listen for something moving over target
	var/static/list/crossed_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)


/datum/component/caltrop/Initialize(_min_damage = 0, _max_damage = 0, _probability = 100,  _flags = NONE)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	min_damage = _min_damage
	max_damage = max(_min_damage, _max_damage)
	probability = _probability
	flags = _flags

	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, crossed_connections)
	else
		RegisterSignal(get_turf(parent), COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

/datum/component/caltrop/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	var/atom/A = parent
	if(!A.has_gravity())
		return

	if(!prob(probability))
		return

	if(ishuman(arrived))
		var/mob/living/carbon/human/H = arrived
		if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			return

		if((flags & CALTROP_IGNORE_WALKERS) && H.m_intent == MOVE_INTENT_WALK)
			return

		var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/O = H.get_bodypart(picked_def_zone)
		if(!istype(O))
			return
		if(!IS_ORGANIC_LIMB(O))
			return

		var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))

		if(!(flags & CALTROP_BYPASS_SHOES) && (H.shoes || feetCover))
			return

		if((H.movement_type & FLYING) || !(H.mobility_flags & MOBILITY_STAND)|| H.buckled)
			return

		var/damage = rand(min_damage, max_damage)
		if(HAS_TRAIT(H, TRAIT_LIGHT_STEP))
			damage *= 0.5

		H.apply_damage(damage, BRUTE, picked_def_zone)

		if(COOLDOWN_FINISHED(src, caltrop_cooldown))
			COOLDOWN_START(src, caltrop_cooldown, 1 SECONDS) //cooldown to avoid message spam.
			if(!H.incapacitated(ignore_restraints = TRUE))
				H.visible_message("<span class='danger'>[H] steps on [A].</span>", \
						"<span class='userdanger'>You step on [A]!</span>")
			else
				H.visible_message("<span class='danger'>[H] slides on [A]!</span>", \
						"<span class='userdanger'>You slide on [A]!</span>")

		H.Paralyze(40)

/datum/component/caltrop/UnregisterFromParent()
	. = ..()
	if(ismovable(parent))
		qdel(GetComponent(/datum/component/connect_loc_behalf))
