#define BRAINDAMAGE_TRANSMISSION "transmission"
#define BRAINDAMAGE_STAGE_SPEED "stage speed"

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
	threshold_desc = "<b>Transmission 12:</b> The disease's damage reaches lethal levels.<br>\
					  <b>Speed 9:</b> Host's brain develops even more traumas than normal."
	threshold_ranges = list(
		BRAINDAMAGE_TRANSMISSION = list(11, 13),
		BRAINDAMAGE_STAGE_SPEED = list(8, 10)
	)

/datum/symptom/braindamage/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= get_threshold(BRAINDAMAGE_TRANSMISSION))
		severity += 1

/datum/symptom/braindamage/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= get_threshold(BRAINDAMAGE_TRANSMISSION))
		lethal = TRUE
	if(A.stage_rate >= get_threshold(BRAINDAMAGE_STAGE_SPEED))
		moretrauma = TRUE

/datum/symptom/braindamage/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(10))
				to_chat(M, "<span class='notice'>Your head feels strange...</span>")
		if(2, 3)
			if(prob(10))
				to_chat(M, "<span class='danger'>Your brain begins hurting...</span>")
		if(4, 5)
			if(lethal)
				if(prob(35))
					M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5,90)), 200)
					to_chat(M, "<span class='danger'>Your brain hurts immensely!</span>")
			else
				if(prob(35))
					M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5,90)), 120)
					to_chat(M, "<span class='danger'>Your head hurts immensely!</span>")
			if(moretrauma && A.stage == 5)
				givetrauma(A, 10)

/datum/symptom/braindamage/proc/givetrauma(datum/disease/advance/A, chance)
	if(prob(chance))
		if(ishuman(A.affected_mob))
			var/mob/living/carbon/human/M = A.affected_mob
			M?.gain_trauma(BRAIN_TRAUMA_MILD)

/datum/symptom/braindamage/Threshold(datum/disease/advance/A)
	if(!..())
		return
	threshold_desc = "<b>Transmission [get_threshold(BRAINDAMAGE_TRANSMISSION)]:</b> The disease's damage reaches lethal levels.<br>\
					  <b>Speed [get_threshold(BRAINDAMAGE_STAGE_SPEED)]:</b> Host's brain develops even more traumas than normal."
	return threshold_desc
