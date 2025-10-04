/mob/living/basic/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach" //Make this work
	density = FALSE
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	mob_size = MOB_SIZE_TINY
	health = 1
	maxHealth = 1
	speed = 1.25
	can_be_held = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS

	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	speak_emote = list("chitters")

	basic_mob_flags = DEL_ON_DEATH
	faction = list(FACTION_HOSTILE, FACTION_MAINT_CREATURES)

	ai_controller = /datum/ai_controller/basic_controller/cockroach

	///Are we squashable
	var/is_squashable = TRUE

/mob/living/basic/cockroach/strong
	is_squashable = FALSE

/mob/living/basic/cockroach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/effect/decal/cleanable/insectguts))
	// AddElement(/datum/element/swabable, CELL_LINE_TABLE_COCKROACH, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 7) //Bee edit: No swabable elements
	AddElement(/datum/element/basic_body_temp_sensitive, 270, INFINITY)
	if(is_squashable)
		AddComponent(/datum/component/squashable, squash_chance = 50, squash_damage = 1)

/mob/living/basic/cockroach/death(gibbed)
	if(GLOB.station_was_nuked) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/basic/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return FALSE

/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/find_and_hunt_target/cockroach,
	)
