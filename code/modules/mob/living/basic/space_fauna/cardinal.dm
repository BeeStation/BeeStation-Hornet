/mob/living/basic/cardinal
	name = "cardinal"
	desc = "A cardinal!"
	icon_state = "cardinal"
	icon_living = "cardinal"
	icon_dead = "cardinal_dead"
	held_state = "cardinal"
	speak_emote = list("chirps")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	friendly_verb_continuous = "nudges"
	friendly_verb_simple = "nudge"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	mob_size = MOB_SIZE_SMALL
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab = 1)
	ai_controller = /datum/ai_controller/basic_controller/cardinal

/mob/living/basic/cardinal/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)

/datum/ai_controller/basic_controller/cardinal
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/cardinal,
	)

/datum/ai_planning_subtree/random_speech/cardinal
	speech_chance = 2
	speak = list("Chirp.", "Chirp?", "Squawk.", "Squawk!")
	sound = list('sound/mobs/non-humanoids/bird/squawk.ogg')
	emote_hear = list("squeaks.", "hisses.", "squeals.")
	emote_see = list("pecks at the ground.", "flaps its wings.")
