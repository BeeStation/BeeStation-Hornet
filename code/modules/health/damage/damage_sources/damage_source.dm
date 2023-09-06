#define INITIAL_SETUP \
	src.transformed_damage_source = src;\
	src.damage_amount = damage_amount;\
	src.armour_penetration = 0;\
	src.target = target;

/datum/damage_source
	// ===========================
	// Initial Variables
	// ===========================

	/// The armour flag to use when calculating armour
	/// and armour penetration. If null then armour will
	/// be entirely bypassed.
	var/armour_flag = null

	// NOTE: For maximum performance of a potentially hot path, we store our data here to be passed around the damage_sources and to be
	// manipulated later on.
	// !!! This means that our damage application procs that use this must NEVER sleep. !!!

	/// The damage source instance that we should be using when applying damage. This
	/// allows things like armour to transform our damage type from sharp to blunt.
	var/transformed_damage_source
	/// The amount of damage that we are attempting to apply. Can be mutated by armour
	var/damage_amount
	/// The armour penetration value of this attack
	var/armour_penetration
	/// The target of these attacks
	var/atom/target

/datum/damage_source/proc/apply_direct(atom/target, damage_type, damage_amount, target_zone = null, update_health = TRUE, forced = FALSE)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	INITIAL_SETUP
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
		var/final_damage_amount = calculate_damage(target, null, damage_amount, target_zone)
		if (targetted_bodypart)
			damage.apply_bodypart(targetted_bodypart, final_damage_amount, update_health, forced)
		else
			damage.apply_living(target, final_damage_amount, update_health, forced)
	else
		// Determine armour
		var/final_damage_amount = calculate_damage(target, null, damage_amount, target_zone)
		// Target the whole body and apply the damage
		var/datum/damage/damage = GET_DAMAGE(damage_type)
		damage.apply_living(target, final_damage_amount, update_health, forced)

/// Attacker may be null
/datum/damage_source/proc/deal_attack(mob/living/attacker, obj/item/attacking_item, atom/target, damage_type, damage_amount, target_zone = null, update_health = TRUE, forced = FALSE)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	INITIAL_SETUP
	// Determine the target_zone
	if (!target_zone)
		target_zone = ran_zone(attacker?.zone_selected || BODY_ZONE_CHEST)

	// Determine armour penetration
	if (attacking_item)
		attacking_item.damage_get_armour_penetration(src)
	else
		attacker.damage_get_armour_penetration(src)

	var/final_damage_amount = calculate_damage(target, attacking_item, isnull(damage_amount) ? attacking_item?.force : damage_amount, target_zone, armour_penetration_value)
	if (final_damage_amount <= 0)
		return
	// Pacifism check
	if (attacker && HAS_TRAIT(attacker, TRAIT_PACIFISM) && final_damage_amount > 0 && ispath(damage_type, /datum/damage/stamina))
		to_chat(attacker, "<span class='notice'>You don't want to hurt anyone!</span>")
		return
	// Play the animation
	if (attacking_item)
		if (attacker)
			attacker.do_attack_animation(target, used_item = attacking_item)
		else
			attacking_item.do_attack_animation(target, used_item = attacking_item)
	else
		if (attacker)
			attacker.do_attack_animation(target, isanimal(attacker) ? pick(ATTACK_EFFECT_BITE, ATTACK_EFFECT_CLAW) : pick(ATTACK_EFFECT_KICK, ATTACK_EFFECT_PUNCH))
	// Get the damage applyer
	var/datum/damage/damage = damage_type
	if (!istype(damage))
		damage = GET_DAMAGE(damage_type)
	// Deal the damage
	if (isliving(target))
		var/mob/living/living_target = target
		// Get the bodypart that we are going to target
		var/obj/item/bodypart/targetted_part = living_target.get_bodypart(target_zone)
		if (!targetted_part)
			targetted_part = living_target.get_bodypart(BODY_ZONE_CHEST)
		// Determine armour
		if (attacking_item && attacker)
			living_target.send_item_attack_message(attacking_item, attacker, parse_zone(target_zone))
		if (targetted_part)
			damage.apply_bodypart(targetted_part, final_damage_amount, update_health, forced)
			after_attack_limb(attacker, attacking_item, target, targetted_part, damage, final_damage_amount, target_zone)
			if (attacker && attacking_item)
				target.on_attacked(attacking_item, attacker)
		else
			damage.apply_living(target, final_damage_amount, update_health, forced)
			if (attacker && attacking_item)
				target.on_attacked(attacking_item, attacker)
		after_attack(attacker, attacking_item, target, damage, final_damage_amount, target_zone)
	else if(isobj(target))
		// Send straight to damaging
		damage.apply_object(target, final_damage_amount)
	else
		CRASH("Cannot attack non-objects and non-living entities as they do not recieve damage.")

