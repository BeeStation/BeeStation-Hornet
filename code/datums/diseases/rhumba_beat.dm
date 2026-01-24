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

/datum/disease/rhumba_beat/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	if(affected_mob.ckey == "rosham") //persist evermore
		cure()
		return FALSE

	switch(stage)
		if(2)
			if(DT_PROB(26, delta_time))
				affected_mob.adjustFireLoss(5, FALSE)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel strange...</span>")
		if(3)
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel the urge to dance...</span>")
			else if(DT_PROB(2.5, delta_time))
				affected_mob.emote("gasp")
			else if(DT_PROB(5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel the need to chick chicky boom...</span>")
		if(4)
			if(DT_PROB(10, delta_time))
				if(prob(50))
					affected_mob.adjust_fire_stacks(2)
					affected_mob.ignite_mob()
				else
					affected_mob.emote("gasp")
					to_chat(affected_mob, span_danger("You feel a burning beat inside..."))
		if(5)
			to_chat(affected_mob, "<span class='danger'>Your body is unable to contain the Rhumba Beat...</span>")
			if(DT_PROB(29, delta_time))
				explosion(get_turf(affected_mob), -1, 0, 2, 3, 0, 2, magic=TRUE) // This is equivalent to a lvl 1 fireball
