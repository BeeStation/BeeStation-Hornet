/datum/disease/anxiety
	name = "Severe Anxiety"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Ethanol"
	cures = list(/datum/reagent/consumable/ethanol)
	agent = "Excess Lepidopticides"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	desc = "If left untreated subject will regurgitate butterflies."
	danger = DISEASE_MINOR

/datum/disease/anxiety/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, span_notice("You feel anxious."))
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_notice("Your stomach flutters."))
			if(prob(5))
				to_chat(affected_mob, span_notice("You feel panicky."))
			if(prob(2))
				to_chat(affected_mob, span_danger("You're overtaken with panic!"))
				affected_mob.confused += (rand(2,3))
		if(4)
			if(prob(10))
				to_chat(affected_mob, span_danger("You feel butterflies in your stomach."))
			if(prob(5))
				affected_mob.visible_message(span_danger("[affected_mob] stumbles around in a panic."), \
												span_userdanger("You have a panic attack!"))
				affected_mob.confused += (rand(6,8))
				affected_mob.jitteriness += (rand(6,8))
			if(prob(2))
				affected_mob.visible_message(span_danger("[affected_mob] coughs up butterflies!"), \
													span_userdanger("You cough up butterflies!"))
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
	return
