/datum/damage_source/sharp
	armour_flag = MELEE
	var/dismemberment_multiplier = 0
	var/bleed_multiplier = 1

/datum/damage_source/sharp/after_attack_limb(
		mob/living/attacker,
		obj/item/attacking_item,
		mob/living/target,
		obj/item/bodypart/limb,
		datum/damage/damage,
		damage_amount,
		target_zone
	)
	run_bleeding(target, damage_amount, bleed_multiplier)
	run_deepen_wounds(attacker, attacking_item, target, limb, damage, damage_amount, target_zone)
	run_dismemberment(attacker, attacking_item, target, limb, damage, damage_amount, target_zone, dismemberment_multiplier)

/// Small and light but sharp weapons like knives
/datum/damage_source/sharp/light
	dismemberment_multiplier = 0.6
	bleed_multiplier = 0.8

/datum/damage_source/sharp/light/after_attack_limb(mob/living/attacker, obj/item/attacking_item, mob/living/target, obj/item/bodypart/limb, datum/damage/damage, damage_amount, target_zone)
	. = ..()
	if (attacking_item && target_zone == BODY_ZONE_PRECISE_EYES)
		attacking_item.eyestab(target, attacker)

/// Heavy and sharp weapons like large swords
/// Either by slicing or stabbing, without armour this will be likely to
/// penetrate the skin and cause internal damage and bleeding.
/datum/damage_source/sharp/heavy
	dismemberment_multiplier = 1.2
	bleed_multiplier = 1.4

/// Surgical incisions. Causes bleeding but won't deal massive amounts
/// of unpredictable internal damage.
/// Should cause extreme amounts of pain compared to other damage types
/// to enforce surgery painkilling/sleeping.
/datum/damage_source/sharp/incision
	bleed_multiplier = 1.8

/datum/damage_source/blunt
	armour_flag = MELEE

/datum/damage_source/blunt/after_attack_limb(mob/living/attacker, obj/item/attacking_item, mob/living/target, obj/item/bodypart/limb, datum/damage/damage, damage_amount, target_zone)
	run_deepen_wounds(attacker, attacking_item, target, limb, damage, damage_amount, target_zone)
	// Revolutionary remove
	var/mob/living/carbon/human/H = target
	if (attacking_item && target_zone == BODY_ZONE_HEAD && istype(H))
		if(H.mind && H.stat == CONSCIOUS && H != attacker && (H.health - (attacking_item.force * attacking_item.attack_weight)) <= 0) // rev deconversion through blunt trauma.
			var/datum/antagonist/rev/rev = H.mind.has_antag_datum(/datum/antagonist/rev)
			if(rev)
				rev.remove_revolutionary(FALSE, attacker)

/// Light and blunt weaker weapons like toolboxes
/datum/damage_source/blunt/light

/// Heavy but blunt weapons like battle hammers
/datum/damage_source/blunt/heavy

/// A constant source of damage drilling into the skin.
/// Pretty bad but respects melee armour.
/datum/damage_source/drill
	armour_flag = MELEE

/datum/damage_source/drill/after_attack_limb(
		mob/living/attacker,
		obj/item/attacking_item,
		mob/living/target,
		obj/item/bodypart/limb,
		datum/damage/damage,
		damage_amount,
		target_zone
	)
	run_bleeding(target, damage_amount, 1.8)
	run_deepen_wounds(attacker, attacking_item, target, limb, damage, damage_amount, target_zone)
	run_dismemberment(attacker, attacking_item, target, limb, damage, damage_amount, target_zone, 1.4)

/// Something pricked directly in the skin, bypasses armour
/// Ignored if the mob has TRAIT_PIERCEIMMUNE
/datum/damage_source/skin_prick

/// For when you rip a bodypart (un)cleanly off with sheer force.
/// Will force screaming
/datum/damage_source/forceful_laceration

/// Caused by impact of objects colliding with each other
/// May cause head trauma if hit on the head
/// Affected by armour
/datum/damage_source/impact
	armour_flag = MELEE

/datum/damage_source/impact/after_attack_limb(mob/living/attacker, obj/item/attacking_item, mob/living/target, obj/item/bodypart/limb, datum/damage/damage, damage_amount, target_zone)
	run_deepen_wounds(attacker, attacking_item, target, limb, damage, damage_amount, target_zone)

/// Caused by being crushed
/// Might break some bones
/datum/damage_source/crush
	armour_flag = MELEE

/datum/damage_source/crush/after_attack_limb(mob/living/attacker, obj/item/attacking_item, mob/living/target, obj/item/bodypart/limb, datum/damage/damage, damage_amount, target_zone)
	run_deepen_wounds(attacker, attacking_item, target, limb, damage, damage_amount, target_zone)

/// Caused by an object inside of a mob bursting out through their skin
/// Causes intense bleeding and internal damage
/datum/damage_source/internal_rupture

/datum/damage_source/internal_rupture/after_attack_limb(mob/living/attacker, obj/item/attacking_item, mob/living/target, obj/item/bodypart/limb, datum/damage/damage, damage_amount, target_zone)
	run_bleeding(target, damage_amount, 2)
	run_deepen_wounds(attacker, attacking_item, target, limb, damage, damage_amount, target_zone)

