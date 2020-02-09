/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	species_traits = list(NOBLOOD,NOHUSK)
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NOHUNGER,TRAIT_EASYDISMEMBER,TRAIT_LIMBATTACHMENT,TRAIT_FAKEDEATH, TRAIT_CALCIUM_HEALER,TRAIT_XENO_IMMUNE)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	mutanttongue = /obj/item/organ/tongue/bone
	damage_overlay_type = ""//let's not show bloody wounds or burns over bones.
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW
	//They can technically be in an ERT
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

/datum/species/skeleton/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()
