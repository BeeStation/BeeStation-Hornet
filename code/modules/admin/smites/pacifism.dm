/// Makes them a pacifist
/datum/smite/pacifism
	name = "Pacify"

/datum/smite/pacifism/effect(client/user, mob/living/target)
	. = ..()

	ADD_TRAIT(target, TRAIT_PACIFISM, "adminabuse")
	to_chat(target, span_danger("You feel repulsed by the thought of violence!"))
