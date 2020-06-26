/datum/species/fly
	name = "Flyperson"
	id = "fly"
	say_mod = "buzzes"
	species_traits = list(NOEYESPRITES, NO_UNDERWEAR, TRAIT_BEEFRIEND)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutanttongue = /obj/item/organ/tongue/fly
	mutantliver = /obj/item/organ/liver/fly
	mutantstomach = /obj/item/organ/stomach/fly
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/fly
	mutant_bodyparts = list("insect_type")
	default_features = list("insect_type" = "housefly")
	burnmod = 1.4
	brutemod = 1.4
	speedmod = 0.7
	disliked_food = null
	liked_food = GROSS | MEAT | RAW | FRUIT
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/fly

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
	if(istype(chem, /datum/reagent/consumable))
		var/datum/reagent/consumable/nutri_check = chem
		if(nutri_check.nutriment_factor > 0)
			var/turf/pos = get_turf(H)
			H.vomit(0, FALSE, FALSE, 2, TRUE)
			playsound(pos, 'sound/effects/splat.ogg', 50, 1)
			H.visible_message("<span class='danger'>[H] vomits on the floor!</span>", \
						"<span class='userdanger'>You throw up on the floor!</span>")
		return TRUE

	..()

// Change body types
/datum/species/fly/on_species_gain(mob/living/carbon/C)
	. = ..()
	for(var/obj/item/bodypart/O in C.bodyparts)
		O.render_like_organic = TRUE // Makes limbs render like organic limbs instead of augmented limbs, check bodyparts.dm
		var/species = C.dna.features["insect_type"]
		var/datum/sprite_accessory/insect_type/player_species = GLOB.insect_type_list[species]
		C.dna.species.limbs_id = player_species.limbs_id

/datum/species/fly/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 29 //Flyswatters deal 30x damage to flypeople.
	return 0
