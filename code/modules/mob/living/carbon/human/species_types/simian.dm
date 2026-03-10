/datum/species/simian
	name = "\improper Simian"
	plural_form = "Simians"
	id = SPECIES_SIMIAN
	meat = /obj/item/food/meat/slab/monkey
	species_language_holder = /datum/language_holder/monkey

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

	species_height = SPECIES_HEIGHTS(8, 8, 8)
	height_icon_state = "height_displacement_monkey"

//TODO: Remove after monkey species - Racc
/datum/species/simian/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.pass_flags = PASSTABLE

//TODO: Remove after TM - Racc
/datum/species/simian/check_roundstart_eligible()
	. = ..()
	return TRUE
