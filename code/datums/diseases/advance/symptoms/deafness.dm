/*
//////////////////////////////////////

Deafness

	Slightly noticable.
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Intense Level.

Bonus
	Causes intermittent loss of hearing.

//////////////////////////////////////
*/

#define DEAFNESS_RESISTANCE "resistance"
#define DEAFNESS_STEALTH "stealth"

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
	threshold_ranges = list(
		DEAFNESS_RESISTANCE = list(8, 10),
		DEAFNESS_STEALTH = list(3, 5)
	)

/datum/symptom/deafness/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= get_threshold(DEAFNESS_RESISTANCE))
		severity += 1

/datum/symptom/deafness/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= get_threshold(DEAFNESS_STEALTH))
		suppress_warning = TRUE
	if(A.resistance >= get_threshold(DEAFNESS_RESISTANCE)) //permanent deafness
		power = 2

/datum/symptom/deafness/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You hear a ringing in your ear.", "Your ears pop.")]</span>")
		if(5)
			if(power >= 2)
				var/obj/item/organ/ears/ears = M.getorganslot(ORGAN_SLOT_EARS)
				if(istype(ears) && ears.damage < ears.maxHealth)
					to_chat(M, "<span class='userdanger'>Your ears pop painfully and start bleeding!</span>")
					ears.damage = max(ears.damage, ears.maxHealth)
					M.emote("scream")
			else
				to_chat(M, "<span class='userdanger'>Your ears pop and begin ringing loudly!</span>")
				M.minimumDeafTicks(20)

/datum/symptom/deafness/Threshold(datum/disease/advance/A)
	if(!..())
		return
	threshold_desc = "<b>Resistance [get_threshold(DEAFNESS_RESISTANCE)]:</b> Causes permanent deafness, instead of intermittent.<br>\
					  <b>Stealth [get_threshold(DEAFNESS_STEALTH)]:</b> The symptom remains hidden until active."
	return threshold_desc
