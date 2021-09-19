/*
//////////////////////////////////////
Viral adaptation

	Moderate stealth boost.
	Major Increases to resistance.
	Reduces stage speed.
	No change to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viraladaptation
	name = "Viral self-adaptation"
	desc = "The virus mimics the function of normal body cells, becoming harder to spot and to eradicate, but reducing its speed."
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmission = 0
	level = 3

/*
//////////////////////////////////////
Viral evolution

	Moderate stealth reductopn.
	Major decreases to resistance.
	increases stage speed.
	increase to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viralevolution
	name = "Viral evolutionary acceleration"
	desc = "The virus quickly adapts to spread as fast as possible both outside and inside a host. \
	This, however, makes the virus easier to spot, and less able to fight off a cure."
	stealth = -2
	resistance = -3
	stage_speed = 5
	transmission = 3
	level = 3

/*
//////////////////////////////////////

Viral aggressive metabolism

	Somewhat increased stealth.
	Abysmal resistance.
	Increased stage speed.
	Poor transmitability.
	Medium Level.

Bonus
	The virus starts at stage 5, but after a certain time will start curing itself.
	Stages still increase naturally with stage speed.

//////////////////////////////////////
*/

/datum/symptom/viralreverse

	name = "Viral aggressive metabolism"
	desc = "The virus sacrifices its long term survivability to nearly instantly fully spread inside a host. \
	The virus will start at the last stage, but will eventually decay and die off by itself."
	stealth = 1
	resistance = -4
	stage_speed = 3
	transmission = -3
	level = 3
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/time_to_cure
	threshold_desc = "<b>Resistance/Stage Speed:</b> Highest between these determines the amount of time before self-curing.<br>\
					  <b>Stealth 4</b> Doubles the time before the virus self-cures"


/datum/symptom/viralreverse/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(time_to_cure > 0)
		time_to_cure--
	else
		var/mob/living/M = A.affected_mob
		Heal(M, A)

/datum/symptom/viralreverse/proc/Heal(mob/living/M, datum/disease/advance/A)
	A.stage -= 1
	if(A.stage < 2)
		to_chat(M, "<span class='notice'>You suddenly feel healthy.</span>")
		A.cure(FALSE) //Doesn't Add Resistance. Virology can now make potions for stuff, be it healing the senses or making people explode

/datum/symptom/viralreverse/Start(datum/disease/advance/A)
	if(!..())
		return
	A.stage = 5
	if(A.stealth >= 4) //more time before it's cured
		power = 2
	time_to_cure = max(A.resistance, A.stage_rate) * 10 * power
