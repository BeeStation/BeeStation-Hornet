/mob/living/basic/pet/penguin
	abstract_type = /mob/living/basic/pet/penguin

	icon = 'icons/mob/simple/penguins.dmi'
	gender = FEMALE

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

	faction = list(FACTION_NEUTRAL)
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	ai_controller = /datum/ai_controller/basic_controller/penguin

/datum/emote/penguin
	abstract_type = /datum/emote/penguin
	mob_type_allowed_typecache = /mob/living/basic/pet/penguin
	mob_type_blacklist_typecache = list()

/datum/emote/penguin/honk
	key = "honk"
	key_third_person = "honks"
	message = "honks happily!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/mob/living/basic/pet/penguin/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cultist_pet)
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/pet_bonus, "honk")
	AddElementTrait(TRAIT_WADDLING, INNATE_TRAIT, /datum/element/waddling)

/mob/living/basic/pet/penguin/emperor
	name = "emperor penguin"
	real_name = "penguin"
	desc = "Emperor of all she surveys."
	icon_state = "penguin"
	icon_living = "penguin"
	icon_dead = "penguin_dead"
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/basic/pet/penguin/emperor/shamebrero
	name = "shamebrero penguin"
	icon_state = "penguin_shamebrero"
	icon_living = "penguin_shamebrero"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/penguin/baby
	name = "penguin chick"
	real_name = "penguin"
	desc = "Can't fly and barely waddles, yet the prince of all chicks."
	icon_state = "penguin_baby"
	icon_living = "penguin_baby"
	icon_dead = "penguin_baby_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/food/meat/slab/penguin = 1)
	ai_controller = /datum/ai_controller/basic_controller/penguin/baby
	///will it grow up?
	var/can_grow_up = TRUE

/mob/living/basic/pet/penguin/baby/Initialize(mapload)
	. = ..()
	if(!can_grow_up)
		return
	var/list/weight_mobtypes = list(
		/mob/living/basic/pet/penguin/emperor = 5,
		/mob/living/basic/pet/penguin/emperor/shamebrero = 1,
	)
	var/grown_type = pick_weight(weight_mobtypes)
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = null,\
		growth_path = grown_type,\
		growth_probability = 100,\
		lower_growth_value = 0.5,\
		upper_growth_value = 1,\
		signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
	)

/mob/living/basic/pet/penguin/baby/proc/ready_to_grow()
	return (stat == CONSCIOUS)

/mob/living/basic/pet/penguin/baby/permanent
	can_grow_up = FALSE
