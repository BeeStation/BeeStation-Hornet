/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "\improper Lizardperson"
	plural_form = "Lizardfolk"
	id = SPECIES_LIZARD
	bodyflag = FLAG_LIZARD
	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		LIPS
	)
	inherent_traits = list(
		TRAIT_TACKLING_TAILED_DEFENDER
	)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_REPTILE)
	mutant_bodyparts = list(
		"tail_lizard" = "Smooth",
		"snout" = "Round",
		"horns" = "None",
		"frills" = "None",
		"spines" = "None",
		"body_markings" = "None",
		"legs" = "Normal Legs",
		"body_size" = "Normal"
	)
	mutanttongue = /obj/item/organ/tongue/lizard
	mutant_organs = list(/obj/item/organ/tail/lizard)
	coldmod = 1.5
	heatmod = 0.67
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "L"
	inert_mutation = /datum/mutation/firebreath
	deathsound = 'sound/voice/lizard/deathsound.ogg'
	species_language_holder = /datum/language_holder/lizard
	digitigrade_customization = DIGITIGRADE_OPTIONAL
	blush_color = COLOR_BLUSH_TEAL

	// Lizards are coldblooded and can stand a greater temperature range than humans
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT + 20) // This puts lizards 10 above lavaland max heat for ash lizards.
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard,
	)

/// Lizards are cold blooded and do not stabilize body temperature naturally
/datum/species/lizard/body_temperature_core(mob/living/carbon/human/humi, delta_time, times_fired)
	return

/datum/species/lizard/random_name(gender, unique, lastname, attempts)
	if(gender == MALE)
		. = "[pick(GLOB.lizard_names_male)]-[pick(GLOB.lizard_names_male)]"
	else
		. = "[pick(GLOB.lizard_names_female)]-[pick(GLOB.lizard_names_female)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, null, ++attempts)

//I wag in death
/datum/species/lizard/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

/datum/species/lizard/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

/datum/species/lizard/get_scream_sound(mob/living/carbon/user)
	return pick(
		'sound/voice/lizard/lizard_scream_1.ogg',
		'sound/voice/lizard/lizard_scream_2.ogg',
		'sound/voice/lizard/lizard_scream_3.ogg',
		'sound/voice/lizard/lizard_scream_4.ogg',
		)

/datum/species/lizard/get_cough_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_COUGH_SOUND(user)

/datum/species/lizard/get_gasp_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GASP_SOUND(user)

/datum/species/lizard/get_sigh_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SIGH_SOUND(user)

/datum/species/lizard/get_sneeze_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNEEZE_SOUND(user)

/datum/species/lizard/get_sniff_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNIFF_SOUND(user)

/datum/species/lizard/get_giggle_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GIGGLE_SOUND(user)

/datum/species/lizard/get_species_description()
	return "Lizardpeople, unlike many 'Animalid' species, are not derived from humans, and are simply bipedal reptile-like people. \
	Lizards often find great pride in their species."

/datum/species/lizard/get_species_lore()
	return null

/*
	Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = SPECIES_LIZARD_ASH
	examine_limb_id = SPECIES_LIZARD
	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		LIPS,
		NO_UNDERWEAR
	)
	inherent_traits = list(
		TRAIT_CHUNKYFINGERS,
		TRAIT_VIRUSIMMUNE
		)
	species_language_holder = /datum/language_holder/lizard/ash
	mutantlungs = /obj/item/organ/lungs/ashwalker
	digitigrade_customization = DIGITIGRADE_FORCED

/datum/species/lizard/ashwalker/spec_life(mob/living/carbon/human/H)
	. = ..()
	H.cauterise_wounds(0.1)
	if (H.blood_volume < BLOOD_VOLUME_NORMAL && !H.is_bleeding())
		H.blood_volume += 0.5
