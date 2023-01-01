/*
//////////////////////////////////////

Coughing

	Noticable.
	Little Resistance.
	Doesn't increase stage speed much.
	Transmissibile.
	Low Level.

BONUS
	Will force the affected mob to drop small items!

//////////////////////////////////////
*/

#define COUGH_RESISTANCE_1 "resistance1"
#define COUGH_RESISTANCE_2 "resistance2"
#define COUGH_STAGE_SPEED "stage speed"
#define COUGH_STEALTH "stealth"
#define COUGH_TRANSMISSION "transmission"

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
	threshold_ranges = list(
		COUGH_RESISTANCE_1 = list(2, 4),
		COUGH_RESISTANCE_2 = list(9, 11),
		COUGH_STAGE_SPEED = list(4, 8),
		COUGH_STEALTH = list(3, 5),
		COUGH_TRANSMISSION = list(10, 12)
	)

/datum/symptom/cough/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= get_threshold(COUGH_RESISTANCE_1))
		severity += 1
		if(A.resistance >= get_threshold(COUGH_RESISTANCE_2))
			severity += 1

/datum/symptom/cough/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= get_threshold(COUGH_STEALTH))
		suppress_warning = TRUE
	if(A.resistance >= get_threshold(COUGH_RESISTANCE_1)) //strong enough to drop items
		power = 1.5
		if(A.resistance >= get_threshold(COUGH_RESISTANCE_2)) //strong enough to stun (rarely)
			power = 2
	if(A.stage_rate >= get_threshold(COUGH_STAGE_SPEED)) //cough more often
		symptom_delay_max = 10
	if(A.transmission >= get_threshold(COUGH_TRANSMISSION)) //spread virus
		infective =TRUE

/datum/symptom/cough/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span notice='warning'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>")
		else
			M.emote("cough")
			if(power >= 1.5)
				var/obj/item/I = M.get_active_held_item()
				if(I?.w_class == WEIGHT_CLASS_TINY)
					M.dropItemToGround(I)
			if(power >= 2 && prob(10))
				to_chat(M, "<span notice='userdanger'>[pick("You have a coughing fit!", "You can't stop coughing!")]</span>")
				M.Immobilize(20)
				M.emote("cough")
				addtimer(CALLBACK(M, /mob/.proc/emote, "cough"), 6)
				addtimer(CALLBACK(M, /mob/.proc/emote, "cough"), 12)
				addtimer(CALLBACK(M, /mob/.proc/emote, "cough"), 18)
			if(infective && !(A.spread_flags & DISEASE_SPREAD_FALTERED) && prob(50))
				addtimer(CALLBACK(A, /datum/disease/.proc/spread, 2), 20)

/datum/symptom/cough/Threshold(datum/disease/advance/A)
	if(!..())
		return
	threshold_desc = "<b>Resistance [get_threshold(COUGH_RESISTANCE_1)]:</b> Host will drop small items when coughing.<br>\
					  <b>Resistance [get_threshold(COUGH_RESISTANCE_2)]:</b> Occasionally causes coughing fits that stun the host.<br>\
					  <b>Stage Speed [get_threshold(COUGH_STAGE_SPEED)]:</b> Increases cough frequency.<br>\
					  <b>Stealth [get_threshold(COUGH_STEALTH)]:</b> The symptom remains hidden until active.<br>\
					  <b>Transmission [get_threshold(COUGH_TRANSMISSION)]:</b> The host's coughing will occasionally spread the virus."
	return threshold_desc
