/*
//////////////////////////////////////

Vomiting

	Very very noticeable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmissibility.
	Medium Level.

Bonus
	Forces the affected mob to vomit!
	Meaning your disease can spread via
	people walking on vomit.
	Makes the affected mob lose nutrition and
	heal toxin damage.

//////////////////////////////////////
*/

/datum/symptom/vomit

	name = "Vomiting"
	desc = "The virus causes nausea and irritates the stomach, causing occasional vomit."
	stealth = -2
	resistance = 0
	stage_speed = 1
	transmission = 2
	level = 3
	severity = 1
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 80
	prefixes = list("Digestive ")
	bodies = list("Vomit")
	suffixes = list(" Emission")
	var/vomit_blood = FALSE
	var/proj_vomit = 0
	threshold_desc = "<b>Stage Speed 5:</b> Host will vomit blood, causing internal damage.<br>\
					  <b>Transmission 6:</b> Host will projectile vomit, increasing vomiting range.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/vomit/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.stage_rate >= 5) //blood vomit
		vomit_blood = TRUE
	if(A.transmission >= 6) //projectile vomit
		proj_vomit = 5

/datum/symptom/vomit/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You feel nauseated.", "You feel like you're going to throw up!")]</span>")
		else
			vomit(M)

/datum/symptom/vomit/proc/vomit(mob/living/carbon/M)
	M.vomit(20, vomit_blood, stun = 0, distance = proj_vomit)
