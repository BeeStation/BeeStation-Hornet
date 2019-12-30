/datum/symptom/radiation
	name = "Iraddiant Cells"
	desc = "Causes the cells in the host's body to give off harmful radiation."
	stealth = -1
	resistance = 2
	stage_speed = -1
	transmittable = 2
	level = 8
	severity = 4
	symptom_delay_min = 1
	symptom_delay_max = 4
	var/fastrads = FALSE
	var/radothers = FALSE
	threshold_desc = "<b>Transmission 12:</b> Makes the host irradiate others around them as well.<br>\
					  <b>Speed 8:</b> Host takes radiation damage faster."

/datum/symptom/radiation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmission"] >= 10)
		radothers = TRUE
	if(A.properties["speed"] >= 8)
		fastrads = TRUE

/datum/symptom/radiation/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(10))
				to_chat(M, "<span class='notice'>You feel off...</span>")
		if(2, 3)
			if(prob(50))
				to_chat(M, "<span class='danger'>You feel like the atoms inside you are beginning to split...</span>")
		if(4, 5)
			if(fastrads)
				radiate(M, 80)
			else
				radiate(M, 40)
			if(radothers && A.stage == 5)
				if(prob(40))
					M.visible_message("<span class='danger'>[M] glows green for a moment!</span>", \
								 	  "<span class='userdanger'>You feel a massive wave of pain flow through you!</span>")
					radiation_pulse(M, 20)
			

/datum/symptom/radiation/proc/radiate(mob/living/carbon/M, chance)
	if(prob(chance))
		to_chat(M, "<span class='danger'>You feel a wave of pain throughout your body!</span>")
		M.radiation += 4
