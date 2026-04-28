/datum/species/abductor
	name = "\improper Abductor"
	id = SPECIES_ABDUCTOR
	sexes = FALSE
	species_traits = list(
		NOEYESPRITES,
		NOMOUTH
	)
	inherent_traits = list(
		TRAIT_VIRUSIMMUNE,
		TRAIT_CHUNKYFINGERS,
		TRAIT_NOHUNGER,
		TRAIT_NOBREATH,
		TRAIT_NOBLOOD,
	)
	mutanttongue = /obj/item/organ/tongue/abductor
	mutantstomach = null
	mutantheart = null
	mutantlungs = null
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/abductor,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/abductor,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/abductor,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/abductor,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/abductor,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/abductor,
	)

/datum/species/abductor/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.add_hud_to(C)

	C.set_safe_hunger_level()

/datum/species/abductor/on_species_loss(mob/living/carbon/C)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.remove_hud_from(C)

/datum/species/abductor/get_species_description()
	return "Silent, but deadly. It's not known where they really come from, but they seem to have shown up regardless."

/datum/species/abductor/get_species_lore()
	return null

/datum/species/abductor/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "volume-mute",
			SPECIES_PERK_NAME = "Mute",
			SPECIES_PERK_DESC = "Abductors can't speak. At all. This may upset your coworkers.",
		),
	)

	return to_add
