
/datum/species/monkey
	name = "\improper Monkey"
	id = SPECIES_MONKEY
	mutanttongue = /obj/item/organ/tongue/monkey
	mutantbrain = /obj/item/organ/brain/primate
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	meat = /obj/item/food/meat/slab/monkey
	knife_butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	changesource_flags = MIRROR_BADMIN
	inherent_traits = list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_WEAK_SOUL,
	)
	offset_features = list(
		OFFSET_HEAD = list(0,-3),
		OFFSET_FACEMASK = list(0,-3)
	)
	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN | SLIME_EXTRACT
	sexes = FALSE
	species_language_holder = /datum/language_holder/monkey

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/monkey,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/monkey
	)
	dust_anim = "dust-m"
	gib_anim = "gibbed-m"

	ai_controlled_species = TRUE

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	passtable_on(H, SPECIES_TRAIT)
	H.dna.add_mutation(/datum/mutation/race, MUT_NORMAL)
	H.dna.activate_mutation(/datum/mutation/race)
	H.AddElement(/datum/element/human_biter)

/datum/species/monkey/on_species_loss(mob/living/carbon/C)
	. = ..()
	passtable_off(C, SPECIES_TRAIT)
	C.dna.remove_mutation(/datum/mutation/race)
	C.RemoveElement(/datum/element/human_biter)

/datum/species/monkey/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[MONKEYDAY])
		return TRUE
	return ..()

/datum/species/monkey/get_scream_sound(mob/living/carbon/human/monkey)
	return pick(
		'sound/creatures/monkey/monkey_screech_1.ogg',
		'sound/creatures/monkey/monkey_screech_2.ogg',
		'sound/creatures/monkey/monkey_screech_3.ogg',
		'sound/creatures/monkey/monkey_screech_4.ogg',
		'sound/creatures/monkey/monkey_screech_5.ogg',
		'sound/creatures/monkey/monkey_screech_6.ogg',
		'sound/creatures/monkey/monkey_screech_7.ogg',
	)

/datum/species/monkey/get_species_description()
	return "Monkeys are a type of primate that exist between humans and animals on the evolutionary chain. \
		Every year, on Monkey Day, Nanotrasen shows their respect for the little guys by allowing them to roam the station freely."

/datum/species/monkey/get_species_lore()
	return list(
		"Monkeys are commonly used as test subjects on board Space Station 13. \
		But what if... for one day... the Monkeys were allowed to be the scientists? \
		What experiments would they come up with? Would they (stereotypically) be related to bananas somehow? \
		There's only one way to find out.",
	)

/datum/species/monkey/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "Monkeys can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Primal Primate",
			SPECIES_PERK_DESC = "Monkeys are primitive humans, and can't do most things a human can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your smaller form.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "capsules",
			SPECIES_PERK_NAME = "Mutadone Averse",
			SPECIES_PERK_DESC = "Monkeys are reverted into normal humans upon being exposed to Mutadone.",
		),
	)

	return to_add

/datum/species/monkey/create_pref_language_perk()
	var/list/to_add = list()
	// Holding these variables so we can grab the exact names for our perk.
	var/datum/language/common_language = /datum/language/common
	var/datum/language/monkey_language = /datum/language/monkey

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "comment",
		SPECIES_PERK_NAME = "Primitive Tongue",
		SPECIES_PERK_DESC = "You may be able to understand [initial(common_language.name)], but you can't speak it. \
			You can only speak [initial(monkey_language.name)].",
	))

	return to_add

/obj/item/organ/brain/primate
	name = "primate brain"
	desc = "This wad of meat is small, but has enlaged occipital lobes for spotting bananas."
	organ_traits = list(TRAIT_CAN_STRIP, TRAIT_PRIMITIVE, TRAIT_GUN_NATURAL) // No advanced tool usage.
	actions_types = list(/datum/action/item_action/organ_action/toggle_trip)
	/// Will this monkey stumble if they are crossed by a simple mob or a carbon in combat mode? Toggable by monkeys with clients, and is messed automatically set to true by monkey AI.
	var/tripping = TRUE

