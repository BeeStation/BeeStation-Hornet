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
	name = "Viral Self-Adaptation"
	desc = "The virus mimics the function of normal body cells, becoming harder to spot and to eradicate, but reducing its speed. This symptom discourages disease mutation"
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmission = 0
	level = 4
	prefixes = list("Chronic ")

/datum/symptom/viraladaptation/OnAdd(datum/disease/advance/A)
	A.mutability -= 0.5

/datum/symptom/viraladaptation/OnRemove(datum/disease/advance/A)
	A.mutability += 0.5

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
	name = "Viral Evolutionary Acceleration"
	desc = "The virus quickly adapts to spread as fast as possible both outside and inside a host. \
	This, however, makes the virus easier to spot, and less able to fight off a cure. This symptom encourages disease mutation"
	stealth = -2
	resistance = -3
	stage_speed = 5
	transmission = 3
	level = 4
	prefixes = list("Unstable ")

/datum/symptom/viralevolution/OnAdd(datum/disease/advance/A)
	A.mutability += 2

/datum/symptom/viralevolution/OnRemove(datum/disease/advance/A)
	A.mutability -= 1

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

	name = "Viral Aggressive Metabolism"
	desc = "The virus sacrifices its long term survivability to nearly instantly fully spread inside a host. \
	The virus will start at the last stage, but will eventually decay and die off by itself."
	stealth = 1
	resistance = 1
	stage_speed = 3
	transmission = -4
	level = 4
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Spontaneous ")
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
		to_chat(M, span_notice("You suddenly feel healthy."))
		A.cure(FALSE) //Doesn't Add Resistance. Virology can now make potions for stuff, be it healing the senses or making people explode

/datum/symptom/viralreverse/Start(datum/disease/advance/A)
	if(!..())
		return
	A.stage = 5
	if(A.stealth >= 4) //more time before it's cured
		power = 2
	time_to_cure = max(A.resistance, A.stage_rate) * 10 * power

/*
//////////////////////////////////////

Viral Suspended Animation

	Very high stealth.
	Abysmal resistance.
	Poor stage speed.
	Decent transmitability.
	Medium Level.

Bonus
	The virus does not start until stage 5

//////////////////////////////////////
*/

/datum/symptom/viralincubate
	name = "Viral Suspended Animation"
	desc = "The virus has very little effect until it reaches its final stage"
	stealth = 4
	resistance = -2
	stage_speed = -2
	transmission = 1
	level = 4
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Asymptomatic ")
	var/list/captives = list()
	var/used = FALSE

/datum/symptom/viralincubate/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage >= 5)
		for(var/datum/symptom/S as() in captives)
			S.stopped = FALSE
			captives -= S
		if(!LAZYLEN(captives))
			stopped = TRUE
	else if(!used)
		for(var/datum/symptom/S as() in A.symptoms)
			if(S.neutered)
				continue
			if(S == src)
				continue
			S.stopped = TRUE
			captives += S
		used = TRUE


/*
//////////////////////////////////////

Viral power multiplier

	Average stats
	UNOBTAINABLE- THIS SYMPTOM IS FOR ADMINBUS OR WEIRD CRAZY SHIT. You can enable it if you like, but be warned that this symptom is potentially very abusable

Bonus
	All unneutered symptoms in the virus have their power boosted

//////////////////////////////////////
*/
/datum/symptom/viralpower
	name = "Viral power multiplier"
	desc = "The virus has more powerful symptoms. May have unpredictable effects"
	stealth = 2
	resistance = 2
	stage_speed = 2
	transmission = 2
	level = -1 //currently unobtainable except by adminbus
	prefixes = list("Super", "Mega", "Admin ")
	var/maxpower
	var/powerbudget
	var/scramble = FALSE
	var/used = FALSE
	threshold_desc = "<b>Transmission 8:</b> Constantly scrambles the power of all unneutered symptoms.<br>\
						<b>Stage Speed 8</b> Doubles the power boost"


/datum/symptom/viralpower/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.speed >= 8)
		power = 2
	if(A.transmission >= 8)
		scramble = TRUE

/datum/symptom/viralpower/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(!used)
		for(var/datum/symptom/S as() in A.symptoms)
			if(S.neutered)
				continue
			if(S == src)
				return
			S.power += power
			maxpower += S.power
		if(scramble)
			powerbudget += power
			maxpower += power
			power = 0
		used = TRUE
	if(scramble)
		var/datum/symptom/S = pick(A.symptoms)
		if(S == src)
			return
		if(S.neutered)
			return
		if(powerbudget && (prob(50) || powerbudget == maxpower))
			S.power += 1
			powerbudget -= 1
		else if(S.power >= 2)
			S.power -= 1
			powerbudget += 1

