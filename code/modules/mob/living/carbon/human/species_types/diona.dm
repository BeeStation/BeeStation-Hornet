/datum/species/diona
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "\improper Diona"
	plural_form = "Dionae"
	id = SPECIES_DIONAE
	default_color = "59CE00"
	species_traits = list(MUTCOLORS,EYECOLOR,AGENDER,NOHUSK,NO_DNA_COPY)
	inherent_traits = list(TRAIT_ALWAYS_CLEAN, TRAIT_BEEFRIEND, TRAIT_NONECRODISEASE)
	inherent_factions = list("plants", "vines")
	fixed_mut_color = "59CE00"
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/food/meat/slab/human/mutant/diona
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/diona
	bodytemp_normal = (BODYTEMP_NORMAL - 22) // Body temperature for dionaea is much lower then humans as they are plants, supposed to be 15 celsius
	speedmod = 2 // Dionaea are slow.

	mutanteyes = /obj/item/organ/eyes/diona //SS14 sprite
	mutanttongue = /obj/item/organ/tongue/diona //placeholder sprite
	mutant_brain = /obj/item/organ/brain/diona //SS14 sprite
	mutantliver = /obj/item/organ/liver/diona //placeholder sprite
	mutantstomach = /obj/item/organ/stomach/diona //SS14 sprite
	mutantears = /obj/item/organ/ears/diona //SS14 sprite
	mutant_heart = /obj/item/organ/heart/diona //placeholder sprite
	mutant_organs = list()

	species_chest = /obj/item/bodypart/chest/diona
	species_head = /obj/item/bodypart/head/diona
	species_l_arm = /obj/item/bodypart/l_arm/diona
	species_r_arm = /obj/item/bodypart/r_arm/diona
	species_l_leg = /obj/item/bodypart/l_leg/diona
	species_r_leg = /obj/item/bodypart/r_leg/diona


/datum/species/diona/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		H.adjust_nutrition(light_amount * 10)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/datum/species/diona/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/diona/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	if(P.type == (/obj/projectile/energy/floramut || /obj/projectile/energy/florayield))
		H.set_nutrition(min(H.nutrition+30, NUTRITION_LEVEL_FULL))
