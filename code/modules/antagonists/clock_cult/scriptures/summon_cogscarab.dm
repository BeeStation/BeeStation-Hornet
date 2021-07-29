//==================================//
// !           Cogscarab          ! //
//==================================//
/datum/clockcult/scripture/cogscarab
	name = "Summon Cogscarab"
	desc = "Summon a Cogscarab shell, which will be possessed by fallen Rat'Varian soldiers. Requires 2 invokers. Takes longer the more cogscarabs are alive. Requires 20 vitality."
	tip = "Use Cogscarabs to fortify Reebe while the human servants convert and sabotage the crew."
	button_icon_state = "Cogscarab"
	power_cost = 500
	vitality_cost = 20
	invokation_time = 120
	invokation_text = list("My fallen brothers,", "Now is the time we rise", "Protect our lord", "Achieve greatness!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 5
	invokers_required = 2

/datum/clockcult/scripture/cogscarab/begin_invoke(mob/living/M, obj/item/clockwork/clockwork_slab/slab, bypass_unlock_checks)
	invokation_time = 120 + (60 * GLOB.cogscarabs.len)
	if(!is_reebe(M.z))
		to_chat(M, "<span class='warning'>You must do this on Reebe!</span>")
		return
	if(GLOB.cogscarabs.len > 8)
		to_chat(M, "<span class='warning'>You can't summon anymore cogscarabs.</span>")
		return
	if(GLOB.gateway_opening)
		to_chat(M, "<span class='warning'>It is too late to summon cogscarabs now, Rat'var is coming!</span>")
		return
	. = ..()

/datum/clockcult/scripture/cogscarab/invoke_success()
	new /obj/effect/mob_spawn/drone/cogscarab(get_turf(invoker))
