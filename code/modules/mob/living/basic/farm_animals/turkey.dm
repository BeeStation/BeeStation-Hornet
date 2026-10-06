/mob/living/basic/turkey
	name = "turkey"
	desc = "it's that time again."
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"
	speak_emote = list("clucks", "gobbles")
	health = 15
	maxHealth = 15
	melee_damage = 5
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	attack_sound = 'sound/mobs/non-humanoids/turkey/gobble.ogg'
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"
	ai_controller = /datum/ai_controller/basic_controller/turkey

/mob/living/basic/turkey/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "gobble")

/mob/living/basic/turkey/tom
	name = "Tom"
	desc = "A veteran of Nanotrasen's Animal Experimentation Program that attempted to replicate the organic space suit that some hostile entities are known to have exhibited, Tom now serves Nanotrasen as the mascot of the Exploration Crew."
	unsuitable_atmos_damage = 0
	health = 200
	maxHealth = 200
	minimum_survivable_temperature = TCMB

/datum/emote/turkey
	abstract_type = /datum/emote/turkey
	mob_type_allowed_typecache = /mob/living/basic/turkey
	mob_type_blacklist_typecache = list()

/datum/emote/turkey/gobble
	key = "gobble"
	key_third_person = "gobbles"
	message = "gobbles!"
	sound = 'sound/mobs/non-humanoids/turkey/gobble.ogg'
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/ai_controller/basic_controller/turkey
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/turkey,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)
