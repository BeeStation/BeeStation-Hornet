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
	else
		if (attacker)
			attacker.do_attack_animation(target, isanimal(attacker) ? pick(ATTACK_EFFECT_BITE, ATTACK_EFFECT_CLAW) : pick(ATTACK_EFFECT_KICK, ATTACK_EFFECT_PUNCH))
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
		var/armour_penetration_value = attacking_item?.armour_penetration
		if (isanimal(attacker))
			var/mob/living/simple_animal/animal_attacker = attacker
			armour_penetration_value ||= animal_attacker.armour_penetration
		var/final_damage_amount = calculate_damage(living_target, isnull(damage_amount) ? attacking_item?.force : damage_amount, target_zone, armour_penetration_value)
		if (final_damage_amount <= 0)
			return
		if (attacking_item && attacker)
			living_target.send_item_attack_message(attacking_item, attacker, parse_zone(target_zone))
		// Get the damage applyer
		var/datum/damage/damage = damage_type
		if (!istype(damage))
			damage = GET_DAMAGE(damage_type)
		if (targetted_part)
			damage.apply_bodypart(targetted_part, final_damage_amount, update_health, forced)
			after_attack_limb(attacker, attacking_item, target, targetted_part, damage, final_damage_amount, target_zone)
		else
			damage.apply_living(target, final_damage_amount, update_health, forced)
		after_attack(attacker, attacking_item, target, damage, final_damage_amount, target_zone)
	else
		CRASH("Not implemented")

/// Get the amount of damage blocked by armour. 0 to 100.
/datum/damage_source/proc/get_armour_block(mob/living/target, input_damage, target_zone, armour_penetration = 0)
	// Determine armour
	if (armour_flag)
		return target.run_armor_check(target_zone || BODY_ZONE_CHEST, armour_flag, armour_penetration = armour_penetration)
	return 0

/// Calculate the damage caused by a specific attack
/datum/damage_source/proc/calculate_damage(mob/living/target, input_damage, target_zone, armour_penetration = 0)
	// Determine armour
	var/blocked = get_armour_block(target, input_damage, target_zone, armour_penetration)
	if (blocked >= 100)
		return 0
	return input_damage * (1 - (blocked / 100))

/// Called after a successful attack
/datum/damage_source/proc/after_attack(
		mob/living/attacker,
		obj/item/attacking_item,
		atom/target,
		datum/damage/damage,
		damage_amount,
		target_zone
	)
	return

/// Called after a specific limb was attacked
/datum/damage_source/proc/after_attack_limb(
		mob/living/attacker,
		obj/item/attacking_item,
		mob/living/target,
		obj/item/bodypart/limb,
		datum/damage/damage,
		damage_amount,
		target_zone
	)
	return

/// Run dismemberment checks after a specific limb was attacked
/datum/damage_source/proc/run_dismemberment(
		mob/living/attacker,
		obj/item/attacking_item,
		mob/living/target,
		obj/item/bodypart/limb,
		datum/damage/damage,
		damage_amount,
		target_zone,
		multipler = 1
	)
	if (!attacking_item || !damage_amount)
		return
	var/dismemberthreshold = limb.max_damage * 2 - (limb.get_damage() + ((attacking_item.w_class - 3) * 10) + ((attacking_item.attack_weight - 1) * 15))
	if(HAS_TRAIT(target, TRAIT_EASYDISMEMBER))
		dismemberthreshold -= 50
	dismemberthreshold = min(((limb.max_damage * 2) - limb.get_damage()), dismemberthreshold) //makes it so limbs wont become immune to being dismembered if the item is sharp
	if(target.stat == DEAD)
		dismemberthreshold = dismemberthreshold / 3
	if(multipler * damage_amount >= dismemberthreshold && damage_amount >= 10)
		if(limb.dismember(damage))
			attacking_item.add_mob_blood(src)
			playsound(get_turf(src), attacking_item.get_dismember_sound(), 80, 1)

/// Causes bleeding on the target
/datum/damage_source/proc/run_bleeding(
		mob/living/carbon/human/target,
		damage_amount,
		intensity_multiplier = 1
	)
	if (!istype(target) || !damage_amount)
		return
	target.bleed_rate = max(min(target.bleed_rate + (damage_amount * intensity_multiplier) * rand(4, 8) / 10, damage_amount * intensity_multiplier), target.bleed_rate )

/// Deepends any pre-existing wounds and causes blood to splatter
/// if they are already bleeding.
/// Doesn't cause bleeding itself.
/datum/damage_source/proc/run_deepen_wounds(
		mob/living/attacker,
		obj/item/attacking_item,
		mob/living/carbon/human/target,
		datum/damage/damage,
		damage_amount,
		target_zone,
		force = FALSE
	)
	// Check if we are bleeding already
	if (!istype(target) || (target.bleed_rate < damage_amount && !force))
		return
	// Get blood on themselves
	target.add_mob_blood(target)
	if(target_zone == BODY_ZONE_HEAD)
		if(target.wear_mask)
			target.wear_mask.add_mob_blood(target)
			target.update_inv_wear_mask()
		if(target.wear_neck)
			target.wear_neck.add_mob_blood(target)
			target.update_inv_neck()
		if(target.head)
			target.head.add_mob_blood(target)
			target.update_inv_head()
	// Get our location
	var/turf/location = get_turf(target)
	if (!location)
		return
	// Add blood to the surrounding location
	target.add_splatter_floor(location)
	// Check if we are in range
	if (attacker && get_dist(attacker, target) <= 1)
		attacker.add_mob_blood(target)
		if (ishuman(attacker))
			var/mob/living/carbon/human/human_attacker = attacker
			if(target_zone == BODY_ZONE_HEAD)
				if(human_attacker.wear_mask)
					human_attacker.wear_mask.add_mob_blood(target)
					human_attacker.update_inv_wear_mask()
				if(human_attacker.wear_neck)
					human_attacker.wear_neck.add_mob_blood(target)
					human_attacker.update_inv_neck()
				if(human_attacker.head)
					human_attacker.head.add_mob_blood(target)
					human_attacker.update_inv_head()
