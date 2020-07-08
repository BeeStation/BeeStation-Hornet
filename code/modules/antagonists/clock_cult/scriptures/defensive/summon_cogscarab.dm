//==================================//
// !           Cogscarab          ! //
//==================================//
/datum/clockcult/scripture/cogscarab
	name = "Summon Cogscarab"
	desc = "Summon a Cogscarab shell, which will be possessed by fallen Rat'Varian soldiers."
	tip = "Use Cogscarabs to fortify Reebe while the human servants convert and sabotage the crew."
	button_icon_state = "Cogscarab"
	power_cost = 500
	invokation_time = 120
	invokation_text = list("Here you go, good coggy")
	category = SPELLTYPE_DEFENSE
	cogs_required = 6

/datum/clockcult/scripture/cogscarab/invoke_success()
	new /obj/item/drone_shell/cogscarab(get_turf(invoker))
