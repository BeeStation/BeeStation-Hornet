/mob/living/basic/cortical_borer
	name = "Cortical Borer"
	desc = "WIP"
	icon = 'icons/mob/borer.dmi'
	icon_state = "borer"
	icon_living = "borer"
	icon_dead = "borer_dead"

	// Attributes
	maxHealth = 50
	health = 50

	// Damage and Combat
	combat_mode = TRUE
	melee_damage = 5
	obj_damage = 5
	armour_penetration = 100

	// Flavor
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	death_message = "screeches as its wings turn to dust and it collapses on the floor, its life extinguished."

	// Misc Stuff
	mob_size = MOB_SIZE_TINY
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	// AI
	environment_smash = ENVIRONMENT_SMASH_NONE
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile
	faction = list(FACTION_BORER)

	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)

