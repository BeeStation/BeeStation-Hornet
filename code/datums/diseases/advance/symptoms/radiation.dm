/datum/symptom/radiation
	name = "Iraddiant Cells"
	desc = "Causes the cells in the host's body to give off harmful radiation."
	stealth = -1
	resistance = 2
	stage_speed = -1
	transmission = 2
	level = 7
	severity = 3
	symptom_delay_min = 10
	symptom_delay_max = 40
	prefixes = list("Gamma ")
	bodies = list("Radiation")
	threshold_desc = "<b>Speed 8:</b> Host takes radiation damage faster."

/datum/symptom/radiation/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 8)
		severity += 1

/datum/symptom/radiation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		power = 2

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
	M.radiation += 75 * power
	return 1

/datum/symptom/radconversion
	name = "Aptotic Culling"
	desc = "The virus causes infected cells to die off when exposed to radiation, causing open wounds to appear on the host's flesh. The end result of this process is the removal of radioactive contamination from the host."
	stealth = 1
	resistance = 1
	stage_speed = 1
	transmission = -2
	level = 8
	severity = 0 //this is, at base level, somewhat negative. low levels of radiation will become brute damage and a danger to a host, where otherwise they'd have no effect
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/toxheal = FALSE
	var/cellheal = FALSE
	suffixes = list(" Aptosis")
	threshold_desc = "<b>Stage Speed 6:</b> The disease also kills off contaminated cells, converting Toxin damage to Brute damage, at an efficient rate.<br>\
					<b>Resistance 12 :</b> The disease also kills off genetically damaged cells and their neighbors, converting Cellular damage into Burn damage, at an inefficient rate."

/datum/symptom/radconversion/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 6)
		severity -= 1
	if(A.resistance >= 12)
		severity -= 1

/datum/symptom/radconversion/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 6)
		toxheal = TRUE
	if(A.resistance >= 12)
		cellheal = TRUE


/datum/symptom/radconversion/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(A.stage >= 4)
		if(M.radiation)
			M.radiation -= max(M.radiation * 0.05, min(10, M.radiation))
			M.take_overall_damage(2)
			if(prob(5))
				to_chat(M, "<span class='userdanger'>A tear opens in your flesh!</span>")
				M.add_splatter_floor()
		if(M.getToxLoss() && toxheal)
			M.adjustToxLoss(-2, forced = TRUE) //this is removing foreign contaminants, it's not a toxinheal drug. of course its safe for slimes
			M.take_overall_damage(1)
			if(prob(5))
				to_chat(M, "<span class='userdanger'>A tear opens in your flesh!</span>")
				M.add_splatter_floor()
		if(M.getCloneLoss() && cellheal)
			M.adjustCloneLossAbstract(-1)
			M.take_overall_damage(burn = 2) //this uses burn, so as not to make it so you can heal brute to heal all the damage types this deals, and it isn't a no-brainer to use with Pituitary
			if(prob(5))
				to_chat(M, "<span class='userdanger'>A nasty rash appears on your skin!</span>")
	else if(prob(2) && ((M.getCloneLoss() && cellheal) || (M.getToxLoss() && toxheal) || M.radiation))
		to_chat(M, "<span class='notice'>You feel a tingling sensation</span>")
