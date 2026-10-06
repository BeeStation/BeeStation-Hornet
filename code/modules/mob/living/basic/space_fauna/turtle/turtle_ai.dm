/datum/ai_controller/basic_controller/turtle
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/headbutt_people, //playfully headbutt people's legs
		/datum/ai_planning_subtree/random_speech/turtle,
	)

/datum/ai_planning_subtree/find_and_hunt_target/headbutt_people
	target_key = BB_TURTLE_HEADBUTT_VICTIM
	finding_behavior = /datum/ai_behavior/find_hunt_target/human_to_headbutt
	hunting_behavior = /datum/ai_behavior/hunt_target/headbutt_leg
	hunt_targets = list(/mob/living/carbon/human)
	hunt_range = 4
	hunt_chance = 45

/datum/ai_behavior/find_hunt_target/human_to_headbutt
	action_cooldown = 2 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_hunt_target/human_to_headbutt/valid_dinner(mob/living/source, mob/living/carbon/human/dinner, radius, datum/ai_controller/controller, seconds_per_tick)
	if(dinner.stat != CONSCIOUS)
		return FALSE
	if(isnull(dinner.get_bodypart(BODY_ZONE_R_LEG)) && isnull(dinner.get_bodypart(BODY_ZONE_L_LEG))) //no legs to headbutt!
		return FALSE
	return can_see(source, dinner, radius)

/datum/ai_behavior/hunt_target/headbutt_leg
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/headbutt_leg/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("playfully headbutts [hunted]'s legs!")

/datum/ai_planning_subtree/random_speech/turtle
	speech_chance = 1
	emote_hear = list("snores.", "yawns.")
	emote_see = list("stretches out their neck.", "looks around slowly.")
