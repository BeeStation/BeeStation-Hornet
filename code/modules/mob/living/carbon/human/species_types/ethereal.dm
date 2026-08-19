/datum/species/ethereal
	name = "\improper Ethereal"
	id = SPECIES_ETHEREAL
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantstomach = /obj/item/organ/stomach/electrical/ethereal
	mutanttongue = /obj/item/organ/tongue/ethereal
	mutantheart = /obj/item/organ/heart/ethereal
	exotic_bloodtype = "LE"
	siemens_coeff = 0.5 //They thrive on energy
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS,
		TRAIT_AGENDER,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/ethereal
	sexes = FALSE //no fetish content allowed

	// Body temperature for ethereals is much higher then humans as they like hotter environments
	bodytemp_normal = (BODYTEMP_NORMAL + 50)
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // about 150C
	// Cold temperatures hurt faster as it is harder to move with out the heat energy
	bodytemp_cold_damage_limit = (T20C - 10) // about 10c
	hair_color_mode = USE_FIXED_MUTANT_COLOR
	hair_alpha = 140
	facial_hair_alpha = 140
	swimming_component = /datum/component/swimming/ethereal
	inert_mutation = /datum/mutation/overload

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ethereal,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ethereal,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ethereal,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ethereal,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ethereal,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ethereal,
	)

/datum/species/ethereal/on_species_gain(mob/living/carbon/human/new_ethereal, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(new_ethereal))
		return
	RegisterSignal(new_ethereal, COMSIG_ATOM_SHOULD_EMAG, PROC_REF(should_emag))
	RegisterSignal(new_ethereal, COMSIG_ATOM_ON_EMAG, PROC_REF(on_emag))
	new_ethereal.set_safe_hunger_level()

	var/obj/item/organ/heart/ethereal/core = new_ethereal.get_organ_slot(ORGAN_SLOT_HEART)
	core?.sync_color(new_ethereal)

	for(var/obj/item/bodypart/limb as anything in new_ethereal.bodyparts)
		if(limb.limb_id == SPECIES_ETHEREAL)
			limb.update_limb(is_creating = TRUE)

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/former_ethereal, datum/species/new_species, pref_load)
	UnregisterSignal(former_ethereal, list(
		COMSIG_ATOM_SHOULD_EMAG,
		COMSIG_ATOM_ON_EMAG,
	))
	return ..()

/datum/species/ethereal/proc/should_emag(mob/living/carbon/human/H, mob/user)
	SIGNAL_HANDLER
	var/obj/item/organ/heart/ethereal/core = H?.get_organ_slot(ORGAN_SLOT_HEART)
	return !(!core?.emag_effect || !istype(H)) // signal is inverted

/datum/species/ethereal/proc/on_emag(mob/living/carbon/human/H, mob/user, obj/item/card/emag/hacker)
	SIGNAL_HANDLER

	if(hacker)
		if(hacker.charges <= 0)
			to_chat(user, span_warning("[hacker] is out of charges and needs some time to restore them!"))
			user.balloon_alert(user, "out of charges!")
			return
		else
			hacker.use_charge()

	var/obj/item/organ/heart/ethereal/core = H.get_organ_slot(ORGAN_SLOT_HEART)
	core?.set_emagged(TRUE, H)
	if(user)
		to_chat(user, span_notice("You tap [H] on the back with your card."))
	H.visible_message(span_danger("[H] starts flickering in an array of colors!"))
	handle_emag(H)
	addtimer(CALLBACK(src, PROC_REF(stop_emag), H), 30 SECONDS) //Disco mode for 30 seconds! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.

/datum/species/ethereal/proc/handle_emag(mob/living/carbon/human/ethereal)
	var/obj/item/organ/heart/ethereal/core = ethereal.get_organ_slot(ORGAN_SLOT_HEART)
	if(!core?.emag_effect)
		return
	//Picks a random colour from the Ethereal colour list
	core.flicker_to(GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)], ethereal)
	addtimer(CALLBACK(src, PROC_REF(handle_emag), ethereal), 0.5 SECONDS)

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/ethereal)
	var/obj/item/organ/heart/ethereal/core = ethereal.get_organ_slot(ORGAN_SLOT_HEART)
	core?.set_emagged(FALSE, ethereal)
	ethereal.visible_message(span_danger("[ethereal] stops flickering and goes back to their normal state!"))

/datum/species/ethereal/get_cough_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_COUGH_SOUND(user)

/datum/species/ethereal/get_gasp_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GASP_SOUND(user)

/datum/species/ethereal/get_sigh_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SIGH_SOUND(user)

/datum/species/ethereal/get_sneeze_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNEEZE_SOUND(user)

/datum/species/ethereal/get_sniff_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNIFF_SOUND(user)

/datum/species/ethereal/get_giggle_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GIGGLE_SOUND(user)

/datum/species/ethereal/get_features()
	var/list/features = ..()

	features += "feature_ethcolor"

	return features

/datum/species/ethereal/get_scream_sound(mob/living/carbon/human/ethereal)
	return pick(
		'sound/voice/ethereal/ethereal_scream_1.ogg',
		'sound/voice/ethereal/ethereal_scream_2.ogg',
		'sound/voice/ethereal/ethereal_scream_3.ogg',
	)

/datum/species/ethereal/get_species_description()
	return "Ethereals are a unique species with liquid electricity for blood and a glowing body. They thrive on electricity, and are naturally agender."

/datum/species/ethereal/get_species_lore()
	return null

/datum/species/ethereal/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shockingly Tasty",
			SPECIES_PERK_DESC = "Ethereals can feed on electricity from APCs and powercells to restore their charge; and do not otherwise need to eat.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Disco Ball",
			SPECIES_PERK_DESC = "Ethereals passively generate their own light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Elemental Attacker",
			SPECIES_PERK_DESC = "Ethereals deal burn damage with their punches instead of brute.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Starving Artist",
			SPECIES_PERK_DESC = "Ethereals take toxin damage while starving.",
		),
	)

	return to_add
