/datum/component/caltrop
	var/min_damage
	var/max_damage
	var/probability
	var/flags
	COOLDOWN_DECLARE(caltrop_cooldown)


/datum/component/caltrop/Initialize(_min_damage = 0, _max_damage = 0, _probability = 100,  _flags = NONE)
	min_damage = _min_damage
	max_damage = max(_min_damage, _max_damage)
	probability = _probability
	flags = _flags

	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED), .proc/Crossed)

/datum/component/caltrop/proc/Crossed(datum/source, atom/movable/AM)
	var/atom/A = parent
	if(!A.has_gravity())
		return

	if(!prob(probability))
		return

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			return

		if((flags & CALTROP_IGNORE_WALKERS) && H.m_intent == MOVE_INTENT_WALK)
			return

		var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/O = H.get_bodypart(picked_def_zone)
		if(!istype(O))
			return
		if(O.status == BODYPART_ROBOTIC)
			return

		var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))

		if(!(flags & CALTROP_BYPASS_SHOES) && (H.shoes || feetCover))
			return

		if((H.movement_type & FLYING) || !(H.mobility_flags & MOBILITY_STAND)|| H.buckled)
			return

		var/damage = rand(min_damage, max_damage)
		if(HAS_TRAIT(H, TRAIT_LIGHT_STEP))
			damage *= 0.5
		if(is_species(H, /datum/species/squid))
			damage *= 1.3
		H.apply_damage(damage, BRUTE, picked_def_zone)

		if(COOLDOWN_FINISHED(src, caltrop_cooldown))
			COOLDOWN_START(src, caltrop_cooldown, 1 SECONDS) //cooldown to avoid message spam.
			if(!H.incapacitated(ignore_restraints = TRUE))
				H.visible_message("<span class='danger'>[H] steps on [A].</span>", \
						"<span class='userdanger'>You step on [A]!</span>")
			else
				H.visible_message("<span class='danger'>[H] slides on [A]!</span>", \
						"<span class='userdanger'>You slide on [A]!</span>")

		if(is_species(H, /datum/species/squid))
			H.Paralyze(10)
		else
			H.Paralyze(40)
