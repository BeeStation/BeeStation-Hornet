#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin

/datum/species/zombie
	// 1spooky
	name = "\improper High-Functioning Zombie"
	id = "zombie"
	sexes = 0
	meat = /obj/item/food/meat/slab/human/mutant/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	species_traits = list(
		NOZOMBIE,
		NOTRANSSTING
	)
	inherent_traits = list(
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_FAST_CUFF_REMOVAL,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_NODEATH,
		TRAIT_NOHUNGER,
		TRAIT_NOMETABOLISM,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOSTASIS,
		TRAIT_NOBLOOD,
	)
	mutantstomach = null
	mutantheart = null
	mutantliver = null
	mutantlungs = null
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	bodytemp_normal = T0C // They have no natural body heat, the environment regulates body temp
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_EXIST // Take damage at fire temp
	bodytemp_cold_damage_limit = MINIMUM_TEMPERATURE_TO_MOVE // take damage below minimum movement temp

	species_chest = /obj/item/bodypart/chest/zombie
	species_head = /obj/item/bodypart/head/zombie
	species_l_arm = /obj/item/bodypart/l_arm/zombie
	species_r_arm = /obj/item/bodypart/r_arm/zombie
	species_l_leg = /obj/item/bodypart/l_leg/zombie
	species_r_leg = /obj/item/bodypart/r_leg/zombie

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
	name = "\improper Infectious Zombie"
	id = "memezombies"
	examine_limb_id = "zombie"
	mutanthands = /obj/item/zombie_hand
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 1.6
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	/// The rate the zombies regenerate at
	var/heal_rate = 0.5
	/// The cooldown before the zombie can start regenerating
	COOLDOWN_DECLARE(regen_cooldown)

/datum/species/zombie/infectious/check_roundstart_eligible()
	return FALSE

/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(20, amount)

/datum/species/zombie/infectious/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE)
	. = ..()
	if(.)
		COOLDOWN_START(src, regen_cooldown, REGENERATION_DELAY)

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C, delta_time, times_fired)
	. = ..()
	C.set_combat_mode(TRUE) // THE SUFFERING MUST FLOW

	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(COOLDOWN_FINISHED(src, regen_cooldown))
		var/heal_amt = heal_rate
		if(HAS_TRAIT(C, TRAIT_CRITICAL_CONDITION))
			heal_amt *= 2
		C.heal_overall_damage(heal_amt * delta_time, heal_amt * delta_time)
		C.adjustToxLoss(-heal_amt * delta_time)
		C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -heal_amt * delta_time)
	if(!HAS_TRAIT(C, TRAIT_CRITICAL_CONDITION) && DT_PROB(2, delta_time))
		playsound(C, pick(spooks), 50, TRUE, 10)

//Congrats you somehow died so hard you stopped being a zombie
/datum/species/zombie/infectious/spec_death(gibbed, mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/zombie_infection/infection
	infection = C.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(infection)
		qdel(infection)

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	// Deal with the source of this zombie corruption
	//  Infection organ needs to be handled separately from mutant_organs
	//  because it persists through species transitions
	var/obj/item/organ/zombie_infection/infection
	infection = C.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new()
		infection.Insert(C)

/datum/species/zombie/infectious/viral
	name = "\improper Infected Zombie"
	id = "memezombiesfast"
	armor = 0
	speedmod = 0
	inherent_biotypes = list(MOB_ORGANIC, MOB_UNDEAD, MOB_HUMANOID) //mob organic, so still susceptible to the disease that created it
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	mutanthands = /obj/item/zombie_hand/infectious

// Your skin falls off
/datum/species/human/krokodil_addict
	name = "\improper Human"
	id = "goofzombies"
	meat = /obj/item/food/meat/slab/human/mutant/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	examine_limb_id = SPECIES_HUMAN

	species_chest = /obj/item/bodypart/chest/zombie
	species_head = /obj/item/bodypart/head/zombie
	species_l_arm = /obj/item/bodypart/l_arm/zombie
	species_r_arm = /obj/item/bodypart/r_arm/zombie
	species_l_leg = /obj/item/bodypart/l_leg/zombie
	species_r_leg = /obj/item/bodypart/r_leg/zombie

/datum/species/human/krokodil_addict/replace_body(mob/living/carbon/C, datum/species/new_species)
	..()
	var/skintone
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		skintone = H.skin_tone

	for(var/obj/item/bodypart/BP as() in C.bodyparts)
		if(IS_ORGANIC_LIMB(BP))
			if(BP.body_zone == BODY_ZONE_HEAD || BP.body_zone == BODY_ZONE_CHEST)
				BP.is_dimorphic = TRUE
			BP.skin_tone ||= skintone
			BP.limb_id = SPECIES_HUMAN
			BP.should_draw_greyscale = TRUE
			BP.name = "human [parse_zone(BP.body_zone)]"
			BP.update_limb()


#undef REGENERATION_DELAY
