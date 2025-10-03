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
	prefixes = list("Hive ")
	bodies = list("Bees", "Hive")
	threshold_desc = "<b>Resistance 12:</b> The bees become symbiotic with the host, synthesizing honey and no longer stinging the stomach lining, and no longer attacking the host. Bees will also contain honey, unless transmission exceeds 10.<br>\
						<b>Transmission 8:</b> Bees now contain a completely random toxin."

/datum/symptom/beesease/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 8)
		severity += 2
	if(A.resistance >= 12)
		severity -= 4

/datum/symptom/beesease/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 12)
		honey = TRUE
	if(A.transmission >= 8)
		toxic_bees = TRUE

/datum/symptom/beesease/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(M.stat == DEAD)
		return
	switch(A.stage)
		if(2)
			if(prob(2))
				to_chat(M, span_notice("You taste honey in your mouth."))
		if(3)
			if(prob(15))
				to_chat(M, span_notice("Your stomach tingles."))
			if(prob(15))
				if(honey)
					to_chat(M, span_notice("You can't get the taste of honey out of your mouth!."))
					M.reagents.add_reagent(/datum/reagent/consumable/honey, 2)
				else
					to_chat(M, span_danger("Your stomach stings painfully."))
					M.adjustToxLoss(5)
					M.updatehealth()
		if(4, 5)
			if(honey)
				ADD_TRAIT(M, TRAIT_BEEFRIEND, DISEASE_TRAIT)
			if(prob(15))
				to_chat(M, span_notice("Your stomach squirms."))
			if(prob(25))
				if(honey)
					to_chat(M, span_notice("You can't get the taste of honey out of your mouth!."))
					M.reagents.add_reagent_list(list(/datum/reagent/consumable/honey = 10, /datum/reagent/consumable/honey = 5, /datum/reagent/medicine/insulin = 5)) //insulin prevents hyperglycemic shock
				else
					to_chat(M, span_danger("Your stomach stings painfully."))
					M.adjustToxLoss(5)
					M.updatehealth()
			if(prob(10))
				M.visible_message(span_danger("[M] buzzes."), \
									span_userdanger("Your stomach buzzes violently!"))
			if(prob(15))
				to_chat(M, span_danger("You feel something moving in your throat."))
			if(prob(10))
				M.visible_message(span_danger("[M] coughs up a bee!"), \
									span_userdanger("You cough up a bee!"))
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
