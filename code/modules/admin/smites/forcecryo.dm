/// Cryo's the target, opening up their job slot in the lobby
/datum/smite/forcecryo
	name = "Force Cryo"

/datum/smite/forcecryo/effect(client/user, mob/living/target)
	. = ..()
	forcecryo(target)
