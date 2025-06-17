/*
//////////////////////////////////////

Deafness

	Slightly noticeable.
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Intense Level.

Bonus
	Causes intermittent loss of hearing.

//////////////////////////////////////
*/

/datum/symptom/deafness

	name = "Deafness"
	desc = "The virus causes inflammation of the eardrums, causing intermittent deafness."
	stealth = -1
	resistance = -1
	stage_speed = 1
	transmission = -3
	level = 3
	severity = 2
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 80
	prefixes = list("Aural ")
	bodies = list("Ear")
	threshold_desc = "<b>Resistance 9:</b> Causes permanent deafness, instead of intermittent.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/deafness/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 9)
		severity += 1

/datum/symptom/deafness/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.resistance >= 9) //permanent deafness
		power = 2

/datum/symptom/deafness/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(M.stat == DEAD)
		return
	switch(A.stage)
		if(3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("You hear a ringing in your ear.", "Your ears pop.")]"))
		if(5)
			if(power >= 2)
				var/obj/item/organ/ears/ears = M.get_organ_slot(ORGAN_SLOT_EARS)
				if(istype(ears) && ears.damage < ears.maxHealth)
					to_chat(M, span_userdanger("Your ears pop painfully and start bleeding!"))
					ears.damage = max(ears.damage, ears.maxHealth)
					M.emote("scream")
			else
				to_chat(M, span_userdanger("Your ears pop and begin ringing loudly!"))
				M.minimumDeafTicks(20)
