/datum/species/human
	name = "\improper Human"
	id = SPECIES_HUMAN
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "wings" = "None", "body_size" = "Normal")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/human/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.

/datum/species/human/get_laugh_sound(mob/living/carbon/user)
	return user.gender == FEMALE ? 'sound/voice/human/womanlaugh.ogg' : pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')

/datum/species/human/get_scream_sound(mob/living/carbon/user)
	return user.gender == FEMALE ? pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		) : pick(
		'sound/voice/human/malescream_1.ogg',
		'sound/voice/human/malescream_2.ogg',
		'sound/voice/human/malescream_3.ogg',
		'sound/voice/human/malescream_4.ogg',
		'sound/voice/human/malescream_5.ogg',
		)

/datum/species/human/get_cough_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_COUGH_SOUND(user)

/datum/species/human/get_gasp_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GASP_SOUND(user)

/datum/species/human/get_sigh_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SIGH_SOUND(user)

/datum/species/human/get_sneeze_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNEEZE_SOUND(user)

/datum/species/human/get_sniff_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNIFF_SOUND(user)
