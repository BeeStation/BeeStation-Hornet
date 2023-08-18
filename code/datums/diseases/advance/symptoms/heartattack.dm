/*
//////////////////////////////////////

Heart Disease

	A bit stealthy
	Slightly resistant
	Quite slow
	small transmission penalty
	max level

Bonus
	heart attacks

//////////////////////////////////////
*/

/datum/symptom/heartattack
	name = "Heart Disease"
	desc = "This disease infiltrates the host's heart, causing cardiac arrest after a long incubation period"
	stealth = 2
	resistance = 1
	stage_speed = -6
	transmission = -2
	level = 9
	severity = 5
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Cardiac ", "Cardio")
	bodies = list("Heart")
	var/heartattack = FALSE
	threshold_desc = "<b>Transmission 10:</b> When the victim has a heart attack, their heart will pop right out of their chest, and attack!.<br>\
					  <b>Stealth 2:</b> The disease is somewhat less noticeable to the host."

/datum/symptom/heartattack/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 10)
		severity += 1

/datum/symptom/heartattack/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 10)
		heartattack = TRUE
	if(A.stealth >= 2)
		suppress_warning = TRUE

/datum/symptom/heartattack/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(suppress_warning && M.can_heartattack())
		if(prob(2))
			to_chat(M, "<span class='warning'>[pick("Your chest aches.", "You need to sit down.", "You feel out of breath.")]</span>")
	else if(prob(2) && M.can_heartattack())
		to_chat(M, "<span class='userdanger'>[pick("Your chest hurts!.", "You feel like your heart skipped a beat!")]</span>")
	if(A.stage == 5)
		if(M.getorgan(/obj/item/organ/heart) && M.can_heartattack())
			if(prob(1) && prob(50))
				M.set_heartattack(TRUE)
				to_chat(M, "<span class='userdanger'>Your heart stops!</span>")
				if(heartattack)
					heartattack(M, A)

/datum/symptom/heartattack/proc/heartattack(mob/living/M, datum/disease/advance/A)
	var/obj/item/organ/heart/heart = M.getorganslot(ORGAN_SLOT_HEART)
	if(M.getorgan(/obj/item/organ/heart))
		heart.Remove(M)
		qdel(heart)
		to_chat(M, "<span class='userdanger'>Your heart bursts out of your chest! It looks furious!</span>")
		new /mob/living/simple_animal/hostile/heart(M.loc)


