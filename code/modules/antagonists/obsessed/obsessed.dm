/datum/antagonist/obsessed
	name = "Obsessed"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	banning_key = ROLE_OBSESSED
	required_living_playtime = 0
	show_name_in_check_antagonists = TRUE
	roundend_category = "obsessed"
	silent = TRUE //not actually silent, because greet will be called by the trauma anyway.
	var/datum/brain_trauma/special/obsessed/trauma

/datum/antagonist/obsessed/New(datum/brain_trauma/special/obsessed/_trauma)
	. = ..()
	if(istype(_trauma))
		trauma = _trauma

/datum/antagonist/obsessed/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/current = new_owner.current
	if(!istype(current))
		to_chat(admin, "[roundend_category] comes from a brain trauma, so they need to at least be a carbon!")
		return
	if(!current.get_organ_by_type(/obj/item/organ/brain)) // If only I had a brain
		to_chat(admin, "[roundend_category] comes from a brain trauma, so they need to HAVE A BRAIN.")
		return
	var/datum/mind/forced_target
	if(tgui_alert(admin, "Would you like to force a specific obsession target?", "MY BELOVED", list("Yes", "No")) == "Yes")
		var/list/targets = list()
		var/list/names = list()
		for(var/datum/mind/mind in SSticker.minds)
			if(!mind.key || QDELETED(mind.current))
				continue
			var/name = key_name(mind)
			targets[name] = mind
			names |= name
		var/forced_target_name = tgui_input_list(admin, "Select a target for the obsession", "MY BELOVED", sort_list(names))
		if(forced_target_name)
			forced_target = targets[forced_target_name]
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name][forced_target ? ", with [key_name_admin(forced_target)] as their obsession" : ""].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name][forced_target ? ", with [key_name(forced_target)] as their obsession" : ""].")
	//PRESTO FUCKIN MAJESTO
	current.gain_trauma(/datum/brain_trauma/special/obsessed, null, forced_target)//ZAP

/datum/antagonist/obsessed/greet()
	if(!trauma?.obsession)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/creepalert.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner, span_userdanger("You are the Obsessed!"))
	to_chat(owner, span_bold("Realization floods over you and everything that's happened this shift makes sense."))
	to_chat(owner, span_bold("[trauma.obsession.name] has no idea how much danger they're in and you're the only person that can be there for them."))
	to_chat(owner, span_bold("Nobody else can be trusted, they are all liars and will use deceit to stab you and [trauma.obsession.name] in the back as soon as they can."))
	to_chat(owner, span_boldannounce("This role does NOT enable you to otherwise surpass what's deemed creepy behavior per the rules."))//ironic if you know the history of the antag
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Obsession",
		"Viciously crush anyone or anything that might stand between you and your obsession. Only YOU can be trusted with them, nobody else can be trusted!")

/datum/antagonist/obsessed/Destroy()
	if(trauma)
		qdel(trauma)
	. = ..()

/datum/antagonist/obsessed/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current = mob_override || owner.current
	update_obsession_icons_added(current)

/datum/antagonist/obsessed/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current = mob_override || owner.current
	update_obsession_icons_removed(current)

/datum/antagonist/obsessed/proc/forge_objectives(datum/mind/obsession_mind)
	var/list/objectives_left = list("spendtime", "polaroid", "hug")
	var/datum/objective/protect/obsessed/yandere = new
	yandere.owner = owner
	yandere.set_target(obsession_mind)
	var/datum/quirk/family_heirloom/family_heirloom = locate() in obsession_mind.quirks

	if(!QDELETED(family_heirloom?.heirloom))//oh, they have an heirloom? Well you know we have to steal that.
		objectives_left += "heirloom"

	if(obsession_mind.assigned_role && obsession_mind.assigned_role != JOB_NAME_CAPTAIN)
		objectives_left += "jealous"//if they have no coworkers, jealousy will pick someone else on the station. this will never be a free objective, nice.

	for(var/i in 1 to 3)
		var/chosen_objective = pick(objectives_left)
		objectives_left.Remove(chosen_objective)
		switch(chosen_objective)
			if("spendtime")
				var/datum/objective/spendtime/spendtime = new
				spendtime.owner = owner
				spendtime.set_target(obsession_mind)
				objectives += spendtime
				log_objective(owner, spendtime.explanation_text)
			if("polaroid")
				var/datum/objective/polaroid/polaroid = new
				polaroid.owner = owner
				polaroid.set_target(obsession_mind)
				objectives += polaroid
				log_objective(owner, polaroid.explanation_text)
			if("hug")
				var/datum/objective/hug/hug = new
				hug.owner = owner
				hug.set_target(obsession_mind)
				objectives += hug
				log_objective(owner, hug.explanation_text)
			if("heirloom")
				var/datum/objective/steal/heirloom_thief/heirloom_thief = new
				heirloom_thief.owner = owner
				heirloom_thief.set_target(obsession_mind)//while you usually wouldn't need this for stealing, we need the name of the obsession
				heirloom_thief.steal_target = family_heirloom.heirloom
				objectives += heirloom_thief
				log_objective(owner, heirloom_thief.explanation_text)
			if("jealous")
				var/datum/objective/assassinate/jealous/jealous = new
				jealous.owner = owner
				jealous.obsession = obsession_mind
				jealous.find_target()//will reroll into a coworker on the objective itself
				objectives += jealous
				log_objective(owner, jealous.explanation_text)

	objectives += yandere//finally add the protect last, because you'd have to complete it last to greentext.
	log_objective(owner, yandere.explanation_text)
	for(var/datum/objective/objective in objectives)
		objective.update_explanation_text()

/datum/antagonist/obsessed/roundend_report_header()
	return 	"[span_header("Someone became obsessed!")]<br>"

/datum/antagonist/obsessed/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(length(objectives))
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(trauma)
		if(trauma.total_time_creeping > 0)
			report += span_greentext("The [name] spent a total of [DisplayTimeText(trauma.total_time_creeping)] being near [trauma.obsession]!")
		else
			report += span_redtext("The [name] did not go near their obsession the entire round! That's extremely impressive, but you are a shit [name]!")
	else
		report += span_redtext("The [name] had no trauma attached to their antagonist ways! Either it bugged out or an admin incorrectly gave this good samaritan antag and it broke! You might as well show yourself!!")

	if(!length(objectives) || objectives_complete)
		report += span_greentextbig("The [name] was successful!")
	else
		report += span_redtextbig("The [name] has failed!")

	return report.Join("<br>")

/datum/antagonist/obsessed/proc/update_obsession_icons_added(mob/living/carbon/human/obsessed)
	var/datum/atom_hud/antag/creephud = GLOB.huds[ANTAG_HUD_OBSESSED]
	creephud.join_hud(obsessed)
	set_antag_hud(obsessed, "obsessed")

/datum/antagonist/obsessed/proc/update_obsession_icons_removed(mob/living/carbon/human/obsessed)
	var/datum/atom_hud/antag/creephud = GLOB.huds[ANTAG_HUD_OBSESSED]
	creephud.leave_hud(obsessed)
	set_antag_hud(obsessed, null)
