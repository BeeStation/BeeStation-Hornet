/datum/symptom/radiation
	name = "Iraddiant Cells"
	desc = "Causes the cells in the host's body to give off harmful radiation."
	stealth = -1
	resistance = 2
	stage_speed = -1
	transmittable = 2
	level = 8
	severity = 3
	symptom_delay_min = 10
	symptom_delay_max = 40
	var/fastrads = FALSE
	var/radothers = FALSE
	threshold_desc = "<b>Speed 8:</b> Host takes radiation damage faster."

/datum/symptom/radiation/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["stage_rate"] >= 8)
		severity += 1

/datum/symptom/radiation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 8)
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
			radiate(M)

/datum/symptom/radiation/proc/radiate(mob/living/carbon/M)
	to_chat(M, "<span class='danger'>You feel a wave of pain throughout your body!</span>")
	if(fastrads)
		M.radiation += 150
	else
		M.radiation += 75
	return 1
