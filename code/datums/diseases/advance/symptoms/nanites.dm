/datum/symptom/nano_boost
	name = "Nano-symbiosis"
	desc = "The virus reacts to nanites in the host's bloodstream by enhancing their replication cycle. May cause unpredictable nanite behaviour"
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmittable = -1
	level = 7
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/reverse_boost = FALSE
	threshold_desc = "<b>Transmission 5:</b> Increases the virus' growth rate while nanites are present.<br>\
					  <b>Stage Speed 7:</b> Increases the replication boost."

/datum/symptom/nano_boost/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 5) //reverse boost
		reverse_boost = TRUE
	if(A.properties["stage_rate"] >= 7) //more nanites
		power = 2

/datum/symptom/nano_boost/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	SEND_SIGNAL(M, COMSIG_NANITE_ADJUST_VOLUME, 0.5 * power)
	if(reverse_boost && SEND_SIGNAL(M, COMSIG_HAS_NANITES))
		if(prob(A.stage_prob))
			A.stage = min(A.stage + 1,A.max_stages)
	for(var/datum/component/nanites/N in M.datum_components)
		for(var/X in N.programs)
			var/datum/nanite_program/NP = X
			if(prob(2 * power))
				NP.software_error(rand(3, 4)) //activate, deactivate, or trigger the nanites
			
/datum/symptom/nano_destroy
	name = "Silicolysis"
	desc = "The virus reacts to nanites in the host's bloodstream by attacking and consuming them. May also cause nanites to go haywire."
	stealth = 0
	resistance = 4
	stage_speed = -1
	transmittable = 1
	level = 7
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/reverse_boost = FALSE
	threshold_desc = "<b>Stage Speed 5:</b> Increases the virus' growth rate while nanites are present.<br>\
					  <b>Resistance 7:</b> Severely increases the rate at which the nanites are destroyed."

/datum/symptom/nano_destroy/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 5) //reverse boost
		reverse_boost = TRUE
	if(A.properties["resistance"] >= 7) //more nanites
		power = 3

/datum/symptom/nano_destroy/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	SEND_SIGNAL(M, COMSIG_NANITE_ADJUST_VOLUME, -0.4 * power)
	if(reverse_boost && SEND_SIGNAL(M, COMSIG_HAS_NANITES))
		if(prob(A.stage_prob))
			A.stage = min(A.stage + 1,A.max_stages)
	for(var/datum/component/nanites/N in M.datum_components)
		for(var/X in N.programs)
			var/datum/nanite_program/NP = X
			if(prob(2))
				NP.on_emp(power)
			else if(prob(2))
				NP.software_error()