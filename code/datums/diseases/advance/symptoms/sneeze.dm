/*
//////////////////////////////////////

Sneezing

	Very Noticable.
	Increases resistance.
	Doesn't increase stage speed.
	Very transmissible.
	Low Level.

Bonus
	Forces a spread type of AIRBORNE
	with extra range!

//////////////////////////////////////
*/

#define SNEEZE_STEALTH "stealth"
#define SNEEZE_TRANSMISSION "transmission"

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
	prefixes = list("Nasal ")
	bodies = list("Cold")
	var/infective = FALSE
	threshold_desc = "<b>Stealth 4:</b> The symptom remains hidden until active.<br>\
					  <b>Transmission 12:</b> The host may spread the disease through sneezing."
	threshold_ranges = list(
		SNEEZE_STEALTH = list(3, 5),
		SNEEZE_TRANSMISSION = list(11, 13)
	)

/datum/symptom/sneeze/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= get_threshold(SNEEZE_STEALTH))
		suppress_warning = TRUE
	if(A.transmission >= get_threshold(SNEEZE_TRANSMISSION))
		infective = TRUE

/datum/symptom/sneeze/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(!suppress_warning)
				M.emote("sniff")
		else
			M.emote("sneeze")
			if(infective && !(A.spread_flags & DISEASE_SPREAD_FALTERED))
				addtimer(CALLBACK(A, /datum/disease/.proc/spread, 4), 20)

/datum/symptom/sneeze/Threshold(datum/disease/advance/A)
	if(!..())
		return
	threshold_desc = "<b>Stealth [get_threshold(SNEEZE_STEALTH)]:</b> The symptom remains hidden until active.<br>\
					  <b>Transmission [get_threshold(SNEEZE_TRANSMISSION)]:</b> The host may spread the disease through sneezing."
	return threshold_desc
