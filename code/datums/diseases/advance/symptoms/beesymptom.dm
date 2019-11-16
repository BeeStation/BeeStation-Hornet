/datum/symptom/beesease
	name = "Bees"
	desc = "Infection"
	stealth = -2
	resistance = 2
	stage_speed = 1
	transmittable = 1
	level = 9
	severity = 1
	base_message_chance = 100
	symptom_delay_min = 15
	symptom_delay_max = 30
	threshold_desc = "<b>
					  <b>
					  <b>"

/datum/disease/beesease/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>You taste honey in your mouth.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>Your stomach rumbles.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your stomach stings painfully.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(2)
					affected_mob.updatehealth()
		if(4)
			if(prob(10))
				affected_mob.visible_message("<span class='danger'>[affected_mob] buzzes.</span>", \
												"<span class='userdanger'>Your stomach buzzes violently!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel something moving in your throat.</span>")
			if(prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up a swarm of bees!</span>", \
													"<span class='userdanger'>You cough up a swarm of bees!</span>")
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
	return
