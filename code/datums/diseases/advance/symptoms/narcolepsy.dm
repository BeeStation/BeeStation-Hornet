
/*
//////////////////////////////////////
Narcolepsy
	Noticeable.
	Lowers resistance
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.

Bonus
	Causes drowsiness and sleep.

//////////////////////////////////////
*/
/datum/symptom/narcolepsy
	name = "Narcolepsy"
	desc = "The virus causes a hormone imbalance, making the host sleepy and narcoleptic."
	stealth = 1
	resistance = -1
	stage_speed = -2
	transmission = 0
	level = 2
	symptom_delay_min = 30
	symptom_delay_max = 50
	prefixes = list("Lazy ", "Yawning ")
	bodies = list("Sleep")
	severity = 3
	var/yawning = FALSE
	threshold_desc = "<b>Transmission 4:</b> Causes the host to periodically emit a yawn that spreads the virus in a manner similar to that of a sneeze.<br>\
					  <b>Stage Speed 10:</b> Causes narcolepsy more often, increasing the chance of the host falling asleep."

/datum/symptom/narcolepsy/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 10) //act more often
		severity += 1

/datum/symptom/narcolepsy/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.transmission >= 4) //yawning (mostly just some copy+pasted code from sneezing, with a few tweaks)
		yawning = TRUE
	if(A.stage_rate >= 10) //act more often
		symptom_delay_min = 10
		symptom_delay_max = 40

/datum/symptom/narcolepsy/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return

	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(50))
				to_chat(M, span_warning("You feel tired."))
		if(2)
			if(prob(50))
				to_chat(M, span_warning("You feel very tired."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("You try to focus on staying awake."))

			M.adjust_drowsiness_up_to(10 SECONDS, 140 SECONDS)

		if(4)
			if(prob(50))
				if(yawning)
					to_chat(M, span_warning("You try and fail to suppress a yawn."))
				else
					to_chat(M, span_warning("You nod off for a moment.")) //you can't really yawn while nodding off, can you?

			M.adjust_drowsiness_up_to(20 SECONDS, 140 SECONDS)

			if(yawning)
				M.emote("yawn")
				if(M.CanSpreadAirborneDisease())
					A.spread(6)

		if(5)
			if(prob(50))
				to_chat(M, span_warning("[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]"))

			M.adjust_drowsiness_up_to(80 SECONDS, 140 SECONDS)

			if(yawning)
				M.emote("yawn")
				if(M.CanSpreadAirborneDisease())
					A.spread(6)
