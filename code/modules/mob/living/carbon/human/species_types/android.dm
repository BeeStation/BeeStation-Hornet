/datum/species/android
	name = "Android"
	id = "android"
	species_traits = list(
		NOTRANSSTING,
		NOREAGENTS,
		NO_DNA_COPY,
		NOFLASH
	)
	inherent_traits = list(
		TRAIT_NOMETABOLISM,
		TRAIT_TOXIMMUNE,
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_NOFIRE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NOHUNGER,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOCLONELOSS,
		TRAIT_NOBLOOD,
	)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	meat = null
	damage_overlay_type = "synth"
	mutanttongue = /obj/item/organ/tongue/robot
	mutantstomach = null
	mutantheart = null
	mutantliver = null
	mutantlungs = null
	species_language_holder = /datum/language_holder/synthetic
	reagent_tag = PROCESS_SYNTHETIC
	species_gibs = GIB_TYPE_ROBOTIC
	attack_sound = 'sound/items/trayhit1.ogg'
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/android/on_species_gain(mob/living/carbon/C)
	. = ..()
	ADD_TRAIT(C, TRAIT_XENO_IMMUNE, "xeno immune")
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYTYPE_ROBOTIC, FALSE, TRUE)
		O.brute_reduction = 5
		O.burn_reduction = 4

/datum/species/android/on_species_loss(mob/living/carbon/C)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_XENO_IMMUNE, "xeno immune")
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYTYPE_ORGANIC,FALSE, TRUE)
		O.brute_reduction = initial(O.brute_reduction)
		O.burn_reduction = initial(O.burn_reduction)
