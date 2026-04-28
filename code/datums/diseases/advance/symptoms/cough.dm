/*
//////////////////////////////////////

Coughing

	Noticeable.
	Little Resistance.
	Doesn't increase stage speed much.
	Transmissibile.
	Low Level.

BONUS
	Will force the affected mob to drop small items!

//////////////////////////////////////
*/

/datum/symptom/cough

	name = "Cough"
	desc = "The virus irritates the throat of the host, causing occasional coughing."
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmission = 2
	level = 1
	severity = 0
	base_message_chance = 15
	symptom_delay_min = 2
	symptom_delay_max = 15
	bodies = list("Cough")
	var/infective = FALSE
	threshold_desc = "<b>Resistance 3:</b> Host will drop small items when coughing.<br>\
						<b>Resistance 10:</b> Occasionally causes coughing fits that stun the host.<br>\
						<b>Stage Speed 6:</b> Increases cough frequency.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active.<br>\
						<b>Transmission 11:</b> The host's coughing will occasionally spread the virus."

/datum/symptom/cough/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 3)
		severity += 1
		if(A.resistance >= 10)
			severity += 1

/datum/symptom/cough/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.resistance >= 3) //strong enough to drop items
		power = 1.5
		if(A.resistance >= 10) //strong enough to stun (rarely)
			power = 2
	if(A.stage_rate >= 6) //cough more often
		symptom_delay_max = 10
	if(A.transmission >= 11) //spread virus
		infective =TRUE

/datum/symptom/cough/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(M.stat == DEAD)
		return
	switch(A.stage)
		if(1, 2, 3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning(pick("You swallow excess mucus.", "You lightly cough.")))
		else
			M.emote("cough")
			if(power >= 1.5)
				var/obj/item/I = M.get_active_held_item()
				if(I?.w_class == WEIGHT_CLASS_TINY)
					M.dropItemToGround(I)
			if(power >= 2 && prob(10))
				to_chat(M, span_userdanger(pick("You have a coughing fit!", "You can't stop coughing!")))
				M.Immobilize(20)
				M.emote("cough")
				addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, emote), "cough"), 6)
				addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, emote), "cough"), 12)
				addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, emote), "cough"), 18)
			if((infective || CONFIG_GET(flag/unconditional_virus_spreading) || A.event) && !(A.spread_flags & DISEASE_SPREAD_FALTERED) && prob(50))
				addtimer(CALLBACK(A, TYPE_PROC_REF(/datum/disease, spread), 2), 20)


