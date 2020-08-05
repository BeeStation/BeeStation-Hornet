//==================================//
// !           Cogscarab          ! //
//==================================//
/datum/clockcult/scripture/cogscarab
	name = "Summon Cogscarab"
	desc = "Summon a Cogscarab shell, which will be possessed by fallen Rat'Varian soldiers. Requires 2 invokers."
	tip = "Use Cogscarabs to fortify Reebe while the human servants convert and sabotage the crew."
	button_icon_state = "Cogscarab"
	power_cost = 500
	invokation_time = 120
	invokation_text = list("My fallen brothers,", "Now is the time we rise", "Protect our lord", "Achieve greatness!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 5
	invokers_required = 2

/datum/clockcult/scripture/cogscarab/invoke_success()
	new /obj/item/drone_shell/cogscarab(get_turf(invoker))
