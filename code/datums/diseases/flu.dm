/datum/disease/flu
	name = "The Flu"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = "Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 5
	agent = "H13N1 flu virion"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	spreading_modifier = 0.75
	desc = "If left untreated the subject will feel quite unwell."
	danger = DISEASE_MINOR


/datum/disease/flu/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_bodypart_damage(1, updating_health = FALSE)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1, FALSE)
			if(affected_mob.body_position == LYING_DOWN && DT_PROB(10, delta_time))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return

		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_bodypart_damage(1, updating_health = FALSE)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1, FALSE)
			if(affected_mob.body_position == LYING_DOWN && DT_PROB(7.5, delta_time))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
