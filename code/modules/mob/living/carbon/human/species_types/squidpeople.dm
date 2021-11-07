/datum/species/squid
	name = "Squidperson"
	id = SPECIES_SQUID
	bodyflag = FLAG_SQUID
	default_color = "b8dfda"
	species_traits = list(MUTCOLORS,EYECOLOR,NOSOCKS)
	inherent_traits = list(TRAIT_NOSLIPALL,TRAIT_EASYDISMEMBER)
	default_features = list("mcolor" = "FFF") // bald
	speedmod = 0.8
	coldmod = 1.5
	punchdamage = 7 // Lower max damage in melee. It's just a tentacle
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | SLIME_EXTRACT
	use_skintones = 0
	no_equip = list(ITEM_SLOT_FEET)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	toxic_food = FRIED
	species_language_holder = /datum/language_holder/squid
	swimming_component = /datum/component/swimming/squid

/mob/living/carbon/human/species/squid
	race = /datum/species/squid

/datum/species/squid/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/squid/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_squid_name(genderToFind = gender)
	var/randname = squid_name(gender)
	if(lastname)
		randname += " [lastname]"
	return randname

/proc/random_unique_squid_name(attempts_to_find_unique_name=10, genderToFind)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(squid_name(genderToFind))
		if(!findname(.))
			break
