/datum/disease/rhumba_beat
	name = "The Rhumba Beat"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Chick Chicky Boom!"
	cures = list(GAS_PLASMA)
	agent = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 1
	danger = DISEASE_BIOHAZARD

/datum/disease/rhumba_beat/stage_act()
	..()
	if(affected_mob.ckey == "rosham")
		cure()
		return
	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.adjustFireLoss(5)
				affected_mob.updatehealth()
			if(prob(1))
				to_chat(affected_mob, span_danger("You feel strange..."))
		if(3)
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel the urge to dance..."))
			else if(prob(5))
				affected_mob.emote("gasp")
			else if(prob(10))
				to_chat(affected_mob, span_danger("You feel the need to chick chicky boom..."))
		if(4)
			if(prob(20))
				if (prob(50))
					affected_mob.adjust_fire_stacks(2)
					affected_mob.IgniteMob()
				else
					affected_mob.emote("gasp")
					to_chat(affected_mob, span_danger("You feel a burning beat inside..."))
		if(5)
			to_chat(affected_mob, span_danger("Your body is unable to contain the Rhumba Beat..."))
			if(prob(50))
				explosion(get_turf(affected_mob), -1, 0, 2, 3, 0, 2, magic=TRUE) // This is equivalent to a lvl 1 fireball
		else
			return
