/datum/species/monkey
	name = "Monkey"
	id = SPECIES_MONKEY
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_MONKEY
	attack_verb = "bite"
	mutant_organs = list(/obj/item/organ/tail/monkey)
	mutant_bodyparts = list("tail_monkey" = "Monkey")
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	changesource_flags = MIRROR_BADMIN
	mutanttongue = /obj/item/organ/tongue/monkey
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	meat = /obj/item/food/meat/slab/monkey
	knife_butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	species_traits = list(
		NO_UNDERWEAR,
		NOTRANSSTING,
		EYECOLOR
	)
	inherent_traits = list(
		TRAIT_DISCOORDINATED_TOOL_USER,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_PRIMITIVE,
		TRAIT_INFERIORFORM,
		TRAIT_WEAK_SOUL,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN | SLIME_EXTRACT
	inherent_factions = list("monkey")
	sexes = TRUE
	species_language_holder = /datum/language_holder/monkey

	species_l_arm = /obj/item/bodypart/l_arm/monkey
	species_r_arm = /obj/item/bodypart/r_arm/monkey
	species_head = /obj/item/bodypart/head/monkey
	species_l_leg = /obj/item/bodypart/l_leg/monkey
	species_r_leg = /obj/item/bodypart/r_leg/monkey
	species_chest = /obj/item/bodypart/chest/monkey

	dust_anim = "dust-m"
	gib_anim = "gibbed-m"

	ai_controlled_species = TRUE

	species_height = SPECIES_HEIGHTS(8, 8, 8)

	//payday_modifier = 1.5

/datum/species/monkey/random_name(gender,unique,lastname)
	var/randname = "monkey ([rand(1,999)])"

	return randname

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.pass_flags |= PASSTABLE
	H.butcher_results = knife_butcher_results
	if(!H.dna.features["tail_human"] || H.dna.features["tail_human"] == "None")
		H.dna.features["tail_human"] = "Monkey"
		handle_mutant_bodyparts(H)

	H.dna.add_mutation(/datum/mutation/human/race, MUT_NORMAL)
	H.dna.activate_mutation(/datum/mutation/human/race)


/datum/species/monkey/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.pass_flags = initial(C.pass_flags)
	C.butcher_results = null
	C.dna.remove_mutation(/datum/mutation/human/race)

/datum/species/monkey/spec_unarmedattack(mob/living/carbon/human/user, atom/target)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(!iscarbon(target))
			return TRUE
		var/mob/living/carbon/victim = target
		if(user.is_muzzled())
			return TRUE
		var/obj/item/bodypart/affecting = null
		if(ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			affecting = human_victim.get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/armor = victim.run_armor_check(affecting, MELEE)
		if(prob(25))
			victim.visible_message(span_danger("[user]'s bite misses [victim]!"),
				span_danger("You avoid [user]'s bite!"), span_hear("You hear jaws snapping shut!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("Your bite misses [victim]!"))
			return TRUE
		///Monkeys are of a few mobs remaining in beecode that use randomized damage apply_damage(rand()) for some attacks.
		///It was the perogative a few years ago to standardize most attack procs to the same consistent damage everytime, but we are not the same codebase as then.
		///If someone wants to change this status quo by either reintroducing RNG attacks, or killing them entirely, that should be its own pr and include every remaining case.
		victim.apply_damage(rand(1, 3), BRUTE, affecting, armor)
		victim.visible_message(span_danger("[name] bites [victim]!"),
			span_userdanger("[name] bites you!"), span_hear("You hear a chomp!"), COMBAT_MESSAGE_RANGE, name)
		to_chat(user, span_danger("You bite [victim]!"))
		if(armor >= 2)
			return TRUE
		for(var/d in user.diseases)
			var/datum/disease/bite_infection = d
			victim.ForceContractDisease(bite_infection)
		return TRUE
	target.attack_paw(user)
	return TRUE

/datum/species/monkey/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = ..()
	if(H.radiation > RAD_MOB_MUTATE * 2 && prob(50))
		H.gorillize()
		return

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

/datum/species/monkey/get_species_height_map()
	return icon('icons/effects/64x64.dmi', "height_displacement_monkey")

/datum/dna/tumor
	species = new /datum/species/monkey/teratoma

/datum/species/monkey/teratoma
	name = "Teratoma"
	id = "teratoma"
	species_traits = list(
		NOTRANSSTING,
		NO_DNA_COPY,
		NOEYESPRITES, //teratomas already have eyes baked-in
		NO_UNDERWEAR,
		HAIR,
		FACEHAIR,
		LIPS,
	)
	inherent_traits = list(
		TRAIT_NOHUNGER,
		TRAIT_RADIMMUNE,
		TRAIT_BADDNA, //Made of mutated cells
		TRAIT_NOGUNS,
		TRAIT_NONECRODISEASE,
	)
	use_skintones = FALSE
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	changesource_flags = MIRROR_BADMIN
	mutantbrain = /obj/item/organ/brain/tumor
	mutanttongue = /obj/item/organ/tongue/teratoma

	species_chest = /obj/item/bodypart/chest/monkey/teratoma
	species_head = /obj/item/bodypart/head/monkey/teratoma
	species_l_arm = /obj/item/bodypart/l_arm/monkey/teratoma
	species_r_arm = /obj/item/bodypart/r_arm/monkey/teratoma
	species_l_leg = /obj/item/bodypart/l_leg/monkey/teratoma
	species_r_leg = /obj/item/bodypart/r_leg/monkey/teratoma

/obj/item/organ/brain/tumor
	name = "teratoma brain"

/obj/item/organ/brain/tumor/Remove(mob/living/carbon/C, special, no_id_transfer, pref_load = FALSE)
	. = ..()
	//Removing it deletes it
	if(!QDELETED(src))
		qdel(src)

/mob/living/carbon/human/species/monkey/tumor
	var/creator_key = null

/mob/living/carbon/human/species/monkey/tumor/handle_mutations_and_radiation()
	return

/mob/living/carbon/human/species/monkey/tumor/has_dna()
	return FALSE

/mob/living/carbon/human/species/monkey/tumor/create_dna()
	dna = new /datum/dna/tumor(src)
	//Give us the juicy mutant organs
	dna.species.on_species_gain(src, null, FALSE)
	dna.species.regenerate_organs(src, replace_current = TRUE)
	//Fix initial DNA not properly handling our height
	dna.update_body_size(height = pick(dna.species.get_species_height()))

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
