/datum/symptom/beesease
	name = "Bee Infestation"
	desc = "Causes the host to cough toxin bees and occasionally synthesize toxin."
	stealth = -2
	resistance = 2
	stage_speed = 1
	transmittable = 1
	level = 9
	severity = 5
	symptom_delay_min = 5
	symptom_delay_max = 20
	var/honey = FALSE
	var/toxic_bees= FALSE
	threshold_desc = "<b>Resistance 14:</b> Host synthesizes honey instead of toxins, bees now sting with honey instead of toxin.<br>\
					  <b>Transmission 10:</b> Bees now contain a completely random toxin, unless resistance exceeds 14"		
					  
/datum/symptom/beesease/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 14)
		honey = TRUE
	if(A.properties["transmittable"] >= 10)
		toxic_bees = TRUE

/datum/symptom/beesease/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(2))
				to_chat(M, "<span class='notice'>You taste honey in your mouth.</span>")
		if(3)
			if(prob(15))
				to_chat(M, "<span class='notice'>Your stomach tingles.</span>")
			if(prob(15))
				if(honey)
					to_chat(M, "<span class='notice'>You can't get the taste of honey out of your mouth!.</span>")
					M.reagents.add_reagent(/datum/reagent/consumable/honey, 2)
				else
					to_chat(M, "<span class='danger'>Your stomach stings painfully.</span>")				
					M.adjustToxLoss(5)
					M.updatehealth()
		if(4, 5)
			if(prob(15))
				to_chat(M, "<span class='notice'>Your stomach squirms.</span>")
			if(prob(15))
				if(honey)
					to_chat(M, "<span class='notice'>You can't get the taste of honey out of your mouth!.</span>")
					M.reagents.add_reagent_list(list(/datum/reagent/consumable/honey = 5, /datum/reagent/medicine/insulin = 15)) //honey rooooughly equivalent to 1.5u omnizine. due to how honey synthesizes 7.5 sugar per unit, the large amounts of insulin are necessary to prevent hyperglycaemic shock due to the bees
				else
					to_chat(M, "<span class='danger'>Your stomach stings painfully.</span>")				
					M.adjustToxLoss(5)
					M.updatehealth()
			if(prob(10))
				M.visible_message("<span class='danger'>[M] buzzes.</span>", \
								  "<span class='userdanger'>Your stomach buzzes violently!</span>")
			if(prob(15))
				to_chat(M, "<span class='danger'>You feel something moving in your throat.</span>")
			if(prob(10))
				M.visible_message("<span class='danger'>[M] coughs up a bee!</span>", \
								  "<span class='userdanger'>You cough up a bee!</span>")
				if(honey)
					var/mob/living/simple_animal/hostile/poison/bees/B = new(M.loc)
					B.assign_reagent(GLOB.chemical_reagents_list[/datum/reagent/consumable/honey])
				else if(toxic_bees)
					new /mob/living/simple_animal/hostile/poison/bees/toxin(M.loc)
				else
					new /mob/living/simple_animal/hostile/poison/bees(M.loc)
