/*
* ## Lizards
*
* Green things that crawl around and eat bugs. Not to be confused with the human species lizardpersons, these are just small little fellas.
*/

/mob/living/basic/lizard
	name = "lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	icon_gib = "lizard_gib"
	speak_emote = list("hisses")
	health = 10
	maxHealth = 10
	faction = list(FACTION_LIZARD)
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	melee_damage = 1
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_REPTILE
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	worn_slot_flags = ITEM_SLOT_HEAD
	ai_controller = /datum/ai_controller/basic_controller/lizard

	/// Typecache of things that we seek out to eat. Yummy.
	var/static/list/edibles = typecacheof(list(
		/mob/living/basic/butterfly,
		/mob/living/basic/cockroach,
	))

/datum/emote/lizard
	abstract_type = /datum/emote/lizard
	mob_type_allowed_typecache = /mob/living/basic/lizard
	mob_type_blacklist_typecache = list()

/datum/emote/lizard/whicker
	key = "tongue"
	message = "sticks its tongue out contentedly!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/mob/living/basic/lizard/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/pet_bonus, "tongue")
	AddElement(/datum/element/basic_eating, heal_amt = 5, food_types = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, edibles)

/datum/ai_controller/basic_controller/lizard
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/lizard,
	)
