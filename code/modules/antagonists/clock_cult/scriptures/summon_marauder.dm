//==================================//
// !           Cogscarab          ! //
//==================================//
/datum/clockcult/scripture/marauder
	name = "Summon Clockwork Marauder"
	desc = "Summons a Clockwork Marauder, a powerful warrior that can deflect ranged attacks. Requires 3 invokers."
	tip = "Use Clockwork Marauders as an expendable soldier to send into combat when the fighting gets rough."
	button_icon_state = "Clockwork Marauder"
	power_cost = 8000
	invokation_time = 300
	invokation_text = list("Through the fires and flames...", "...nothing outshines Eng'Ine!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 6
	invokers_required = 3
	var/mob/selected

/datum/clockcult/scripture/marauder/begin_invoke(mob/living/M, obj/item/clockwork/clockwork_slab/slab, bypass_unlock_checks)
	. = ..()
	selected = pollCandidates("Would you like to play as a clockwork marauder?")

/datum/clockcult/scripture/marauder/invoke()
	if(!selected || !isobserver(selected))
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
