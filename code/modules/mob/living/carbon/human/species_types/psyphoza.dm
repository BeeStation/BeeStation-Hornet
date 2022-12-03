/datum/species/pod/psyphoza
	name = "\improper Psyphoza"
	id = SPECIES_PSYPHOZA
	sexes = 0
	meat = /obj/item/reagent_containers/food/meat
	species_traits = list(NOEYESPRITES)
	attack_verb = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	miss_sound = 'sound/weapons/punchmiss.ogg'
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	mutant_brain = /obj/item/organ/brain/psyphoza
    mutanteyes = /obj/item/organ/eyes

	species_chest = /obj/item/bodypart/chest/pumpkin_man
	species_head = /obj/item/bodypart/head/pumpkin_man
	species_l_arm = /obj/item/bodypart/l_arm/pumpkin_man
	species_r_arm = /obj/item/bodypart/r_arm/pumpkin_man
	species_l_leg = /obj/item/bodypart/l_leg/pumpkin_man
	species_r_leg = /obj/item/bodypart/r_leg/pumpkin_man

/obj/item/organ/brain/psyphoza
	name = "psyphoza brain"
    desc = "Bubbling with psychic energy!"
	actions_types = list(/datum/action/item_action/organ_action/psychic_highlight)
	color = "#ff00ee"

/datum/action/item_action/organ_action/psychic_highlight
	name = "Psychic Sense"
	desc = "Sense your surroundings psychically."

/datum/action/item_action/organ_action/psychic_highlight/New(Target)
	. = ..()

/datum/action/item_action/organ_action/psychic_highlight/Trigger()
	. = ..()
	
