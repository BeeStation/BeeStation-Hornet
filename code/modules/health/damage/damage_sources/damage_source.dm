#define INITIAL_SETUP \
	src.transformed_damage_source = src;\
	src.damage_amount = damage_amount;\
	src.armour_penetration = 0;\
	src.target = target;\
	src.target_zone = target_zone;\
	src.weapon = null;\
	src.damage_type = damage_type;

#define CLEAR_REFERENCES \
	src.weapon = null;\
	src.target = null;

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
	/// The target zone of the attack
	var/target_zone
	/// The weapon used for the attack
	var/atom/weapon
	/// The type of damage being given to the victim
	var/damage_type

/datum/damage_source/proc/apply_direct(atom/target, damage_type, damage_amount, target_zone = null, update_health = TRUE, forced = FALSE)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	// Set the state
	INITIAL_SETUP

	// Get the thing we are actually targetting
	target.damage_get_target(src)

	// Run the armour calculation
	target.damage_run_armour(src)

	// Not enough damage
	if (damage_amount <= 0)
		CLEAR_REFERENCES
		return

	if (QDELETED(target))
		CLEAR_REFERENCES
		return

	// Apply the damage at this point
	target.damage_apply_damage(src)

	CLEAR_REFERENCES

/// Attacker may be null
/datum/damage_source/proc/deal_attack(mob/living/attacker, obj/item/attacking_item, atom/target, damage_type, damage_amount, target_zone = null, update_health = TRUE, forced = FALSE)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	// Set the state
	INITIAL_SETUP
	weapon = attacking_item

	// Determine the target_zone
	if (!target_zone)
		target_zone = ran_zone(attacker?.zone_selected || BODY_ZONE_CHEST)

	// Get the thing we are actually targetting
	target.damage_get_target(src)

	// Determine armour penetration
	if (attacking_item)
		attacking_item.damage_get_armour_penetration(src)
	else
		attacker.damage_get_armour_penetration(src)

	// Run the armour calculations
	target.damage_run_armour(src)

	// Pacifism check
	if (attacker && HAS_TRAIT(attacker, TRAIT_PACIFISM) && !ispath(damage_type, /datum/damage/stamina))
		to_chat(attacker, "<span class='notice'>You don't want to hurt anyone!</span>")
		CLEAR_REFERENCES
		return 0

	// Play the animation
	if (attacking_item)
		if (attacker)
			attacker.do_attack_animation(target, used_item = attacking_item)
		else
			attacking_item.do_attack_animation(target, used_item = attacking_item)
	else
		if (attacker)
			attacker.do_attack_animation(target, isanimal(attacker) ? pick(ATTACK_EFFECT_BITE, ATTACK_EFFECT_CLAW) : pick(ATTACK_EFFECT_KICK, ATTACK_EFFECT_PUNCH))

	if (damage_amount <= 0)
		CLEAR_REFERENCES
		return 0

	// Apply the damage at this point
	target.damage_apply_damage(src)

	// Determine armour
	//if (attacking_item && attacker)
	//	living_target.send_item_attack_message(attacking_item, attacker, parse_zone(target_zone))

	if (attacker && attacking_item)
		target.on_attacked(attacking_item, attacker)

	after_attack(attacker, attacking_item, target, GET_DAMAGE(transformed_damage_source), damage_amount, target_zone)
	if (istype(target, /obj/item/bodypart))
		var/obj/item/bodypart/part = target
		if (part.owner)
			after_attack_limb(attacker, attacking_item, part.owner, target, GET_DAMAGE(transformed_damage_source), damage_amount, target_zone)
	CLEAR_REFERENCES
	return damage_amount

/// Called after a successful attack
/datum/damage_source/proc/after_attack()
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
