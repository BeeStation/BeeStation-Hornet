
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

	if(prob(20))
		closrf = 1
	else
		closrf = 0

	for (var/mob/living/C in oview(closrf, M))
		var/def_check = C.getarmor(type = "melee")
		C.apply_damage((A.stage*Power/2), BRUTE, blocked = def_check)
		to_chat(M, "<span class='warning'>[C.name] is pricked on [M.name]'s spines.</span>")
		playsound(get_turf(M), 'sound/weapons/slice.ogg', 50, 1)
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
			if(prob(20))
				to_chat(M, "<span class='warning'> Some spikes break off leaving wounds.</span>")
				new /obj/structure/punji_sticks(M.loc)
		if(5)
			if(prob(20))
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



