#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin

/datum/species/zombie
	// 1spooky
	name = "\improper High-Functioning Zombie"
	id = "zombie"
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	species_traits = list(NOBLOOD,NOZOMBIE,NOTRANSSTING)
	inherent_traits = list(TRAIT_TOXIMMUNE,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_EASYDISMEMBER,\
	TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NODEATH,TRAIT_FAKEDEATH,TRAIT_NOCLONELOSS)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	mutanttongue = /obj/item/organ/tongue/zombie
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN

	species_chest = /obj/item/bodypart/chest/zombie
	species_head = /obj/item/bodypart/head/zombie
	species_l_arm = /obj/item/bodypart/l_arm/zombie
	species_r_arm = /obj/item/bodypart/r_arm/zombie
	species_l_leg = /obj/item/bodypart/l_leg/zombie
	species_r_leg = /obj/item/bodypart/r_leg/zombie

/datum/species/zombie/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/zombie/infectious
	name = "\improper Infectious Zombie"
	id = "memezombies"
	examine_limb_id = "zombie"
	mutanthands = /obj/item/zombie_hand
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 1.6
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	var/heal_rate = 1
	var/regen_cooldown = 0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

/datum/species/zombie/infectious/check_roundstart_eligible()
	return FALSE


/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(20, amount)

/datum/species/zombie/infectious/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW

	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(regen_cooldown < world.time)
		var/heal_amt = heal_rate
		if(C.InCritical())
			heal_amt *= 2
		C.heal_overall_damage(heal_amt,heal_amt)
		C.adjustToxLoss(-heal_amt)
	if(!C.InCritical() && prob(4))
		playsound(C, pick(spooks), 50, TRUE, 10)

//Congrats you somehow died so hard you stopped being a zombie
/datum/species/zombie/infectious/spec_death(gibbed, mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/zombie_infection/infection
	infection = C.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(infection)
		qdel(infection)

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	// Deal with the source of this zombie corruption
	//  Infection organ needs to be handled separately from mutant_organs
	//  because it persists through species transitions
	var/obj/item/organ/zombie_infection/infection
	infection = C.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new()
		infection.Insert(C)

/datum/species/zombie/infectious/fast
	name = "\improper Fast Infectious Zombie"
	id = "memezombiesfast"
	armor = 0
	speedmod = 0
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie

// Your skin falls off
/datum/species/human/krokodil_addict
	name = "\improper Human"
	id = "goofzombies"
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
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
