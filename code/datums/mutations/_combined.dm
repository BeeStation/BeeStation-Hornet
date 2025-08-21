/datum/generecipe
	var/required = "" //it hurts so bad but initial is not compatible with lists
	var/result = null

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	for(var/A in GLOB.mutation_recipes)
		if(findtext(A, "[mutation1]") && findtext(A, "[mutation2]"))
			return GLOB.mutation_recipes[A]

/* RECIPES */

/datum/generecipe/hulk
	required = "/datum/mutation/strong; /datum/mutation/radioactive"
	result = /datum/mutation/hulk

/datum/generecipe/shock
	required = "/datum/mutation/insulated; /datum/mutation/radioactive"
	result = /datum/mutation/shock

/datum/generecipe/antiglow
	required = "/datum/mutation/glow; /datum/mutation/void"
	result = /datum/mutation/glow/anti

/datum/generecipe/cluwne
	required = "/datum/mutation/clumsy; /datum/mutation/badblink"
	result = /datum/mutation/cluwne
