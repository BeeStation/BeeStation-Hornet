/datum/symptom/lubefeet
	name = "Ducatopod"
	desc = "The host now sweats industrial lubricant from their feet, lubing tiles they walk on. Combine with Pierrot's throat for the penultimate form of torture."
	stealth = -4
	resistance = -2
	stage_speed = 4
	transmittable = 1
	level = 9
	severity = 3
	symptom_delay_min = 15
	symptom_delay_max = 30
	var/morelube = FALSE
	threshold_desc = "<b>Transmission 10:</b> The host sweats even more profusely, lubing almost every tile they walk over"				

/datum/symptom/lubefeet/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmission"] >= 10)
		morelube = TRUE

/datum/symptom/lubefeet/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2)
			if(prob(15))
				to_chat(M, "<span class='notice'>Your feet begin to sweat profusely...</span>")
		if(3, 4, 5)
			if(prob(10))
				to_chat(M, "<span class='danger'>You slip from the lube from your feet!</span>")
				M.slip()
			if(A.stage == 4 || A.stage == 5)
				if(morelube)
					makelube(M, 25)
				else
					makelube(M, 5)

/datum/symptom/lubefeet/proc/makelube(mob/living/carbon/M, chance)
	if(prob(chance))
		var/turf/open/OT = get_turf(M)
		if(istype(OT))
			to_chat(M, "<span class='danger'>The lube pools into a puddle!</span>")
			OT.MakeSlippery(TURF_WET_LUBE, 40)
