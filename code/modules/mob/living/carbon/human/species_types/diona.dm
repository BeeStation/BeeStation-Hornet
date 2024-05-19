/* TO DO:

Diona pbody and tail
MAKE IT WORK
make markings actually work
make dionae be able to be planted via replica pods
THE DIONAE SPLITTING

tongue, liver, lungs, stomach, heart, dionae plant sprites (growth phases), action buttons, seed sprite

testmerge
win and get those 85 CAD

*/

/datum/species/diona
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "\improper Diona"
	plural_form = "Dionae"
	id = SPECIES_DIONA
	bodyflag = FLAG_DIONA
	default_color = "59CE00"
	species_traits = list(MUTCOLORS,EYECOLOR,AGENDER,NOHUSK,NO_DNA_COPY,NOMOUTH)
	inherent_traits = list(TRAIT_ALWAYS_CLEAN, TRAIT_BEEFRIEND, TRAIT_NONECRODISEASE)
	mutant_bodyparts = list("diona_leaves", "diona_thorns", "diona_flowers", "diona_moss", "diona_mushroom", "diona_antennae")
	default_features = list("diona_leaves" = "None", "diona_thorns" = "None", "diona_flowers" = "None", "diona_moss" = "None", "diona_mushroom" = "None", "diona_antennae" = "None", "body_size" = "Normal")
	inherent_factions = list("plants", "vines")
	fixed_mut_color = "59CE00"
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/food/meat/slab/human/mutant/diona
	exotic_blood = /datum/reagent/water
	species_gibs = GIB_TYPE_ROBOTIC //Someone please make this like, xeno gibs or something in the future. I cant be bothered to fuck around with gib code right now.
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/diona
	bodytemp_normal = (BODYTEMP_NORMAL - 22) // Body temperature for dionae is much lower then humans as they are plants, supposed to be 15 celsius
	speedmod = 2 // Dionae are slow.
	species_height = SPECIES_HEIGHTS(2, 1, 0)

	mutanteyes = /obj/item/organ/eyes/diona //SS14 sprite
	mutanttongue = /obj/item/organ/tongue/diona //placeholder sprite
	mutant_brain = /obj/item/organ/brain/diona //SS14 sprite
	mutantliver = /obj/item/organ/liver/diona //placeholder sprite
	mutantlungs = /obj/item/organ/lungs/diona //placeholder sprite
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
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //VERY flammable

/datum/species/diona/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = FALSE
	var/radiation = H.radiation
	//Dionae heal and eat radiation for a living.
	H.adjust_nutrition(radiation * 10)
	if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
		H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
	if(radiation > 50)
		H.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
		H.adjustToxLoss(-1)
		H.adjustOxyLoss(-1)

/datum/species/diona/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/diona/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	if(P.type == (/obj/projectile/energy/floramut || /obj/projectile/energy/florayield))
		H.set_nutrition(min(H.nutrition+30, NUTRITION_LEVEL_FULL))

/datum/species/diona/spec_death(gibbed, mob/living/carbon/human/H)
	addtimer(CALLBACK(src, PROC_REF(gib), gibbed, H), 50)

/datum/species/diona/proc/gib(gibbed, mob/living/carbon/human/H)
	var/datum/mind/M = H.mind
	for (var/amount = 0, amount < NPC_NYMPH_SPAWN_AMOUNT, amount++) //Spawn the NPC nymphs
		new /mob/living/simple_animal/nymph(H.loc)
	var/mob/living/simple_animal/nymph/nymph = new(H.loc) //Spawn the player nymph
	for(var/obj/item/I in H.contents)
		H.dropItemToGround(I, TRUE)
		I.pixel_x = rand(-10, 10)
		I.pixel_y = rand(-10, 10)
	nymph.origin = M
	nymph.oldName = H.real_name
	if(nymph.origin)
		nymph.origin.active = 1
		nymph.origin.transfer_to(nymph) //Move the player's mind to the player nymph
	H.gib(TRUE, TRUE, FALSE)  //Gib the old corpse with nothing left of use besides limbs


/datum/species/ipc/on_species_gain(mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/appendix/appendix = C.getorganslot("appendix") //No appendixes for plant people
	if(appendix)
		appendix.Remove(C)
		QDEL_NULL(appendix)

/datum/species/diona/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.diona_names)]"
	if(unique && attempts < 10 && findname(.))
		return .(gender, TRUE, null, ++attempts)

/datum/species/diona/get_species_description()
	/*
	return "Psyphoza are a species of extra-sensory lesser-sensory \
	fungal-form humanoids, infamous for their invulnerability to \
	occlusion-based magic tricks and sleight of hand."
	*/
	return null

/datum/species/diona/get_species_lore()
	/*
	return list(
		"A standing testament to the humor of mother nature, Psyphoza have evolved powerful and mystical \
			psychic abilities, which are almost completely mitigated by the fact they are absolutely \
			blind, and depend entirely on their psychic abilities to navigate their surroundings.",

		"Psyphoza culture is deeply rooted in superstition, mysticism, and the occult. It is their belief \
			that the morphology of their cap deeply impacts the course of their life, with characteristics \
			such as size, colour, and shape influencing how irrespectively lucky or unlucky they might be in \
			their experiences.",

		"An unfortunate superstition that Psyphoza 'meat' and 'blood' contain powerful psychedelics has caused \
			many individuals of the species to be targeted, and hunted, by rich & eccentric individuals who wish \
			to taste their flesh, and learn the truth for themselves. Unfortunately for Psyphoza, \
			this superstition is completely true...",

		"Although most Psyphoza have left behind a majority of the especially superstitious ideas of their \
			progenitors, some lower caste members still cling to these old ideas as strongly as ever. These beliefs \
			impact their culture deeply, resulting in very different behaviors between the typical and lower castes."
	)*/
	return null

/datum/species/diona/create_pref_unique_perks()
	var/list/to_add = list()
	/*
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Psychic",
			SPECIES_PERK_DESC = "Psyphoza are psychic and can sense things others can't.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Drug Codependance",
			SPECIES_PERK_DESC = "Consuming any kind of drug will replenish a Psyphoza's blood.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Blind",
			SPECIES_PERK_DESC = "Psyphoza are blind and can't see outside their immediate location and psychic sense.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Epilepsy Warning",
			SPECIES_PERK_DESC = "This species features effects that individuals with epilepsy may experience negatively!",
		),
	)
	*/

	return to_add