/// Get the amount of damage blocked by armour. 0 to 100.
/datum/damage_source/proc/get_armour_block(atom/target, input_damage, target_zone, armour_penetration = 0)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!armour_flag)
		return 0
	// Determine armour
	if (isliving(target))
		var/mob/living/living_target = target
		return living_target.run_armor_check(target_zone || BODY_ZONE_CHEST, armour_flag, armour_penetration = armour_penetration)
	if (isobj(target))
		var/obj/object_target = target
		return object_target.run_obj_armor(input_damage, BRUTE, armour_flag, armour_penetration = armour_penetration)
	return 0

/// Calculate the damage caused by a specific attack
/datum/damage_source/proc/calculate_damage(atom/target, obj/item/weapon, input_damage, target_zone, armour_penetration = 0)
	SHOULD_NOT_OVERRIDE(TRUE)
	// Determine armour
	var/blocked = get_armour_block(target, input_damage, target_zone, armour_penetration)
	if (blocked >= 100)
		return 0
	if (isliving(target) && weapon)
		var/mob/living/living_target = target
		return input_damage * (1 - (blocked / 100)) * living_target.check_weakness(weapon, target)
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
	SHOULD_NOT_OVERRIDE(TRUE)
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
			attacking_item.add_mob_blood(target)
			playsound(get_turf(target), attacking_item.get_dismember_sound(), 80, 1)

/// Causes bleeding on the target
/datum/damage_source/proc/run_bleeding(
		atom/target,
		damage_amount,
		intensity_multiplier = 1
	)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!damage_amount)
		return
	target.apply_bleeding((damage_amount * intensity_multiplier) * rand(2, 4) / 10, damage_amount * intensity_multiplier)

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
	SHOULD_NOT_OVERRIDE(TRUE)
	// Check if we are bleeding already
	if (!istype(target) || (target.bleed_rate < damage_amount && !force))
		return
	// Get blood on themselves
	target.add_mob_blood(target)
	run_apply_blood(target, target, BODY_ZONE_CHEST)
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
			run_apply_blood(target, human_attacker, target_zone)

/// Apply blood from a source to a target
/datum/damage_source/proc/run_apply_blood(mob/living/blood_source, mob/living/carbon/human/blood_target, def_zone)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!istype(blood_target))
		return
	switch (def_zone)
		if (BODY_ZONE_HEAD)
			if(blood_target.wear_mask)
				blood_target.wear_mask.add_mob_blood(blood_source)
				blood_target.update_inv_wear_mask()
			if(blood_target.wear_neck)
				blood_target.wear_neck.add_mob_blood(blood_source)
				blood_target.update_inv_neck()
			if(blood_target.head)
				blood_target.head.add_mob_blood(blood_source)
				blood_target.update_inv_head()
		if (BODY_ZONE_CHEST)
			if(blood_target.wear_suit)
				blood_target.wear_suit.add_mob_blood(blood_source)
				blood_target.update_inv_wear_suit()
			if(blood_target.w_uniform)
				blood_target.w_uniform.add_mob_blood(blood_source)
				blood_target.update_inv_w_uniform()

/// Force the target to say their message
/datum/damage_source/proc/run_force_say(mob/living/carbon/human/target, damage_amount)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!istype(target))
		return
	if (damage_amount > 10 || damage_amount > 10 && prob(33))
		target.force_say()
