/datum/species/apid
	// Beepeople, god damn it. It's hip, and alive! - Fuck ubunutu edition
	name = "\improper Apid"
	id = SPECIES_APID
	inherent_traits = list(
		TRAIT_BEEFRIEND,
		TRAIT_MUTANT_COLORS
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	mutant_bodyparts = list(
		"apid_stripes" = "thick",
		"apid_headstripes" = "thick",
		"apid_antenna" = "curled"
	)
	mutant_organs = list(
		/obj/item/organ/wings/bee = "Bee",
		/obj/item/organ/apid_stinger = ""
	)
	hair_color_mode = USE_FIXED_MUTANT_COLOR
	meat = /obj/item/food/meat/slab/human/mutant/apid
	mutanteyes = /obj/item/organ/eyes/apid
	mutantlungs = /obj/item/organ/lungs/apid
	mutanttongue = /obj/item/organ/tongue/bee
	toxmod = 0.5
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/apid
	inert_mutation = /datum/mutation/wax_saliva
	var/cold_cycle = 0

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/apid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/apid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/apid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/apid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/apid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/apid
	)

	species_height = SPECIES_HEIGHTS(2, 1, 0)

/datum/species/apid/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !H.IsSleeping() && !HAS_TRAIT(H,TRAIT_RESISTCOLD)) // Sleep when cold, like bees
		cold_cycle++
		if(prob(5))
			to_chat(H, span_warning("The cold is making you feel tired..."))
		switch(cold_cycle)
			if(5 to 10)
				H.drowsyness++
			if(10 to INFINITY)
				H.SetSleeping(50) // Should be 5 seconds
				cold_cycle = 0 // Resets the cycle, they have a chance to get out after waking up

	else
		cold_cycle = 0

/datum/species/apid/random_name(gender, unique, lastname, attempts)
	if(gender == MALE)
		. =  "[pick(GLOB.apid_names_male)]"
	else
		. =  "[pick(GLOB.apid_names_female)]"

	if(lastname)
		. += " [lastname]"
	else
		. +=  " [pick(GLOB.apid_names_last)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, attempts+1)

/datum/species/apid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return FALSE
	return ..()

/datum/species/apid/after_equip_job(datum/job/J, mob/living/carbon/human/H, client/preference_source = null) // For roundstart
	H.mind?.teach_crafting_recipe(/datum/crafting_recipe/honeycomb)
	return ..()

/datum/species/apid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(damage_weakness))
	C.mind?.teach_crafting_recipe(/datum/crafting_recipe/honeycomb)

/datum/species/apid/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	C.mind?.forget_crafting_recipe(/datum/crafting_recipe/honeycomb)

/datum/species/apid/proc/damage_weakness(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		damage_mods += 30 // Yes, a 30x damage modifier

/datum/species/apid/get_species_description()
	return "Beepeople, god damn it. It's hip, and alive! Buzz buzz!"

/datum/species/apid/get_species_lore()
	return null

/datum/species/apid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bug",
			SPECIES_PERK_NAME = "Hive-Friend",
			SPECIES_PERK_DESC = "Apids are naturally friends with bees, and can make honeycombs!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "level-down-alt",
			SPECIES_PERK_NAME = "Low Air Requirements",
			SPECIES_PERK_DESC = "Apids can breathe in lower air pressures just fine!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Dashing!",
			SPECIES_PERK_DESC = "Apids can use their wings to quickly dash forward in a flurry of buzzing!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "skull-crossbones",
			SPECIES_PERK_NAME = "Stinger",
			SPECIES_PERK_DESC = "Apids have stingers loaded with anti-coagulant venom, don't kick the hive!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "icicles",
			SPECIES_PERK_NAME = "Cold-Sensitive Biology",
			SPECIES_PERK_DESC = "The cold makes Apids sleepy, as does smoke...",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Insectoid Biology",
			SPECIES_PERK_DESC = "Fly swatters will deal significantly higher amounts of damage to Apids.",
		),
	)

	return to_add
