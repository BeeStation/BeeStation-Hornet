///DO NOT USE set_species(/datum/species/monkey)
///USE monkeyize() INSTEAD
/datum/species/monkey
	name = "\improper Monkey"
	id = SPECIES_MONKEY
	skinned_type = /obj/item/stack/sheet/animalhide/
	changesource_flags = MIRROR_BADMIN
	offset_features = list(
	OFFSET_HEAD = list(0,-3),
	OFFSET_FACEMASK = list(0,-3)
	)

	species_chest = /obj/item/bodypart/chest/monkey
	species_head = /obj/item/bodypart/head/monkey
	species_l_arm = /obj/item/bodypart/l_arm/monkey
	species_r_arm = /obj/item/bodypart/r_arm/monkey
	species_l_leg = /obj/item/bodypart/l_leg/monkey
	species_r_leg = /obj/item/bodypart/r_leg/monkey

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
