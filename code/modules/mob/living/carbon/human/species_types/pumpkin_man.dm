/datum/species/pod/pumpkin_man
	name = "\improper Pumpkinperson"
	id = "pumpkin_man"
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/pumpkinpieslice
	species_traits = list(NOBLOOD,NOHUSK,NOEYESPRITES)
	inherent_traits = list(TRAIT_NOBREATH,TRAIT_NOHUNGER,TRAIT_XENO_IMMUNE)
	inherent_biotypes = list(MOB_HUMANOID, MOB_ORGANIC)
	mutanttongue = /obj/item/organ/tongue/bone
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN
	species_language_holder = /datum/language_holder/plant

	species_chest = /obj/item/bodypart/chest/pumpkin_man
	species_head = /obj/item/bodypart/head/pumpkin_man
	species_l_arm = /obj/item/bodypart/l_arm/pumpkin_man
	species_r_arm = /obj/item/bodypart/r_arm/pumpkin_man
	species_l_leg = /obj/item/bodypart/l_leg/pumpkin_man
	species_r_leg = /obj/item/bodypart/r_leg/pumpkin_man

/datum/species/pumpkin_man/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()
