/datum/symptom/braindamage
	name = "Neural Decay"
	desc = "Causes the host's brain cells to naturally die off, causing severe brain damage."
	stealth = 1
	resistance = -2
	stage_speed = -3
	transmission = -1
	level = 7
	severity = 3
	symptom_delay_min = 15
	symptom_delay_max = 60
	prefixes = list("Idiot's ")
	bodies = list("Idiot")
	suffixes = list(" Memory Loss")
	var/lethal = FALSE
	var/moretrauma = FALSE
	threshold_desc = "<b>transmission 12:</b> The disease's damage reaches lethal levels.<br>\
						<b>Speed 9:</b> Host's brain develops even more traumas than normal."

/datum/symptom/braindamage/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 12 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.transmission >= 7))
		severity += 1
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>transmission 7:</b> The disease's damage reaches lethal levels.<br>\
						<b>Speed 6:</b> Host's brain develops even more traumas than normal."

/datum/symptom/braindamage/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 12 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.transmission >= 7))
		lethal = TRUE
	if(A.stage_rate >= 9  || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.stage_rate >= 6))
		moretrauma = TRUE

/datum/symptom/braindamage/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(10) && M.stat != DEAD)
				to_chat(M, span_notice("Your head feels strange..."))
		if(2, 3)
			if(prob(10) && M.stat != DEAD)
				to_chat(M, span_danger("Your brain begins hurting..."))
		if(4, 5)
			if(lethal)
				if(prob(35))
					M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5,90)), 200)
					if(M.stat != DEAD)
						to_chat(M, span_danger("Your brain hurts immensely!"))
			else
				if(prob(35))
					M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5,90)), 120)
					if(M.stat != DEAD)
						to_chat(M, span_danger("Your head hurts immensely!"))
			if(moretrauma && A.stage == 5)
				givetrauma(A, 10)

/datum/symptom/braindamage/proc/givetrauma(datum/disease/advance/A, chance)
	if(prob(chance))
		if(ishuman(A.affected_mob))
			var/mob/living/carbon/human/M = A.affected_mob
			M?.gain_trauma(BRAIN_TRAUMA_MILD)
