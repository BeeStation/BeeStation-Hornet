/datum/species/monkeyman
	name = "Simian"
	id = "monkeyman"
	limbs_id = "monkeyman"
	say_mod = "chimpers"

	mutant_bodyparts = list("tail_human")
	default_features = list("mcolor" = "FFF", "tail_human" = "Monkey", "wings" = "None")
	inherent_traits = list(TRAIT_MONKEYLIKE) //currently, this is not enough of a downside for any huge buffs. isadvancedtooluser() is oldcode and not used in modern shit, and monkeys will only get cool shit when that is brought to date
	species_traits = list(NOEYESPRITES) //monkeys have beady little black eyes, and nothing else

	mutant_organs = list(/obj/item/organ/vocal_cords/monkey)
	mutanttail = /obj/item/organ/tail/monkey/
	species_language_holder = /datum/language_holder/monkey
	outfit_important_for_life = /datum/outfit/monkeyhat
	disliked_food = GRAIN | DAIRY | JUNKFOOD //reject modernity
	liked_food = VEGETABLES | MEAT | RAW //embrace tradition
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/outfit/monkeyhat
	name = "Monkey Translator"
	head = /obj/item/clothing/head/helmet/monkeytranslator

/datum/species/monkeyman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/monkeyhat/O = new /datum/outfit/monkeyhat
	switch(current_job) //we have this as a switch for easy futureproofing if someone comes up with stuff like a neck-slot translator for heads
		if("Debtor")
			return 0
	H.equipOutfit(O, visualsOnly)
	return 0
	
