/// Transforms the target into a cluwne
/datum/smite/cluwnify
	name = "Cluwnify"

/datum/smite/cluwnify/effect(client/user, mob/living/target)
	. = ..()
	target.cluwne()
