/datum/species/moth
	name = "\improper Mothman"
	id = SPECIES_MOTH
	bodyflag = FLAG_MOTH
	default_color = "00FF00"
	species_traits = list(LIPS, NOEYESPRITES, HAS_MARKINGS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutant_bodyparts = list("moth_wings", "moth_antennae", "moth_markings")
	default_features = list("moth_wings" = "Plain", "moth_antennae" = "Plain", "moth_markings" = "None", "body_size" = "Normal")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	mutanteyes = /obj/item/organ/eyes/moth
	mutantwings = /obj/item/organ/wings/moth
	mutanttongue = /obj/item/organ/tongue/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth
	inert_mutation = STRONGWINGS
	deathsound = 'sound/voice/moth/moth_deathgasp.ogg'

	species_chest = /obj/item/bodypart/chest/moth
	species_head = /obj/item/bodypart/head/moth
	species_l_arm = /obj/item/bodypart/l_arm/moth
	species_r_arm = /obj/item/bodypart/r_arm/moth
	species_l_leg = /obj/item/bodypart/l_leg/moth
	species_r_leg = /obj/item/bodypart/r_leg/moth

/datum/species/moth/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.moth_first)]"

	if(lastname)
		. += " [lastname]"
	else
		. += " [pick(GLOB.moth_last)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

/datum/species/moth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return FALSE
	return ..()
/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 9 //flyswatters deal 10x damage to moths
	return 0

/datum/species/moth/get_laugh_sound(mob/living/carbon/user)
	return 'sound/emotes/mothlaugh.ogg'

/datum/species/moth/get_scream_sound(mob/living/carbon/user)
	return 'sound/voice/moth/scream_moth.ogg'
