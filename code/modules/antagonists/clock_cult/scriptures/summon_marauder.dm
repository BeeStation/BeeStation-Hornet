//==================================//
// !           Cogscarab          ! //
//==================================//
/datum/clockcult/scripture/marauder
	name = "Summon Clockwork Marauder"
	desc = "Summons a Clockwork Marauder, a powerful warrior that can deflect ranged attacks. Requires 3 invokers and 100 vitality."
	tip = "Use Clockwork Marauders as a powerful soldier to send into combat when the fighting gets rough."
	button_icon_state = "Clockwork Marauder"
	power_cost = 2000
	vitality_cost = 100
	invokation_time = 300
	invokation_text = list("Through the fires and flames...", "nothing outshines Eng'Ine!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 6
	invokers_required = 3
	var/mob/dead/observer/selected

/datum/clockcult/scripture/marauder/invoke()
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
		role = /datum/role_preference/roundstart/clock_cultist,
		check_jobban = ROLE_SERVANT_OF_RATVAR,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_CLOCKWORK_HELPER,
		role_name_text = "clockwork marauder",
		alert_pic = /mob/living/simple_animal/hostile/clockwork_marauder,
	)
	selected = candidate
	if(!selected)
		to_chat(invoker, span_brass("<i>There are no ghosts willing to be a Clockwork Marauder!</i>"))
		invoke_fail()
		if(invokation_chant_timer)
			deltimer(invokation_chant_timer)
			invokation_chant_timer = null
		end_invoke()
		return
	..()

/datum/clockcult/scripture/marauder/invoke_success()
	var/mob/new_mob = new /mob/living/simple_animal/hostile/clockwork_marauder(get_turf(invoker))
	new_mob.key = selected.key
	selected = null

/datum/clockcult/scripture/marauder/check_special_requirements(mob/user)
	if(!..())
		return FALSE
	if(LAZYLEN(GLOB.clockwork_marauders) >= 4)
		to_chat(user, span_brass("The mechanical-soul infrastructure of Reebe is too weak to support more clockwork battle constructs!"))
		return FALSE
	return TRUE
