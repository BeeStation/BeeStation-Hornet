/datum/clockcult/scripture/marauder
	name = "Summon Clockwork Marauder"
	desc = "Summons a Clockwork Marauder, a powerful warrior that can deflect ranged attacks. Requires 3 invokers and 100 vitality."
	tip = "Use Clockwork Marauders as a powerful soldier to send into combat when the fighting gets rough."
	invokation_text = list("Through the fires and flames...", "nothing outshines Eng'Ine!")
	invokation_time = 30 SECONDS
	invokers_required = 3
	button_icon_state = "Clockwork Marauder"
	power_cost = 2000
	vitality_cost = 100
	cogs_required = 6
	category = SPELLTYPE_PRESERVATION

/datum/clockcult/scripture/marauder/can_invoke()
	. = ..()
	if(!.)
		return FALSE

	if(length(GLOB.clockwork_marauders) >= CLOCKCULT_MARAUDER_LIMIT)
		invoker.balloon_alert(invoker, "max marauders reached!")
		return FALSE

/datum/clockcult/scripture/marauder/on_invoke_success()
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Would you like to play as a clockwork marauder?", ROLE_SERVANT_OF_RATVAR, /datum/role_preference/antagonist/clock_cultist, 10 SECONDS, POLL_IGNORE_CLOCKWORK_HELPER)
	if(!length(candidates))
		invoker.balloon_alert(invoker, "no available ghosts!")
		return

	var/mob/dead/observer/selected = pick(candidates)
	var/mob/new_mob = new /mob/living/simple_animal/hostile/clockwork_marauder(get_turf(invoker))
	new_mob.key = selected.key
	. = ..()
