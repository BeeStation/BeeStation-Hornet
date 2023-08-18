/proc/hypnotize(mob/living/carbon/victim, hypnotic_phrase)
	if(!victim.mind)
		return
	message_admins("[ADMIN_LOOKUPFLW(victim)] was hypnotized with the phrase '[hypnotic_phrase]'.")
	victim.log_message("was hypnotized with the phrase '[hypnotic_phrase]'.", LOG_ATTACK, color="red")
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
	var/datum/mind/M = victim.mind
	var/datum/antagonist/hypnotized/B = new()
	var/datum/objective/hypnotized/objective = new(hypnotic_phrase)
	B.objectives += objective
	log_objective(M, objective.explanation_text)
	M.add_antag_datum(B)
	var/rendered = "<span class='deadsay'><b>[victim]</b> has been hypnotized with the following phrase: <b>[hypnotic_phrase]</b>.</span>"
	deadchat_broadcast(rendered, follow_target = victim, turf_target = get_turf(victim), message_type=DEADCHAT_REGULAR)
	victim.log_message(rendered, LOG_ATTACK, color="red")

/datum/antagonist/hypnotized
	name = "Hypnotized Victim"
	banning_key = ROLE_HYPNOTIZED
	roundend_category = "hypnotized victims"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	count_against_dynamic_roll_chance = FALSE

/datum/antagonist/hypnotized/on_gain()
	owner.current.log_message("has been hypnotized!", LOG_ATTACK, color="red")
	return ..()

/datum/antagonist/hypnotized/on_removal()
	owner.current.log_message("is no longer hypnotized !", LOG_ATTACK, color="red")
	if(iscarbon(owner.current))
		var/mob/living/carbon/C = owner.current
		C.cure_trauma_type(/datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY) //This normally won't happen but with admin intervention it might so just in case
	return ..()


/datum/antagonist/hypnotized/greet()
	var/i = 1
	for(var/X in objectives)
		var/datum/objective/O = X
		to_chat(owner, "<b>[i].</b> [O.explanation_text]")
		i++
	owner.current.client?.tgui_panel?.give_antagonist_popup("Hypnotized",
		"You have been hypnotized!\n\
		These strange words echo through your mind over and over.")

/datum/antagonist/hypnotized/farewell()
	owner.announce_objectives()

/datum/antagonist/hypnotized/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//Give traitor appearance on hud (If they are not an antag already)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_HYPNOTIZED]
	traitorhud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "hypnotized")

/datum/antagonist/hypnotized/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//Clear the hud if they haven't become something else and had the hud overwritten
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_HYPNOTIZED]
	traitorhud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "hypnotized")
		set_antag_hud(owner.current, null)

/datum/antagonist/hypnotized/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		return
	var/objective = stripped_input(admin, "Add a hypnotization phrase or leave empty to cancel.", "Hypnotization", null, MAX_MESSAGE_LEN)
	if(objective)
		log_objective(C, objective, admin)

	if(alert(admin,"Confirm Hypnotization","Are you sure?","Yes","No") == "No")
		return

	if(QDELETED(C))
		to_chat(admin, "Mob doesn't exist anymore")
		return
	C.cure_trauma_type(/datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY)
	C.gain_trauma(/datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY, objective)
	message_admins("[key_name_admin(admin)] has hypnotized [key_name_admin(C)] with the following phrase: [objective].")
	log_admin("[key_name(admin)] has hypnotized [key_name(C)] with the following phrase: [objective].")

/datum/objective/hypnotized
	completed = TRUE
