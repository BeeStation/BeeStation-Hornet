

//Cost function for suit Procs/Verbs/Abilities
/obj/item/clothing/suit/space/space_ninja/proc/consume_power(cost = 0, specificCheck = 0)
	var/mob/living/carbon/human/H = affecting
	if(cost && !cell.use(cost))
		to_chat(H, span_danger("Not enough energy."))
		return FALSE
	return TRUE
