
/*
//////////////////////////////////////
Auto-brewery syndrome
	Noticeable.
	Raises resistance
	Decreases stage speed
	Decreases transmission
Thresholds
  transmission 6 Alcohol is produced much faster
  resistance 6 Alcohol is much more letal or toxic
//////////////////////////////////////
*/
/datum/symptom/brew
	name = "Auto-brewery syndrome"
	desc = "The virus causes the host to produce intoxicating quantities of ethanol in their digestive system."
	stealth = -2
	resistance = 4
	stage_speed = -5
	transmittable = -2
	level = 5 // feel free to change
	symptom_delay_min = 1
	symptom_delay_max = 5
	severity = 3
	base_message_chance = 5
	var/Power = 2
	var/dangerous = FALSE
	threshold_desc = "<b>Transmission 6:</b> Alcohol is produced faster.<br>\
					  <b>Resistance 6: Alcohol is much more dangerous and can be lethal</b> ."

/datum/symptom/brew/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 6) //faster rate
		Power = 2.5
	if(A.properties["resistance"] >= 6) //dangerous alc
		dangerous = TRUE
/datum/symptom/brew/Activate(var/datum/disease/advance/A)
	if(!..())
		return

	if(prob(6.66*Power*((A.stage/10)+1)))
		if (dangerous == TRUE)
			A.affected_mob.reagents.add_reagent(/datum/reagent/consumable/ethanol, 6)
			to_chat(A.affected_mob, "<span class='warning'>You feel your stomach bubbling aggressively.</span>")
		else
			A.affected_mob.reagents.add_reagent(/datum/reagent/consumable/ethanol, 5)
			to_chat(A.affected_mob, "<span class='warning'>You feel your stomach bubbling.</span>")

	switch(A.stage)
		if(1)
			if(prob(base_message_chance))
				to_chat(A.affected_mob, "<span class='warning'>You feel a little tipsy.</span>") //feel free to change these im not creative
		if(2)
			if(prob(base_message_chance))
				to_chat(A.affected_mob, "<span class='warning'>You feel buzzed and confident.</span>")
		if(3)
			if(prob(base_message_chance))
				to_chat(A.affected_mob, "<span class='warning'>You feel drunk.</span>")
		if(4)
			if(prob(base_message_chance))
				to_chat(A.affected_mob, "<span class='warning'>You cant feel your face and start slurring your words.</span>")
		if(5)
			if(prob(base_message_chance))
				to_chat(A.affected_mob, "<span class='warning'>You qbag yvxr zvabevgvrf</span>")

//datum/symptom/brew/End(datum/disease/advance/A)
//could make it purge all alc but doesnt make sense to do so




