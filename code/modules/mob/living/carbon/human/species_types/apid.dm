/datum/species/apid
	// Beepeople, god damn it.
	name = "Apids"
	id = "apid"
	say_mod = "buzzes"
	default_color = "FFE800"
	species_traits = list(LIPS, NOEYESPRITES)
	mutant_bodyparts = list("apid_wings")
	default_features = list("apid_wings" = "Apid Wings")
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutanttongue = /obj/item/organ/tongue/bee
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/apid
	liked_foods = VEGETABLES | FRUIT
	disliked_foods = GROSS | DAIRY
	toxic_food = MEAT | RAW
	mutanteyes = /obj/item/organ/eyes/apid
	mutantlungs = /obj/item/organ/lungs/apid
	heat_mod = 1.5
	cold_mod = 1.5
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/obj/effect/particle_effect/smoke/smoke_mob(mob/living/carbon/human/species_types/apids/H)
	H.set_drugginess(25)


/datum/species/apid/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/apidite)

/datum/species/apids/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 29 //Bees get x30 damage from flyswatters
	return 0

/datum/species/apids/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
