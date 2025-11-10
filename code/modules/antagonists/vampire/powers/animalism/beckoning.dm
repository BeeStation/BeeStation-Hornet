










/mob/living/basic/pet/dog/beast
	name = "\improper wild dog"
	real_name = "wild dog"
	desc = "A fearsome looking dog of undefinable breed."
	icon = 'icons/vampires/dogsummon.dmi'
	icon_state = "gray"
	icon_living = "gray"
	icon_dead = "gray_dead"
	butcher_results = list(/obj/item/food/meat/slab = 3)
	gold_core_spawnable = HOSTILE_SPAWN
	speak_emote = list("growls")
	faction = list(FACTION_HOSTILE)
	can_be_held = FALSE
	health = 20
	maxHealth = 20
	speed = 2
	obj_damage = 20
	melee_damage = 10
	armour_penetration = 30
	sharpness = NONE
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES

// We are free thinkers
/mob/living/basic/pet/dog/beast/add_collar()
	return FALSE
