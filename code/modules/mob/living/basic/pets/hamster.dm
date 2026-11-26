#define ROUNDSTART_DISEASE_PROB 5
#define TRANSMISSION_PROBABILITY 20

/mob/living/basic/pet/hamster
	name = "hamster"
	desc = "It's a hamster."

	icon_state = "hamster"
	icon_living = "hamster"
	held_state = "hamster"
	icon_dead = "hamster_dead"

	can_be_held = TRUE
	held_state = "hamster"
	worn_slot_flags = ITEM_SLOT_HEAD
	see_in_dark = 5

	speak_emote = list("squeak", "hisses", "squeals")
	chat_color = "#D3B277"

	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/food/meat/slab/hamster = 1)

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "bites"
	response_harm_simple = "bite"

	ai_controller = /datum/ai_controller/basic_controller/hamster

/mob/living/basic/pet/hamster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)

/mob/living/basic/pet/hamster/vector //now also viro's source of a solitary, shitty starter disease
	name = "Vector"
	desc = "It's Vector the hamster. Definitely not a source of deadly diseases."
	var/datum/disease/vector_disease

/mob/living/basic/pet/hamster/vector/Initialize(mapload)
	. = ..()
	if(!prob(ROUNDSTART_DISEASE_PROB))
		return

	var/disease_type = pick(/datum/disease/cold, /datum/disease/flu, /datum/disease/fluspanish)
	vector_disease = new disease_type()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	message_admins("Vector was roundstart infected with [vector_disease.name]. Don't lynch the virologist!")
	log_game("Vector was roundstart infected with [vector_disease.name].")

/mob/living/basic/pet/hamster/vector/proc/on_entered(datum/source, atom/movable/thing, atom/oldloc)
	SIGNAL_HANDLER
	if(!isliving(thing) || isnull(vector_disease) || !prob(TRANSMISSION_PROBABILITY))
		return
	var/mob/living/poor_soul = thing
	if(!poor_soul.HasDisease(vector_disease)) // I'm not actually sure if this check is needed, but better to be safe than sorry
		poor_soul.ContactContractDisease(vector_disease)

/datum/ai_controller/basic_controller/hamster
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/hamster,
	)

#undef ROUNDSTART_DISEASE_PROB
#undef TRANSMISSION_PROBABILITY
