
/*
//////////////////////////////////////
Spiked Skin
	Noticeable.
	Raises resistance
	Decreases stage speed
	No transmission bonus
Thresholds
  transmission 6 Can give minor armour
  resistance 6 Does more damage
//////////////////////////////////////
*/
/datum/symptom/spiked
	name = "Cornu Cutaneum"
	desc = "The virus causes the host to unpredictably grow and shed sharp spines, damaging those near them."
	stealth = -3
	resistance = 3
	stage_speed = -3
	transmittable = 0
	level = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	severity = 4
	base_message_chance = 5
	var/Power = 1
	var/get_damage = 0
	var/ closrf = 0
	var/armour = FALSE
	var/done = FALSE
	var/mob/living/C = null
	var/mob/living/carbon/affected_mob = null
	threshold_desc = "<b>Transmission 6:</b> Gives the host some armor against brute damage.<br>\
					  <b>Resistance 6: Spikes grow faster and hurt you more often</b> ."

/datum/symptom/spiked/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 6) //armor
		armour = TRUE
	if(A.properties["resistance"] >= 6) //higher damage
		Power = 2

/datum/symptom/spiked/Activate(var/datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/mob/living/carbon/human/H = A.affected_mob

	if(!..())
		return

	if(prob(20*power))
		closrf = 1
	else
		closrf = 0

	for (var/mob/living/C in oview(closrf, M))
		var/def_check = C.getarmor(type = "melee")
		C.apply_damage(A.stage, BRUTE, blocked = def_check)
		to_chat(M, "<span class='warning'>[C.name] is pricked on [M.name]'s spines.</span>")
		playsound(get_turf(M), 'sound/weapons/slice.ogg', 50, 1)
	switch(A.stage)
		if(1)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>You feel goosebumps pop up on your skin.</span>")
		if(2)
			if (done == FALSE)
				if (armour == TRUE)
					H.dna.species.armor +=20
					to_chat(M, "<span class='warning'>Your goosebumps become small spines.</span>")
					done = TRUE
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>The small spines spread to cover your entire body.</span>")
		if(3)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'> Your spines pierce your jumpsuit.</span>")
		if(4)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'> You see the spikes getting sharper and elongated.</span>")
		if(5)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>You look like a human hedgehog</span>")

/datum/symptom/spiked/End(datum/disease/advance/A)
	var/mob/living/carbon/human/H = A.affected_mob
	if(!..() && A.stage >= 2)
		return
		if (armour == TRUE)
			H.dna.species.armor -=20


