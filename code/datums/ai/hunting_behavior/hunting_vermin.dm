/datum/ai_planning_subtree/find_and_hunt_target/cockroach
	hunt_targets = list(/obj/effect/decal/cleanable/ants)

/datum/ai_planning_subtree/find_and_hunt_target/mothroach
	hunt_range = 3
	hunt_targets = list(/obj/effect/decal/cleanable/cobweb, /obj/structure/spider/stickyweb)
	hunting_behavior = /datum/ai_behavior/hunt_target/mothroach

/datum/ai_behavior/hunt_target/mothroach
	hunt_cooldown = 25 SECONDS
	hunt_emote = "nibbles"
