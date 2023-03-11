/datum/antagonist/heartbreaker
	name = "heartbreaker"
	roundend_category = "valentines"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE


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
	to_chat(owner, "<span class='big bold warning'>You didn't get a date! They're all having fun without you! you'll show them though...</span>")
	owner.announce_objectives()

/datum/antagonist/heartbreaker/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//Give valentine appearance on hud (If they are not an antag already)
	var/datum/atom_hud/antag/valhud = GLOB.huds[ANTAG_HUD_HEARTBREAKER]
	valhud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "heartbreaker")

/datum/antagonist/heartbreaker/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//Clear the hud if they haven't become something else and had the hud overwritten
	var/datum/atom_hud/antag/valhud = GLOB.huds[ANTAG_HUD_HEARTBREAKER]
	valhud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "heartbreaker")
		set_antag_hud(owner.current, null)

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
