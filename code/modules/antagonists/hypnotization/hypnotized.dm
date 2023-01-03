/proc/hypnotize(mob/living/carbon/victim, hypnotic_phrase)
	if(!victim.mind)
		return
	message_admins("[ADMIN_LOOKUPFLW(victim)] was hypnotized with the phrase '[hypnotic_phrase]'.")
	victim.log_message("was hypnotized with the phrase '[hypnotic_phrase]'.", LOG_ATTACK, color="#960000")
	log_game("[key_name(victim)] was hypnotized with the phrase '[hypnotic_phrase]'.")
	to_chat(victim, "<span class='reallybig hypnophrase'>[hypnotic_phrase]</span>")
	to_chat(victim, "<span class='notice'>[pick("You feel your thoughts focusing on this phrase... you can't seem to get it out of your head.",\
												"Your head hurts, but this is all you can think of. It must be vitally important.",\
												"You feel a part of your mind repeating this over and over. You need to follow these words.",\
												"Something about this sounds... right, for some reason. You feel like you should follow these words.",\
												"These words keep echoing in your mind. You find yourself completely fascinated by them.")]</span>")
	to_chat(victim, "<span class='boldwarning'>You've been hypnotized by this sentence. You must follow these words. If it isn't a clear order, you can freely interpret how to do so,\
										as long as you act like the words are your highest priority.</span>")
	var/atom/movable/screen/alert/hypnosis/hypno_alert = victim.throw_alert("hypnosis", /atom/movable/screen/alert/hypnosis)
	hypno_alert.desc = "\"[hypnotic_phrase]\"... your mind seems to be fixated on this concept."
	if(!islist(hypnotic_phrase))
		hypnotic_phrase = list(hypnotic_phrase)
	var/datum/mind/M = victim.mind
	var/datum/antagonist/hypnotized/B = M.has_antag_datum(/datum/antagonist/hypnotized)
	if(B)
		for(var/O in hypnotic_phrase)
			var/datum/objective/hypnotized/objective = new(O)
			B.objectives += objective
			log_objective(M, objective.explanation_text)
		B.greet()
	else
		B = new()
		for(var/O in hypnotic_phrase)
			var/datum/objective/hypnotized/objective = new(O)
			B.objectives += objective
			log_objective(M, objective.explanation_text)
		M.add_antag_datum(B)

	var/begin_message = "<span class='deadsay'><b>[victim]</b> has been hypnotized with the following objectives: "
	var/obj_message = english_list(hypnotic_phrase)
	var/end_message = "</b>.</span>"
	var/rendered = begin_message + obj_message + end_message
	deadchat_broadcast(rendered, follow_target = victim, turf_target = get_turf(victim), message_type=DEADCHAT_REGULAR)
	victim.log_message(rendered, LOG_ATTACK, color="#960000")

/datum/antagonist/hypnotized/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//Give traitor appearence on hud (If they are not an antag already)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_BRAINWASHED]
	traitorhud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "brainwash")

/datum/antagonist/hypnotized/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//Clear the hud if they haven't become something else and had the hud overwritten
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_BRAINWASHED]
	traitorhud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "brainwash")
		set_antag_hud(owner.current, null)

/datum/antagonist/hypnotized
	name = "Hypnotized Victim"
	job_rank = ROLE_HYPNOTIZED
	roundend_category = "Hypnotized victims"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	count_against_dynamic_roll_chance = FALSE

/datum/antagonist/hypnotized/on_gain()
	owner.current.log_message("has been hypnotized!", LOG_ATTACK, color="#960000")
	. = ..()

/datum/antagonist/hypnotized/on_removal()
	owner.current.log_message("is no longer hypnotized !", LOG_ATTACK, color="#960000")
	return ..()


/datum/antagonist/brainwashed/greet()
	var/i = 1
	for(var/X in objectives)
		var/datum/objective/O = X
		to_chat(owner, "<b>[i].</b> [O.explanation_text]")
		i++
	owner.current.client?.tgui_panel?.give_antagonist_popup("Hypnotized",
		"You have been hypnotized!\n\
		These strange words echo through your mind over and over.")

/datum/antagonist/brainwashed/farewell()
	owner.announce_objectives()

/datum/objective/hypnotized
	completed = TRUE
