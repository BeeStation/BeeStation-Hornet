/*
//////////////////////////////////////

Sneezing

	Very noticeable.
	Increases resistance.
	Doesn't increase stage speed.
	Very transmissible.
	Low Level.

Bonus
	Forces a spread type of AIRBORNE
	with extra range!

//////////////////////////////////////
*/
/datum/symptom/sneeze
	name = "Sneezing"
	desc = "The virus causes irritation of the nasal cavity, making the host sneeze occasionally."
	stealth = -2
	resistance = 3
	stage_speed = 0
	transmission = 4
	level = 1
	severity = 0
	symptom_delay_min = 5
	symptom_delay_max = 35
	required_organ = ORGAN_SLOT_LUNGS
	prefixes = list("Nasal ")
	bodies = list("Cold")
	var/infective = FALSE
	threshold_desc = "<b>Stealth 4:</b> The symptom remains hidden until active.<br>\
						<b>Transmission 12:</b> The host may spread the disease through sneezing."

/datum/symptom/sneeze/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.transmission >= 12)
		infective = TRUE

/datum/symptom/sneeze/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(M.stat == DEAD)
		return
	switch(A.stage)
		if(1, 2, 3)
			if(!suppress_warning)
				M.emote("sniff")
		else
			M.emote("sneeze")
			if((infective || CONFIG_GET(flag/unconditional_virus_spreading) || A.event) && !(A.spread_flags & DISEASE_SPREAD_FALTERED))
				addtimer(CALLBACK(A, TYPE_PROC_REF(/datum/disease, spread), 4), 20)
