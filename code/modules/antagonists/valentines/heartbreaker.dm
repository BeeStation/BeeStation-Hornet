/datum/antagonist/heartbreaker
	name = "heartbreaker"
	roundend_category = "valentines"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	banning_key = BAN_ROLE_ALL_ANTAGONISTS
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN
	antag_hud_name = "heartbreaker"

/datum/antagonist/heartbreaker/forge_objectives()
	if(prob(30)) // rare chance to get martyr, really ruin those dates!
		add_objective(new /datum/objective/heartbroken/murder())
		add_objective(new /datum/objective/martyr())
	else
		add_objective(new /datum/objective/heartbroken())

/datum/antagonist/heartbreaker/on_gain()
	. = ..()
	if(give_objectives)
		forge_objectives()
	if(issilicon(owner.current))
		var/mob/living/silicon/S = owner.current
		var/laws = list("Accomplish your objectives by ruining everyone's date!")
		S.set_valentines_laws(laws)

/datum/antagonist/heartbreaker/greet()
	to_chat(owner, span_bigboldwarning("You didn't get a date! They're all having fun without you! you'll show them though..."))
	owner.announce_objectives()

/datum/objective/heartbroken
	name = "heartbroken"
	explanation_text = "Ruin people's dates through non-lethal means."
	completed = TRUE

/datum/objective/heartbroken/murder
	name = "murdery heartbroken"
	explanation_text = "Ruin people's dates however necessary."
	murderbone_flag = TRUE
