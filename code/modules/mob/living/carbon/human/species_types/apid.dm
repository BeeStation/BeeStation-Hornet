/datum/species/apid
	// Beepeople, god damn it. It's hip, and alive! - Fuck ubunutu edition
	name = "Apids"
	id = "apid"
	say_mod = "buzzes"
	default_color = "FFE800"
	species_traits = list(LIPS, NOEYESPRITES, TRAIT_BEEFRIEND)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/apid
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | DAIRY
	toxic_food = MEAT | RAW
	heatmod = 1.5
	coldmod = 1.5
	burnmod = 1.5
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/apid

/datum/species/apid/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_apid_name(gender)

	var/randname = apid_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/apid/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 29 //Bees get x30 damage from flyswatters
	return 0

/datum/species/apid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		
/datum/species/apid/get_species_organs()
	var/list/organs = ..()
	organs[ORGAN_SLOT_LUNGS] = /obj/item/organ/lungs/apid
	organs[ORGAN_SLOT_EYES] = /obj/item/organ/eyes/apid
	organs[ORGAN_SLOT_WINGS] = /obj/item/organ/wings/bee
	organs[ORGAN_SLOT_TONGUE] = /obj/item/organ/tongue/bee
	return organs
