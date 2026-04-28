/datum/clockcult/scripture/cogscarab
	name = "Summon Cogscarab"
	desc = "Summon a Cogscarab shell, which will be possessed by fallen Rat'Varian soldiers. Requires 2 invokers. Takes longer the more cogscarabs are alive. Requires 20 vitality."
	tip = "Use Cogscarabs to fortify Reebe while the human servants convert and sabotage the crew."
	invokation_text = list("My fallen brothers,", "Now is the time we rise", "Protect our lord", "Achieve greatness!")
	invokation_time = 12 SECONDS
	invokers_required = 2
	button_icon_state = "Cogscarab"
	power_cost = 500
	vitality_cost = 20
	cogs_required = 5
	category = SPELLTYPE_PRESERVATION

/datum/clockcult/scripture/cogscarab/try_to_invoke(mob/living/user)
	invokation_time = initial(invokation_time) + (6 SECONDS * length(GLOB.cogscarabs))
	return ..()

/datum/clockcult/scripture/cogscarab/can_invoke()
	. = ..()
	if(!.)
		return FALSE

	if(!is_on_reebe(invoker))
		invoker.balloon_alert(invoker, "not on Reebe!")
		return FALSE
	if(length(GLOB.cogscarabs) >= CLOCKCULT_COGSCARAB_LIMIT)
		invoker.balloon_alert(invoker, "max cogscarabs reached!")
		return FALSE
	if(GLOB.gateway_opening)
		invoker.balloon_alert(invoker, "the rift is opening!")
		return FALSE

/datum/clockcult/scripture/cogscarab/on_invoke_success()
	new /obj/effect/mob_spawn/drone/cogscarab(get_turf(invoker))
	return ..()
