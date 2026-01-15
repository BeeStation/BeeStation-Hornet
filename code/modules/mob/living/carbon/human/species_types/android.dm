/datum/species/android
	name = "Android"
	id = SPECIES_ANDROID
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_NOFIRE,
		TRAIT_NOFLASH,
		TRAIT_NOHUNGER,
		TRAIT_NOREAGENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NOT_TRANSMORPHIC,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
	)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	meat = null
	mutanttongue = /obj/item/organ/tongue/robot
	mutantstomach = null
	mutantheart = null
	mutantliver = null
	mutantlungs = null
	species_language_holder = /datum/language_holder/synthetic
	reagent_tag = PROCESS_SYNTHETIC
	species_gibs = GIB_TYPE_ROBOTIC
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/robot/android,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot/android,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/robot/android,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/robot/android,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot/android,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot/android,
	)
	examine_limb_id = SPECIES_HUMAN

/datum/species/android/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	ADD_TRAIT(C, TRAIT_XENO_IMMUNE, "xeno immune")
	C.set_safe_hunger_level()

/datum/species/android/on_species_loss(mob/living/carbon/C)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_XENO_IMMUNE, "xeno immune")
