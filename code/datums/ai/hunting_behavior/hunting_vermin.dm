/datum/ai_planning_subtree/find_and_hunt_target/cockroach
	hunt_targets = list(/obj/effect/decal/cleanable/food) //Bee Edit: We don't have ants yet July 2023, sorry. Also hi!!!

/datum/ai_planning_subtree/find_and_hunt_target/mothroach
	hunt_range = 3
	hunt_targets = list(/obj/effect/decal/cleanable/cobweb, /obj/structure/spider/stickyweb)
	hunting_behavior = /datum/ai_behavior/hunt_target/mothroach

/datum/ai_behavior/hunt_target/mothroach
	hunt_cooldown = 25 SECONDS
	hunt_emote = "nibbles"
