/mob/living/basic/mothroach
	name = "mothroach"
	desc = "This is the adorable by-product of multiple attempts at genetically mixing mothpeople with cockroaches."
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	held_state = "mothroach"
	held_lh = 'icons/mob/pets_held_lh.dmi'
	held_rh = 'icons/mob/pets_held_rh.dmi'
	head_icon = 'icons/mob/pets_held.dmi'
	butcher_results = list(/obj/item/food/meat/slab/mothroach = 3, /obj/item/stack/sheet/animalhide/mothroach = 1)
	density = TRUE
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	mob_size = MOB_SIZE_SMALL
	mobility_flags = MOBILITY_FLAGS_DEFAULT
	health = 25
	maxHealth = 25
	speed = 1.25
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	ventcrawler = VENTCRAWLER_ALWAYS

	verb_say = "flutters"
	verb_ask = "flutters inquisitively"
	verb_exclaim = "flutters loudly"
	verb_yell = "flutters loudly"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "hits"
	response_harm_simple = "hit"
	response_help_continuous = "pats"
	response_help_simple = "pat"

	faction = list("neutral")

	ai_controller = /datum/ai_controller/basic_controller/mothroach

/mob/living/basic/mothroach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "squeaks happily!", emote_sound = 'sound/voice/moth/scream_moth.ogg')

/mob/living/basic/mothroach/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	if(resting)
		icon_state = "[icon_living]_rest"
	else
		icon_state = "[icon_living]"

/datum/ai_controller/basic_controller/mothroach
	blackboard = list()

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/mothroach,
		/datum/ai_planning_subtree/find_and_hunt_target/mothroach,
	)
