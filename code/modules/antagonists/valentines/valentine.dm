/datum/antagonist/valentine
	name = "valentine"
	roundend_category = "valentines" //there's going to be a ton of them so put them in separate category
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	replace_banned = FALSE
	var/datum/mind/date
	banning_key = UNBANNABLE_ANTAGONIST
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/antagonist/valentine/forge_objectives()
	var/datum/objective/protect/protect_objective = new
	protect_objective.owner = owner
	protect_objective.set_target(date)
	if(!ishuman(date.current))
		protect_objective.human_check = FALSE
	protect_objective.explanation_text = "Protect [date.name], your date."
	objectives += protect_objective
	log_objective(owner, protect_objective.explanation_text)

/datum/antagonist/valentine/on_gain()
	forge_objectives()
	if(isliving(owner.current) && isliving(date.current))
		var/mob/living/L = owner.current
		L.apply_status_effect(/datum/status_effect/in_love, date.current)
		//Faction assignation
		L.faction |= "[REF(date.current)]"
		L.faction |= date.current.faction
		if(issilicon(owner.current))
			var/mob/living/silicon/S = owner.current
			var/laws = list("Protect your date and do not allow them to come to harm.", "Ensure your date has a good time.")
			S.set_valentines_laws(laws)
	. = ..()

/datum/antagonist/valentine/on_removal()
	. = ..()
	if(isliving(owner.current))
		var/mob/living/L = owner.current
		L.remove_status_effect(/datum/status_effect/in_love)
		L.faction -= "[REF(date.current)]"

/datum/antagonist/valentine/greet()
	to_chat(owner, span_bigboldclown("You're on a date with [date.name]! Protect [date.current.p_them()] at all costs. This takes priority over all other loyalties, you may do whatever you can to help and protect them."))

//Squashed up a bit
/datum/antagonist/valentine/roundend_report()
	var/objectives_complete = TRUE
	if(objectives.len)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives_complete)
		return span_greentextbig("[owner.name] protected their date, [date.name]!")
	else
		return span_redtextbig("[owner.name] failed to protect their date, [date.name]!")

/datum/antagonist/valentine/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//Give valentine appearance on hud (If they are not an antag already)
	var/datum/atom_hud/antag/valhud = GLOB.huds[ANTAG_HUD_VALENTINE]
	valhud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "valentine")

/datum/antagonist/valentine/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//Clear the hud if they haven't become something else and had the hud overwritten
	var/datum/atom_hud/antag/valhud = GLOB.huds[ANTAG_HUD_VALENTINE]
	valhud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "valentine")
		set_antag_hud(owner.current, null)
