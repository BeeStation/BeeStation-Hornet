
/*
//////////////////////////////////////
Spiked Skin
	Noticeable.
	Raises resistance
	Decreases stage speed
	Increases Transmisson

Thresholds
  transmission 6 Can give minor armour
  resistance 6 Does more damage

//////////////////////////////////////
*/
/datum/symptom/spiked
	name = "Spiked Skin"
	desc = "The virus causes a spikes to protrude and fall from the skin causing damage to anyone that walks on them."
	stealth = -3
	resistance = 3
	stage_speed = -3
	transmittable = 2
	level = 6 //change it if you want
	symptom_delay_min = 1
	symptom_delay_max = 3
	severity = 4
	var/damage_level = 1
	var/punji_prob = 0
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
	if(A.properties["transmittable"] >= 6) //armor makes you take less brute damage (thx VictorP#0699)
		armour = TRUE
	if(A.properties["resistance"] >= 6) //Damage occurs more often
		damage_level = 2

/datum/symptom/spiked/Activate(var/datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/mob/living/carbon/human/H = A.affected_mob


	switch(damage_level)
		if(1)
			punji_prob = 10
		if(2)
			punji_prob = 20
	if(!..())
		return

	if(prob(20))
		closrf = 1
	else
		closrf = 0

	for (var/mob/living/C in oview(closrf, M))
		C.take_overall_damage(brute = punji_prob * (A.stage/10+1))
		to_chat(M, "<span class='warning'>[M.name] stabbed [C.name] with their body.</span>")
	switch(A.stage)
		if(1)
			if(prob(10))
				to_chat(M, "<span class='warning'>You see small spikes on your skin.</span>")
		if(2)
			if (done == FALSE)
				if (armour == TRUE)
					ADD_TRAIT(M, TRAIT_RESISTLOWPRESSURE, DISEASE_TRAIT)
					H.dna.species.armor +=20
					to_chat(M, "<span class='warning'> The spikes coat your entire body making your skin stronger.</span>")
					done = TRUE
			if(prob(10))
				to_chat(M, "<span class='warning'>You see wooden spikes protruding from your skin.</span>")
		if(3)
			if(prob(10))
				to_chat(M, "<span class='warning'> The spikes multiply and start oozing blood.</span>")
		if(4)
			if(prob(punji_prob))
				to_chat(M, "<span class='warning'> Some spikes break off leaving wounds.</span>")
				new /obj/structure/punji_sticks(M.loc)
		if(5)
			if(prob(punji_prob * 1.5))
				to_chat(M, "<span class='warning'> Deep spikes break off causing massive bleeding and flesh damage</span>")
				M.emote("scream")
				new /obj/structure/punji_sticks(M.loc)

/datum/symptom/spiked/End(datum/disease/advance/A)
	var/mob/living/carbon/human/H = A.affected_mob
	if(!..())
		return
		REMOVE_TRAIT(A.affected_mob, TRAIT_RESISTLOWPRESSURE, DISEASE_TRAIT)
		if (armour == TRUE)
			H.dna.species.armor -=20