/// Caused by an explosion, obviously
/datum/damage_source/explosion
	armour_flag = BOMB

/// Electrical damage to a mechanical source
/datum/damage_source/electrical_damage

/// Caused by fatigue from doing an action over and over.
/// Bypasses all armour.
/datum/damage_source/fatigue

/// Damage caused by consuming something you shouldn't have. Highly likely to cause
/// internal damage and bypasses armour.
/datum/damage_source/consumption

/// Caused by accidentally burning yourself on something.
/// Will account for armour or gloves if you are wearing any and the target is a precise hand
/datum/damage_source/accidental_burn
	armour_flag = FIRE

/// Caused by external pressure
/datum/damage_source/pressure

/// Damage caused by exposure to various temperatures.
/datum/damage_source/temperature

/// Damaged caused by internal exosure to high temperatures from breathing
/// in cold/hot air.
/datum/damage_source/temperature/internal

/// Electrical damage.
/// Applies the stutter effect.
/datum/damage_source/shock

/// Damage caused by a religious source. Damage is reduced by a null rod
/// or magic protection.
/datum/damage_source/magic
	armour_flag = MAGIC

/// Abstract magic damage not blocked by a null rod
/datum/damage_source/magic/abstract
	armour_flag = null

/datum/damage_source/magic/religion

//SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK) //Only used for nanites
//target.stuttering = 20
//target.do_jitter_animation(20)
/// Damaged caused by stun shock weapons.
/// Blocked by the stamina damage flag.
/// Applies the stutter effect.
/datum/damage_source/stun
	armour_flag = STAMINA

/// Caused by chemicals injested inside the body. Bypasses armour and causes
/// internal damage.
/// Only causes damage to organic limbs
/datum/damage_source/chemical

/// Damage caused by external acid burns. Respects acid armour
/datum/damage_source/acid_burns
	armour_flag = ACID

/// Damage caused by mental trauma
/datum/damage_source/mental_health

/// Damage caused by a bullet. If not blocked by armour, will be penetrating
/// and may cause internal damage.
/datum/damage_source/bullet
	armour_flag = BULLET

/// Rubber bullets and beanbag bullets.
/datum/damage_source/bullet/beanbag

/// Unstoppable things like the immovable rod
/// This will entirely penetrate literally all armour and will rip a giant
/// hole through your body.
/datum/damage_source/bullet/unstoppable
	armour_flag = NONE

/// Laser projectiles
/datum/damage_source/laser
	armour_flag = LASER

/// Energy based projectiles
/datum/damage_source/energy
	armour_flag = ENERGY

/// Ion damage, causes empulses
/datum/damage_source/ion
	armour_flag = ENERGY

/// Caused by a mob punching another mob. Similar to blunt but with no force
/// multiplier at all (you are just using a fist).
/datum/damage_source/punch
	armour_flag = MELEE

/datum/damage_source/punch/after_attack_limb(mob/living/attacker, obj/item/attacking_item, mob/living/target, obj/item/bodypart/limb, datum/damage/damage, damage_amount, target_zone)
	run_deepen_wounds(attacker, attacking_item, target, limb, damage, damage_amount, target_zone)

/// Checks for radiation armour
/// Might cause some secondary bad effect like mutations if bad enough
/datum/damage_source/radiation_burn
	armour_flag = RAD

/// Caused by a slime attacking something. Might have digestive enzymes
/// or something.
/datum/damage_source/slime

/*
/datum/damage_source/slime/calculate_damage(mob/living/target, input_damage, target_zone, armour_penetration = 0)
	// Determine armour
	var/blocked = 0
	if (armour_flag)
		var/bio_flag = target.run_armor_check(target_zone || BODY_ZONE_CHEST, BIO, armour_penetration = armour_penetration, silent = TRUE)
		var/melee_flag = target.run_armor_check(target_zone || BODY_ZONE_CHEST, MELEE, armour_penetration = armour_penetration)
		blocked = (bio_flag + melee_flag) / 2
	if (blocked >= 100)
		return 0
	return input_damage * (1 - (blocked / 100))
*/

/// Similar to above, but specific to blobs
/datum/damage_source/blob

/*
/datum/damage_source/blob/calculate_damage(mob/living/target, input_damage, target_zone, armour_penetration = 0)
	// Determine armour
	var/blocked = 0
	if (armour_flag)
		var/bio_flag = target.run_armor_check(target_zone || BODY_ZONE_CHEST, BIO, armour_penetration = armour_penetration, silent = TRUE)
		var/melee_flag = target.run_armor_check(target_zone || BODY_ZONE_CHEST, MELEE, armour_penetration = armour_penetration)
		blocked = (bio_flag + melee_flag) / 2
	if (blocked >= 100)
		return 0
	return input_damage * (1 - (blocked / 100))
*/

/// Biohazard damage.
/datum/damage_source/biohazard
	armour_flag = BIO

/// Abstract damage. Unavoidable
/datum/damage_source/abstract

/// Damage caused from bodilly processes
/datum/damage_source/body
