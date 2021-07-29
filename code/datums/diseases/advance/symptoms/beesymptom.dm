/datum/symptom/beesease
	name = "Bee Infestation"
	desc = "Causes the host to cough toxin bees and occasionally synthesize toxin."
	stealth = -2
	resistance = 2
	stage_speed = 1
	transmission = 1
	level = 0
	severity = 2
	symptom_delay_min = 5
	symptom_delay_max = 20
	var/honey = FALSE
	var/toxic_bees= FALSE
	threshold_desc = "<b>Resistance 12:</b> The bees become symbiotic with the host, synthesizing honey and no longer stinging the stomach lining, and no longer attacking the host. Bees will also contain honey, unless transmission exceeds 10.<br>\
					  <b>Transmission 10:</b> Bees now contain a completely random toxin."

/datum/symptom/beesease/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 10)
		severity += 2
		if(A.resistance >= 12)
			severity -= 4

/datum/symptom/beesease/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 12)
		honey = TRUE
	if(A.transmission >= 10)
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
			if(honey)
				ADD_TRAIT(M, TRAIT_BEEFRIEND, DISEASE_TRAIT)
			if(prob(15))
				to_chat(M, "<span class='notice'>Your stomach squirms.</span>")
			if(prob(25))
				if(honey)
					to_chat(M, "<span class='notice'>You can't get the taste of honey out of your mouth!.</span>")
					M.reagents.add_reagent_list(list(/datum/reagent/consumable/honey = 10, /datum/reagent/consumable/honey/special = 5, /datum/reagent/medicine/insulin = 5)) //insulin prevents hyperglycemic shock
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
				if(toxic_bees)
					new /mob/living/simple_animal/hostile/poison/bees/toxin(M.loc)
				else if(honey)
					var/mob/living/simple_animal/hostile/poison/bees/newbee = new /mob/living/simple_animal/hostile/poison/bees(M.loc) //Heh, newbee
					newbee.assign_reagent(GLOB.chemical_reagents_list[/datum/reagent/consumable/honey])
					var/mob/living/simple_animal/hostile/poison/bees/newbee2 = new /mob/living/simple_animal/hostile/poison/bees(M.loc)
					newbee2.assign_reagent(GLOB.chemical_reagents_list[/datum/reagent/medicine/insulin])
				else
					new /mob/living/simple_animal/hostile/poison/bees(M.loc)

/datum/symptom/beesease/End(datum/disease/advance/A)
	if(!..())
		return
	REMOVE_TRAIT(A.affected_mob, TRAIT_BEEFRIEND, DISEASE_TRAIT)
