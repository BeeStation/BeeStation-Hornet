/mob/living/can_zFall(turf/source, turf/target, direction)
	if(!..())
		return FALSE
	if(buckled && !buckled.can_zFall(source, target, direction))
		return FALSE
	return TRUE

/mob/living/onZImpact(turf/T, levels)
	if(!isgroundlessturf(T))
		ZImpactDamage(T, levels)
		if(pulling)
			stop_pulling()
		if(buckled)
			buckled.unbuckle_mob(src)
	return ..()

/// The function responsible for determining the total damage for a zfall impact
/// The goal here:
/// 1 level: Your legs are mildly injured. Probably a bit slow
/// 2 levels: Your legs are broken, but you are still conscious
/// 3+ levels: You're dead/near dead
/mob/living/proc/get_distributed_zimpact_damage(levels)
	return (levels * 15) ** 1.4

/// Called when a successful zimpact (landing) occurs
/mob/living/proc/ZImpactDamage(turf/T, levels)
	apply_general_zimpact_damage(T, levels)

/// Generic proc for most living things taking fall damage. Will attempt splitting between legs, if the mob has any.
/mob/living/proc/apply_general_zimpact_damage(turf/T, levels)
	visible_message("<span class='danger'>[src] falls [levels] level\s into [T] with a sickening noise!</span>")
	var/amount_total = get_distributed_zimpact_damage(levels)
	var/total_damage_percent_left = 1
	var/obj/item/bodypart/left_leg = get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/right_leg = get_bodypart(BODY_ZONE_R_LEG)
	if(left_leg && !left_leg.disabled)
		total_damage_percent_left -= 0.45
		apply_damage(amount_total * 0.45, BRUTE, BODY_ZONE_L_LEG)
	if(right_leg && !right_leg.disabled)
		total_damage_percent_left -= 0.45
		apply_damage(amount_total * 0.45, BRUTE, BODY_ZONE_R_LEG)
	adjustBruteLoss(amount_total * total_damage_percent_left)
	Knockdown(levels * 50)

// Let the species handle it instead
/mob/living/carbon/human/ZImpactDamage(turf/T, levels)
	var/datum/species/species_datum = dna?.species
	if(!istype(species_datum))
		return ..()
	species_datum.z_impact_damage(src, T, levels)
