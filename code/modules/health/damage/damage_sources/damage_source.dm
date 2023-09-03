/datum/damage_source
	var/armour_flag = null

/datum/damage_source/proc/apply_direct(mob/living/target, damage_type, damage_amount, target_zone = null, update_health = TRUE, forced = FALSE)
	if (target_zone)
		// Apply the damage
		var/datum/damage/damage = GET_DAMAGE(damage_type)
		// Target a specific bodypart
		var/obj/item/bodypart/targetted_bodypart = target.get_bodypart(check_zone(target_zone))
		if (!targetted_bodypart)
			if (iscarbon(target))
				var/mob/living/carbon/carbon_target = target
				if (!length(carbon_target.bodyparts))
					damage.apply_living(target, damage_amount, update_health, forced)
					return
				targetted_bodypart = pick(carbon_target.bodyparts)
		var/final_damage_amount = calculate_damage(target, damage_amount, target_zone)
		if (targetted_bodypart)
			damage.apply_bodypart(targetted_bodypart, final_damage_amount, update_health, forced)
		else
			damage.apply_living(target, final_damage_amount, update_health, forced)
	else
		// Determine armour
		var/final_damage_amount = calculate_damage(target, damage_amount, target_zone)
		// Target the whole body and apply the damage
		var/datum/damage/damage = GET_DAMAGE(damage_type)
		damage.apply_living(target, final_damage_amount, update_health, forced)

/// Attacker may be null
/datum/damage_source/proc/deal_attack(mob/living/attacker, obj/item/attacking_item, atom/target, damage_type, damage_amount, target_zone = null, update_health = TRUE, forced = FALSE)
	// Play the animation
	if (attacking_item)
		if (attacker)
			attacker.do_attack_animation(target, used_item = attacking_item)
		else
			attacking_item.do_attack_animation(target, used_item = attacking_item)
	// Determine the target_zone
	if (!target_zone)
		target_zone = ran_zone(attacker?.zone_selected || BODY_ZONE_CHEST)
	if (isliving(target))
		var/mob/living/living_target = target
		// Get the bodypart that we are going to target
		var/obj/item/bodypart/targetted_part = living_target.get_bodypart(target_zone)
		if (!targetted_part)
			targetted_part = living_target.get_bodypart(BODY_ZONE_CHEST)
		// Determine armour
		var/final_damage_amount = calculate_damage(living_target, isnull(damage_amount) ? attacking_item?.force : damage_amount, target_zone, attacking_item?.armour_penetration)
		// Get the damage applyer
		var/datum/damage/damage = damage_type
		if (!istype(damage))
			damage = GET_DAMAGE(damage_type)
		if (targetted_part)
			damage.apply_bodypart(targetted_part, final_damage_amount, update_health, forced)
		else
			damage.apply_living(target, final_damage_amount, update_health, forced)
	else
		CRASH("Not implemented")

/datum/damage_source/proc/calculate_damage(mob/living/target, input_damage, target_zone, armour_penetration = 0)
	// Determine armour
	var/blocked = 0
	if (armour_flag)
		blocked = target.run_armor_check(target_zone || BODY_ZONE_CHEST, armour_flag, armour_penetration = armour_penetration)
	if (blocked >= 100)
		return 0
	return input_damage * (1 - (blocked / 100))
