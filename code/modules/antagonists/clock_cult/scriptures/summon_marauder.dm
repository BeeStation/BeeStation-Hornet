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
	var/list/mob/dead/observer/candidates
	var/mob/dead/observer/selected

/datum/clockcult/scripture/marauder/invoke()
	candidates = pollGhostCandidates("Would you like to play as a clockwork marauder?", ROLE_SERVANT_OF_RATVAR, null, null, 100, POLL_IGNORE_CLOCKWORK)
	if(LAZYLEN(candidates))
		selected = pick(candidates)
	if(!selected)
		to_chat(invoker, "<span class='brass'><i>There are no ghosts willing to be a Clockwork Marauder!</i></span>")
		invoke_fail()
		if(invokation_chant_timer)
			deltimer(invokation_chant_timer)
			invokation_chant_timer = null
		end_invoke()
		return
	..()

/datum/clockcult/scripture/marauder/invoke_success()
	var/mob/new_mob = new /mob/living/simple_animal/clockwork_marauder(get_turf(invoker))
	new_mob.key = selected.key
	selected = null

/datum/clockcult/scripture/marauder/check_special_requirements(mob/user)
	if(!..())
		return FALSE
	if(LAZYLEN(GLOB.clockwork_marauders) >= 4)
		to_chat(user, "<span class='brass'>The mechanical-soul infrastructure of Reebe is too weak to support more clockwork battle constructs!</span>")
		return FALSE
	return TRUE
