/datum/species/frostwing
	name = "\improper Frostwing"
	id = SPECIES_FROSTWING
	bodyflag = FLAG_FROSTWING
	default_color = "00FFFF"
	species_traits = list(NO_UNDERWEAR)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mutant_bodyparts = list("wings_frostwing", "trail_frostwing")
	mutanttongue = /obj/item/organ/tongue/frostwing
	mutantwings = /obj/item/organ/wings/frostwing
	// Icy atmos has lower pressure, need to resist oxyloss but still require oxygen
	oxymod = 0.2
	// Full cold resist
	inherent_traits = list(TRAIT_RESISTCOLD)
	default_features = list("legs" = "Normal Legs", "body_size" = "Normal")
	//changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/frostwing
	skinned_type = /obj/item/stack/sheet/animalhide/frostwing
	species_language_holder = /datum/language_holder/frostwing

	species_chest = /obj/item/bodypart/chest/frostwing
	species_head = /obj/item/bodypart/head/frostwing
	species_l_arm = /obj/item/bodypart/l_arm/frostwing
	species_r_arm = /obj/item/bodypart/r_arm/frostwing
	species_l_leg = /obj/item/bodypart/l_leg/frostwing
	species_r_leg = /obj/item/bodypart/r_leg/frostwing


/*
/datum/species/frostwing/random_name(gender, unique, lastname, attempts)
	if(gender == MALE)
		. = "[pick(GLOB.lizard_names_male)]-[pick(GLOB.lizard_names_male)]"
	else
		. = "[pick(GLOB.lizard_names_female)]-[pick(GLOB.lizard_names_female)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, null, ++attempts)
*/
