/datum/species/zombie
	// 1spooky
	name = "High-Functioning Zombie"
	id = SPECIES_ZOMBIE
	meat = /obj/item/food/meat/slab/human/mutant/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	inherent_traits = list(
		// SHARED WITH ALL ZOMBIES
		TRAIT_NO_ZOMBIFY,
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_FAST_CUFF_REMOVAL,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_NOT_TRANSMORPHIC,
		TRAIT_NODEATH,
		TRAIT_NOHUNGER,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOSTASIS,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOSTASIS,
		// HIGH FUNCTIONING UNIQUE
		TRAIT_NOBLOOD,
	)
	mutantstomach = null
	mutantheart = null
	mutantliver = null
	mutantlungs = null
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	bodytemp_normal = T0C // They have no natural body heat, the environment regulates body temp
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_EXIST // Take damage at fire temp
	bodytemp_cold_damage_limit = MINIMUM_TEMPERATURE_TO_MOVE // take damage below minimum movement temp

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie
	)

	var/static/list/spooks = list(
		'sound/hallucinations/growl1.ogg',
		'sound/hallucinations/growl2.ogg',
		'sound/hallucinations/growl3.ogg',
		'sound/hallucinations/veryfar_noise.ogg',
		'sound/hallucinations/wail.ogg'
	)

/// Zombies do not stabilize body temperature they are the walking dead and are cold blooded
/datum/species/zombie/body_temperature_core(mob/living/carbon/human/humi)
	return

/datum/species/zombie/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/zombie/get_species_description()
	return "A rotting zombie! They descend upon Space Station Thirteen Every year to spook the crew! \"Sincerely, the Zombies!\""

/datum/species/zombie/get_species_lore()
	return list("Zombies have long lasting beef with Botanists. Their last incident involving a lawn with defensive plants has left them very unhinged.")

/datum/species/zombie/infectious
	name = "Infectious Zombie"
	id = SPECIES_ZOMBIE_INFECTIOUS
	examine_limb_id = SPECIES_ZOMBIE
	damage_modifier = 20 // 120 damage to KO a zombie, which kills it
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	var/muthands_path = /obj/item/mutant_hand/zombie
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	inherent_traits = list(
		// SHARED WITH ALL ZOMBIES
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_FAST_CUFF_REMOVAL,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_NODEATH,
		TRAIT_NOHUNGER,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOSTASIS,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		// INFECTIOUS UNIQUE
		TRAIT_STABLEHEART, // Replacement for noblood. Infectious zombies can bleed but don't need their heart.
		TRAIT_STABLELIVER, // Not necessary but for consistency with above
	)
	// Infectious zombies have slow legs
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie/infectious,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie/infectious,
	)

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/human/new_zombie, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	new_zombie.set_combat_mode(TRUE)

	// Deal with the source of this zombie corruption
	// Infection organ needs to be handled separately from mutant_organs
	// because it persists through species transitions
	var/obj/item/organ/zombie_infection/infection = new_zombie.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(isnull(infection))
		infection = new()
		infection.Insert(new_zombie)

	new_zombie.AddComponent( \
		/datum/component/mutant_hands, \
		mutant_hand_path = muthands_path, \
	)
	new_zombie.AddComponent( \
		/datum/component/regenerator, \
		regeneration_delay = 6 SECONDS, \
		brute_per_second = 0.5, \
		burn_per_second = 0.5, \
		tox_per_second = 0.5, \
		oxy_per_second = 0.25, \
		heals_wounds = TRUE, \
		outline_colour = null, \
	)

/datum/species/zombie/infectious/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	qdel(C.GetComponent(/datum/component/mutant_hands))
	qdel(C.GetComponent(/datum/component/regenerator))

/datum/species/zombie/infectious/check_roundstart_eligible()
	return FALSE

/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	return min(2 SECONDS, amount)

/datum/species/zombie/infectious/spec_life(mob/living/carbon/carbon_mob, delta_time, times_fired)
	. = ..()
	carbon_mob.set_combat_mode(TRUE) // THE SUFFERING MUST FLOW

	if(!HAS_TRAIT(carbon_mob, TRAIT_CRITICAL_CONDITION) && DT_PROB(2, delta_time))
		playsound(carbon_mob, pick(spooks), 50, TRUE, 10)

//Congrats you somehow died so hard you stopped being a zombie
/datum/species/zombie/infectious/spec_death(gibbed, mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/zombie_infection/infection
	infection = C.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(infection)
		qdel(infection)

/datum/species/zombie/infectious/viral
	name = "\improper Infected Zombie"
	id = "memezombiesfast"
	damage_modifier = 0
	inherent_biotypes = MOB_ORGANIC|MOB_UNDEAD|MOB_HUMANOID //mob organic, so still susceptible to the disease that created it
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	muthands_path = /obj/item/mutant_hand/zombie/infectious

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie/viral,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie/viral
	)

// Your skin falls off
/datum/species/human/krokodil_addict
	name = "\improper Human"
	id = SPECIES_ZOMBIE_KROKODIL
	examine_limb_id = SPECIES_HUMAN
	meat = /obj/item/food/meat/slab/human/mutant/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	examine_limb_id = SPECIES_HUMAN

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie
	)

/datum/species/human/krokodil_addict/replace_body(mob/living/carbon/target, datum/species/new_species)
	..()
	var/skintone
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		skintone = human_target.skin_tone

	for(var/obj/item/bodypart/limb as anything in target.bodyparts)
		if(IS_ORGANIC_LIMB(limb))
			if(limb.body_zone == BODY_ZONE_HEAD || limb.body_zone == BODY_ZONE_CHEST)
				limb.is_dimorphic = TRUE
			limb.skin_tone ||= skintone
			limb.limb_id = SPECIES_HUMAN
			limb.should_draw_greyscale = TRUE
			limb.name = "human [parse_zone(limb.body_zone)]"
			limb.update_limb()
