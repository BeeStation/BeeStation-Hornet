/datum/unit_test/mob_attacks
	var/list/combat_mobs = list(
		/mob/living/carbon/human,
		/mob/living/carbon/monkey,
		/mob/living/carbon/alien/humanoid/drone,
		/mob/living/carbon/alien/larva,
		/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/slime,
	)
	var/list/mob_targets = list(
		/mob/living/carbon/human,
		/mob/living/carbon/monkey,
		/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/slime,
	)

/datum/unit_test/mob_attacks/Run()
	. = list()
	for (var/attacker in combat_mobs)
		for (var/target in mob_targets)
			var/mob/living/attacker_mob = new attacker(run_loc_floor_bottom_left)
			var/mob/living/target_mob = new target(run_loc_floor_bottom_left)
			var/original_health = target_mob.health
			attacker_mob.a_intent = INTENT_HARM
			attacker_mob.ClickOn(target_mob)
			if (target_mob.health >= original_health)
				. += "[target] did not take damage when attacked by [attacker]"
			qdel(attacker_mob)
			qdel(target_mob)
	if (length(.))
		Fail(jointext(., "\n"))
