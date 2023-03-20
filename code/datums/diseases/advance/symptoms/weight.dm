/*
//////////////////////////////////////

Weight Loss

	Very very noticeable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmission.
	High level.

Bonus
	Decreases the weight of the mob,
	forcing it to be skinny.

//////////////////////////////////////
*/

/datum/symptom/weight_loss

	name = "Weight Loss"
	desc = "The virus mutates the host's metabolism, making it almost unable to gain nutrition from food."
	stealth = 0
	resistance = 2
	stage_speed = -2
	transmission = -1
	level = 3
	severity = 2
	base_message_chance = 100
	symptom_delay_min = 15
	symptom_delay_max = 45
	var/starving = TRUE
	prefixes = list("Starving ")
	bodies = list("Diet")
	threshold_desc = "<b>Stealth 2:</b> The symptom is less noticeable, and does not cause starvation."

/datum/symptom/weight_loss/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 2) //warn less often
		severity -= 3


/datum/symptom/weight_loss/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 2) //warn less often
		base_message_chance = 25
		starving = FALSE

/datum/symptom/weight_loss/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>[pick("You feel hungry.", "You crave for food.")]</span>")
		else
			to_chat(M, "<span class='warning'><i>[pick("So hungry...", "You'd kill someone for a bite of food...", "Hunger cramps seize you...")]</i></span>")
			M.overeatduration = max(M.overeatduration - 100, 0)
			if(starving)
				M.adjust_nutrition(-100)
