/datum/species/simian
	name = "\improper Simian"
	plural_form = "Simians"
	id = SPECIES_SIMIAN
	meat = /obj/item/food/meat/slab/monkey
	species_language_holder = /datum/language_holder/simian
	allow_numbers_in_name = TRUE

	forced_features = list("tail_human" = "Monkey")
	species_traits = list(
		NO_UNDERWEAR,
		EYECOLOR,
		LIPS,
		NOSOCKS,
		MUTCOLORS,
	)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/simian,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/simian,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/simian,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/simian,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/simian,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/simian
	)

	mutant_organs = list(/obj/item/organ/tail/monkey)

	species_height = SPECIES_HEIGHTS(8, 8, 8)
	height_icon_state = "height_displacement_monkey"

//TODO: Remove after monkey species, this should be inherited - Racc
/datum/species/simian/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.pass_flags = PASSTABLE
	C.dna.features["tail_human"] = "Simian" //Defaults to Cat otherwise

//TODO: Remove after TM - Racc
/datum/species/simian/check_roundstart_eligible()
	. = ..()
	return TRUE

/datum/species/simian/get_species_description()
	return "Simians are a race of intelligent bipeds resembling earth chimpanzees. Most are fond of bananas."

//TODO: Write some up - Racc
/datum/species/simian/get_species_lore()
	return list(
		"Leave monkey, return to society.",
	)

/datum/species/simian/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Hand Feet",
			SPECIES_PERK_DESC = "Simian feet are unlike any other species'. Resembling a pair of hands, siminian feet don't comfortably fit into most shoes.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Flexible Feet",
			SPECIES_PERK_DESC = "Simian feet are flexible like hands. This allows them to hold and use items.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Nimble",
			SPECIES_PERK_DESC = "Simian are small and nimble. They can leap over tables with ease.",
		),
	)

	return to_add
