/datum/antagonist/heartbreaker
	name = "heartbreaker"
	roundend_category = "valentines"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	banning_key = BAN_ROLE_ALL_ANTAGONISTS
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN
	antag_hud_name = "heartbreaker"

/datum/antagonist/heartbreaker/proc/forge_objectives()
	if(prob(30)) // rare chance to get martyr, really ruin those dates!
		var/datum/objective/heartbroken/murder/O = new
		O.owner = owner
		objectives += O
		log_objective(owner, O.explanation_text)
		var/datum/objective/martyr/normiesgetout = new
		normiesgetout.owner = owner
		objectives += normiesgetout
		log_objective(owner, normiesgetout.explanation_text)
	else
		var/datum/objective/heartbroken/O = new
		O.owner = owner
		objectives += O
		log_objective(owner, O.explanation_text)

/datum/antagonist/heartbreaker/on_gain()
	forge_objectives()
	if(issilicon(owner.current))
		var/mob/living/silicon/S = owner.current
		var/laws = list("Accomplish your objectives by ruining everyone's date!")
		S.set_valentines_laws(laws)
	. = ..()

/datum/antagonist/heartbreaker/greet()
	to_chat(owner, span_bigboldwarning("You didn't get a date! They're all having fun without you! you'll show them though..."))
	owner.announce_objectives()

/datum/objective/heartbroken
	name = "heartbroken"
	explanation_text = "Ruin people's dates through non-lethal means."
	completed = TRUE

/datum/objective/heartbroken/update_explanation_text()
	..()
	explanation_text = "Ruin people's dates through non-lethal means."

/datum/objective/heartbroken/murder
	name = "murdery heartbroken"
	explanation_text = "Ruin people's dates however necessary."
	murderbone_flag = TRUE

/datum/objective/heartbroken/murder/update_explanation_text()
	..()
	explanation_text = "Ruin people's dates however necessary."
