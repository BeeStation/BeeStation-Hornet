/datum/species/frostwing
	name = "\improper Frostwing"
	id = SPECIES_FROSTWING
	bodyflag = FLAG_FROSTWING
	default_color = "00FFFF"
	species_traits = list(NO_UNDERWEAR)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mutant_bodyparts = list("wings_frostwing", "tail_frostwing")
	mutanttongue = /obj/item/organ/tongue/frostwing
	mutantwings = /obj/item/organ/wings/frostwing
	// Lungs are what actually allow them to breathe low pressure
	mutantlungs = /obj/item/organ/lungs/frostwing
	// Their biology requires less oxygen due to the low pressure environment, so they don't take as much oxyloss.
	oxymod = 0.5
	// Full cold resist
	inherent_traits = list(TRAIT_RESISTCOLD)
	default_features = list("legs" = "Normal Legs", "body_size" = "Normal")
	//changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/frostwing
	// Drop feathers
	skinned_type = /obj/item/stack/sheet/animalhide/frostwing
	// They cannot speak Common, only Icaelic
	species_language_holder = /datum/language_holder/frostwing

	species_chest = /obj/item/bodypart/chest/frostwing
	species_head = /obj/item/bodypart/head/frostwing
	species_l_arm = /obj/item/bodypart/l_arm/frostwing
	species_r_arm = /obj/item/bodypart/r_arm/frostwing
	species_l_leg = /obj/item/bodypart/l_leg/frostwing
	species_r_leg = /obj/item/bodypart/r_leg/frostwing

/datum/species/frostwing/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.frostwing_names)]-[pick(GLOB.frostwing_names)][prob(50) ? "-[pick(GLOB.frostwing_names)]" : ""][prob(50) ? "-[pick(GLOB.frostwing_names)]" : ""]"
	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, null, ++attempts)
