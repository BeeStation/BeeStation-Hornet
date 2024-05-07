/datum/objective/capture
	name = "capture"
	var/amount_captured

/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	update_explanation_text()
	return target_amount

/datum/objective/capture/update_explanation_text()
	. = ..()
	explanation_text = "Capture [target_amount] lifeform\s with an energy net. Live, rare specimens are worth more."

/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	return (amount_captured >= target_amount) || ..()

/datum/objective/capture/proc/register_capture(mob/living/L)
	var/worth = 0
	if (istype(L, /mob/living/carbon/human))
		worth = 1
	else if (istype(L, /mob/living/carbon/human/species/monkey))
		worth = 0.1
	else if (istype(L, /mob/living/carbon/alien/larva))
		worth = 1
	else if (istype(L, /mob/living/carbon/alien/humanoid/royal/queen))
		worth = 3
	else if (istype(L, /mob/living/carbon/alien/humanoid))
		worth = 2
	if (L.stat == DEAD)
		worth /= 2
	amount_captured += worth
	return worth

/datum/objective/capture/admin_edit(mob/admin)
	var/count = input(admin,"How many mobs to capture ?","capture",target_amount) as num|null
	if(count)
		target_amount = count
	update_explanation_text()

/datum/objective/capture/get_completion_message()
	var/span = check_completion() ? "grentext" : "redtext"
	return "[explanation_text] <span class='[span]'>[amount_captured] lifeform\s captured!</span>"
