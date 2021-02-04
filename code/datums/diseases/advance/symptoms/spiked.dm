
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
	severity = 1
	base_message_chance = 5
	var/Power = 1
	var/armor = 0
	var/done = FALSE
	threshold_desc = "<b>Transmission 6:</b> Spikes deal more damage.<br>\
					  <b>Resistance 6:</b> Hard spines give the host armor, scaling with resistance."

/datum/symptom/spiked/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["resistance"] >= 6)
		severity -= 1

/datum/symptom/spiked/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 6) //armor. capped at 20, but scaling with resistance, so if you want to max out spiked skin armor, you'll have to make several sacrifices
		armor = min(20, A.properties["resistance"])
	if(A.properties["transmittable"] >= 6) //higher damage
		Power = 1.4  //the typical +100% is waaaay too strong here when the symptom is stacked. +40% is sufficient

/datum/symptom/spiked/Activate(var/datum/disease/advance/A)
	var/mob/living/carbon/human/H = A.affected_mob
	if(!..())
		return
	switch(A.stage)
		if(1)
			if(prob(base_message_chance))
				to_chat(H, "<span class='warning'>You feel goosebumps pop up on your skin.</span>")
		if(2)
			if(prob(base_message_chance))
				to_chat(H, "<span class='warning'>Small spines spread to cover your entire body.</span>")
		if(3)
			if(prob(base_message_chance))
				to_chat(H, "<span class='warning'> Your spines pierce your jumpsuit.</span>")
		if(4, 5)
			if(!done)
				H.AddComponent(/datum/component/spikes, 5*power, armor, A.GetDiseaseID()) //removal is handled by the component
				to_chat(H, "<span class='warning'> Your spines harden, growing sharp and lethal.</span>")
				done = TRUE
			if(H.pulling && iscarbon(H.pulling)) //grabbing is handled with the disease instead of the component, so the component doesn't have to be processed
				var/mob/living/carbon/C = H.pulling
				var/def_check = C.getarmor(type = "melee")
				C.apply_damage(1*power, BRUTE, blocked = def_check)
				C.visible_message("<span class='warning'>[C.name] is pricked on [H.name]'s spikes.</span>")
				playsound(get_turf(C), 'sound/weapons/slice.ogg', 50, 1)
			for(var/mob/living/carbon/C in oview(1, H))
				if(C.pulling && C.pulling == H)
					var/def_check = C.getarmor(type = "melee")
					C.apply_damage(3*power, BRUTE, blocked = def_check)
					C.visible_message("<span class='warning'>[C.name] is pricked on [H.name]'s spikes.</span>")
					playsound(get_turf(C), 'sound/weapons/slice.ogg', 50, 1)



