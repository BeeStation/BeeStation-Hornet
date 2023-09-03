/datum/damage_source/sharp
	armour_flag = MELEE

/// Small and light but sharp weapons like knives
/datum/damage_source/sharp/light

/// Heavy and sharp weapons like large swords
/// Either by slicing or stabbing, without armour this will be likely to
/// penetrate the skin and cause internal damage and bleeding.
/datum/damage_source/sharp/heavy

/// Surgical incisions. Causes bleeding but won't deal massive amounts
/// of unpredictable internal damage.
/// Should cause extreme amounts of pain compared to other damage types
/// to enforce surgery painkilling/sleeping.
/datum/damage_source/sharp/incision

/datum/damage_source/blunt
	armour_flag = MELEE

/// Light and blunt weaker weapons like toolboxes
/datum/damage_source/blunt/light

/// Heavy but blunt weapons like battle hammers
/datum/damage_source/blunt/heavy

/// A constant source of damage drilling into the skin.
/// Pretty bad but respects melee armour.
/datum/damage_source/drill
	armour_flag = MELEE

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

/// Caused by being crushed
/datum/damage_source/crush
	armour_flag = MELEE

/// Caused by an object inside of a mob bursting out through their skin
/// Causes intense bleeding and internal damage
/datum/damage_source/internal_rupture

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

/// Checks for radiation armour
/// Might cause some secondary bad effect like mutations if bad enough
/datum/damage_source/radiation_burn
	armour_flag = RAD

/// Caused by a slime attacking something. Might have digestive enzymes
/// or something.
/datum/damage_source/slime

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

/// Similar to above, but specific to blobs
/datum/damage_source/blob

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

/// Biohazard damage.
/datum/damage_source/biohazard
	armour_flag = BIO

/// Abstract damage. Unavoidable
/datum/damage_source/abstract

/// Damage caused from bodilly processes
/datum/damage_source/body
