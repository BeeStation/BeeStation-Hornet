/datum/symptom/nerve_overdrive
	name = "Neurological Overdrive"
	desc = "The disease increases connectivity between the infected's nerves, reducing stuns. Increased nerve connections however make burns far more painful."
	stealth = 1
	resistance = -1
	stage_speed = 1
	transmittable = -2
	level = 9
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/fastmover = FALSE
	var/fastmover_activation = 0 //Each of the Indexes Represents a Stage, When Activated, the Index is set to true
	var/super_reduction = FALSE
	threshold_desc = "<b>Stage Speed 12:</b>The virus overclocks the nervous system making the host move even faster than normal.<br>\
                      <b>Stage Speed 15:</b>The virus tightens the synapses between nerves, allowing for even quicker recovery from stuns."

/datum/symptom/nerve_overdrive/OnAdd(datum/disease/advance/A)
	A.infectable_biotypes |= MOB_ROBOTIC //Robots don't have nerves.

/datum/symptom/nerve_overdrive/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["stage_rate"] >= 12)
		severity -= 1
	if(A.properties["stage_rate"] >= 15)
		severity -= 1

/datum/symptom/never_overdrive/Start(datum/disease/advance/A)
	. = ..()
	if(A.properties["stage_rate"] >= 12)
		fastmover = TRUE
	if(A.properties["stage_rate"] >= 15)
		super_reduction = TRUE

/datum/symptom/nerve_overdrive/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/C = A.affected_mob
	if(is_human(C))
		var/mob/living/carbon/human/H = C
		for(var/obj/item/bodypart/B in H.bodyparts)
			B.burn_reduction -= 2.5 //Burn Damage Increased. 2.5 burn reduction to avoid robusto clockwork disease breaking even on burn reduction
	switch(A.stage)
		if(2)
			C.AdjustStun(-10, FALSE)
			if(fastmover)
				if(fastmover_activation < A.stage) //Checks if Modifier for the Stage was Added
					C.add_movespeed_modifier(type, TRUE, 100, multiplicative_slowdown = -0.25, blacklisted_movetypes=(FLYING|FLOATING))
					fastmover_activation = A.stage //Ensures Multiplier Not Added 2x
		if(3)
			if(super_reduction)
				C.AdjustStun(-20, FALSE)
			else
				C.AdjustStun(-15, FALSE)
			if(fastmover)
				if(fastmover_activation < A.stage)//Checks if Modifier for Stage was Added
					C.remove_movespeed_modifier(type) //Removes Previous Stage Modifier
					C.add_movespeed_modifier(type, TRUE, 100, multiplicative_slowdown = -0.5, blacklisted_movetypes=(FLYING|FLOATING)) //New Modifier
					fastmover_activation = A.stage
		if(4)
			if(super_reduction)
				C.adjustStun(-25, FALSE)
			else
				C.AdjustStun(-20, FALSE)
			if(fastmover)
				if(fastmover_activation < A.stage)//Checks if Modifier for Stage was Added
					C.remove_movespeed_modifier(type) //Removes Previous Stage Modifier
					C.add_movespeed_modifier(type, TRUE, 100, multiplicative_slowdown = -0.75, blacklisted_movetypes=(FLYING|FLOATING)) //New Modifier
					fastmover_activation = A.stage
		if(5)
			if(super_reduction)
				C.adjustStun(-30, FALSE)
			else
				C.AdjustStun(-25, FALSE)
			if(fastmover)
				if(fastmover_activation < A.stage)//Checks if Modifier for Stage was Added
					C.remove_movespeed_modifier(type) //Removes Previous Stage Modifier
					C.add_movespeed_modifier(type, TRUE, 100, multiplicative_slowdown = -1, blacklisted_movetypes=(FLYING|FLOATING)) //New Modifier
					fastmover_activation = A.stage
		if(prob(10)) //Frequent Activation, would prefer not to Spam
				to_chat(M, "<span class='notice'>[pick("You feel like you are thinking faster than ever.", "You feel like your limbs are more responsive.", "You feel like everything is slower than you remember.", "Your eyes adjust quickly to sudden changes in light", "You feel more aware of everything around you.")]</span>")
