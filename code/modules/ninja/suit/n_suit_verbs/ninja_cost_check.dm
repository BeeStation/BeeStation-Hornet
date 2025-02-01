

//Cost function for suit Procs/Verbs/Abilities
/obj/item/clothing/suit/space/space_ninja/proc/ninjacost(cost = 0, specificCheck = 0)
	var/mob/living/carbon/human/H = affecting
	var/actualCost = cost
	if(cost && cell.charge < actualCost)
		to_chat(H, span_danger("Not enough energy."))
		return 1
	else
		//This shit used to be handled individually on every proc.. why even bother with a universal check proc then?
		cell.charge-=(actualCost)

	switch(specificCheck)
		if(N_ADRENALINE)
			if(!a_boost)
				to_chat(H, span_danger("You do not have any more adrenaline boosters."))
				return 1
	return (s_coold)//Returns the value of the variable which counts down to zero.
