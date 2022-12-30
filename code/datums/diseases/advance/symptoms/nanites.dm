/datum/symptom/nano_boost
	name = "Nano-symbiosis"
	desc = "The virus reacts to nanites in the host's bloodstream by enhancing their replication cycle. May cause unpredictable nanite behaviour. Heals the host's mechanical limbs."
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmission = -1
	level = 6
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Nano-")
	suffixes = list(" Silicophilia")
	var/reverse_boost = FALSE
	threshold_desc = "<b>Transmission 5:</b> Increases the virus' growth rate while nanites are present.<br>\
					  <b>Stage Speed 7:</b> Increases the replication boost."
	threshold_ranges = list(
		"transmission" = list(3, 7),
		"stage speed" = list(5, 9)
	)

/datum/symptom/nano_boost/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= get_threshold("transmission")) //reverse boost
		reverse_boost = TRUE
	if(A.stage_rate >= get_threshold("stage speed")) //more nanites
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
	if(A.stage >= 4)
		M.heal_overall_damage((0.5 * power), (0.5 * power), required_status = BODYTYPE_ROBOTIC)

/datum/symptom/nano_boost/Threshold(datum/disease/advance/A)
	if(!..())
		return
	threshold_desc = "<b>Transmission [get_threshold("transmission")]:</b> Increases the virus' growth rate while nanites are present.<br>\
					  <b>Stage Speed [get_threshold("stage speed")]:</b> Increases the replication boost."
	return threshold_desc

/datum/symptom/nano_destroy
	name = "Silicolysis"
	desc = "The virus reacts to nanites in the host's bloodstream by attacking and consuming them. May also cause nanites to go haywire. Damages the host's mechanical limbs."
	stealth = 0
	resistance = 4
	stage_speed = -1
	transmission = 1
	level = 6
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Nano-")
	suffixes = list(" Silicophobia")
	var/reverse_boost = FALSE
	threshold_desc = "<b>Stage Speed 5:</b> Increases the virus' growth rate while nanites are present.<br>\
					  <b>Resistance 7:</b> Severely increases the rate at which the nanites are destroyed."
	threshold_ranges = list(
		"stage speed" = list(3, 7),
		"resistance" = list(6, 8)
	)

/datum/symptom/nano_destroy/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= get_threshold("stage speed")) //reverse boost
		reverse_boost = TRUE
	if(A.resistance >= get_threshold("resistance")) //more nanites
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
	if(A.stage >= 4)
		M.take_overall_damage((1 * power), required_status = BODYTYPE_ROBOTIC)

/datum/symptom/nano_destroy/Threshold(datum/disease/advance/A)
	if(!..())
		return
	threshold_desc = "<b>Stage Speed [get_threshold("stage speed")]:</b> Increases the virus' growth rate while nanites are present.<br>\
					  <b>Resistance [get_threshold("resistance")]:</b> Severely increases the rate at which the nanites are destroyed."
	return threshold_desc