/datum/symptom/beesease
	name = "Bee Infestation"
	desc = "Causes the host to cough toxin bees and occasionally synthesize toxin."
	stealth = -2
	resistance = 2
	stage_speed = 1
	transmittable = 1
	level = 9
	severity = 1
	symptom_delay_min = 15
	symptom_delay_max = 30
	var/honey = FALSE
	var/infected_bees = FALSE
	threshold_desc = "<b>Resistance 14:</b> Host synthesizes honey instead of toxins, bees now sting with honey instead of toxin.<br>\
					  <b>Transmission 10:</b> Bees now contain a small amount of infected blood"				

/datum/symptom/beesease/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 14)
		honey = TRUE
	if(A.properties["transmission"] >= 10)
		infected_bees = TRUE

/datum/symptom/beesease/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(2))
				to_chat(M, "<span class='notice'>You taste honey in your mouth.</span>")
		if(3)
			if(prob(10))
				to_chat(M, "<span class='notice'>Your stomach rumbles.</span>")
			if(prob(5))
				if(honey)
					to_chat(M, "<span class='notice'>You taste even more honey.</span>")
					M.reagents.add_reagent(/datum/reagent/consumable/honey, 2)
				else if(prob(20))
					to_chat(M, "<span class='danger'>Your stomach stings painfully.</span>")				
					M.adjustToxLoss(2)
					M.updatehealth()
		if(4, 5)
			if(prob(10))
				M.visible_message("<span class='danger'>[M] buzzes.</span>", \
								  "<span class='userdanger'>Your stomach buzzes violently!</span>")
			if(prob(5))
				to_chat(M, "<span class='danger'>You feel something moving in your throat.</span>")
			if(prob(1))
				M.visible_message("<span class='danger'>[M] coughs up a swarm of bees!</span>", \
								  "<span class='userdanger'>You cough up a swarm of bees!</span>")
				if(honey)
					var/mob/living/simple_animal/hostile/poison/bees/B = new(M.loc)
					B.assign_reagent(/datum/reagent/consumable/honey)
				else
					new /mob/living/simple_animal/hostile/poison/bees/toxin(M.loc)