/datum/action/item_action/organ_action/toggle_trip
	name = "Toggle Tripping"
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	button_icon_state = "lesser_form"
	background_icon_state = "bg_default_on"

/datum/action/item_action/organ_action/toggle_trip/on_activate(mob/user, atom/target)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/brain/primate/monkey_brain = target
	if(monkey_brain.tripping)
		monkey_brain.tripping = FALSE
		background_icon_state = "bg_default"
		to_chat(monkey_brain.owner, span_notice("You will now avoid stumbling while colliding with people who are in combat mode."))
	else
		monkey_brain.tripping = TRUE
		background_icon_state = "bg_default_on"
		to_chat(monkey_brain.owner, span_notice("You will now stumble while while colliding with people who are in combat mode."))
	update_buttons()

/obj/item/organ/brain/primate/on_insert(mob/living/carbon/primate)
	. = ..()
	RegisterSignal(primate, COMSIG_LIVING_MOB_BUMPED, PROC_REF(on_mob_bump))

/obj/item/organ/brain/primate/on_remove(mob/living/carbon/primate)
	. = ..()
	UnregisterSignal(primate, COMSIG_LIVING_MOB_BUMPED)

/obj/item/organ/brain/primate/proc/on_mob_bump(mob/source, mob/living/crossing_mob)
	SIGNAL_HANDLER
	if(!tripping || !crossing_mob.combat_mode)
		return
	crossing_mob.knockOver(owner)

/// Virtual monkeys that crave virtual bananas. Everything about them is ephemeral (except that bite).
/datum/species/monkey/holodeck
	id = SPECIES_MONKEY_HOLODECK
	knife_butcher_results = list()
	meat = null
	skinned_type = null
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_GUN_NATURAL,
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_ZOMBIFY,
		TRAIT_NOBLOOD,
		TRAIT_NOHUNGER,
		TRAIT_VENTCRAWLER_NUDE,
	)

/datum/dna/tumor
	species = new /datum/species/monkey/teratoma

/datum/species/monkey/teratoma
	name = "Teratoma"
	id = "teratoma"
	species_traits = list(
		HAIR,
		FACEHAIR,
		LIPS,
		NOEYESPRITES, //teratomas already have eyes baked-in
	)
	inherent_traits = list(
		TRAIT_NOHUNGER,
		TRAIT_RADIMMUNE,
		TRAIT_BADDNA, //Made of mutated cells
		TRAIT_NOGUNS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
	)
	use_skintones = FALSE
	mutantbrain = /obj/item/organ/brain/tumor
	mutanttongue = /obj/item/organ/tongue/teratoma

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey/teratoma,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey/teratoma,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey/teratoma,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey/teratoma,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/monkey/teratoma,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/monkey/teratoma,
	)

/obj/item/organ/brain/tumor
	name = "teratoma brain"

/obj/item/organ/brain/tumor/Remove(mob/living/carbon/C, special, no_id_transfer, pref_load = FALSE)
	. = ..()
	//Removing it deletes it
	if(!QDELETED(src))
		qdel(src)

/mob/living/carbon/human/species/monkey/tumor
	var/creator_key = null

/mob/living/carbon/human/species/monkey/tumor/handle_mutations()
	return

/mob/living/carbon/human/species/monkey/tumor/has_dna()
	return FALSE

/mob/living/carbon/human/species/monkey/tumor/create_dna()
	dna = new /datum/dna/tumor(src)
	//Give us the juicy mutant organs
	dna.species.on_species_gain(src, null, FALSE)
	dna.species.regenerate_organs(src, replace_current = TRUE)
	//Fix initial DNA not properly handling our height
	dna.update_body_size()

/mob/living/carbon/human/species/monkey/tumor/death(gibbed)
	. = ..()
	for (var/mob/living/creator in GLOB.player_list)
		if (creator.key != creator_key)
			continue
		if (creator.stat == DEAD)
			return
		if (!creator.mind)
			return
		if (!creator.mind.has_antag_datum(/datum/antagonist/changeling))
			return
		to_chat(creator, "<span class='warning'>We gain the energy to birth another Teratoma...</span>")
		return
