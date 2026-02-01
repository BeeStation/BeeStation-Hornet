/datum/action/innate/clockcult/transmit
	name = "Hierophant Transmit"
	button_icon_state = "hierophant"
	desc = "Transmit a message to your allies through the Hierophant."

/datum/action/innate/clockcult/transmit/is_available()
	if(!IS_SERVANT_OF_RATVAR(owner))
		Remove(owner)
		return FALSE
	if(owner.incapacitated())
		return FALSE
	. = ..()

/datum/action/innate/clockcult/transmit/on_activate()
	var/message = tgui_input_text(owner, "What do you want to tell your allies?", "Hierophant Transmit", "", encode = FALSE)
	hierophant_message(message, owner, "<span class='brass'>")

//Transmits a message to everyone in the cult
//Doesn't work if the cultists contain holy water, or are not on the station or Reebe
/proc/hierophant_message(msg, mob/living/sender, span = "<span class='srt_radio brass'>", use_sanitisation=TRUE, say=TRUE)
	if(CHAT_FILTER_CHECK(msg))
		if(sender)
			to_chat(sender, span_warning("You message contains forbidden words, please review the server rules and do not attempt to bypass this filter."))
		return
	var/hierophant_message = "[span]"
	if(sender?.reagents)
		if(sender.reagents.has_reagent(/datum/reagent/water/holywater, 1))
			to_chat(sender, span_nezbere("[pick("You fail to transmit your cries for help.", "Your calls into the void go unanswered.", "You try to transmit your message, but the hierophant network is silent.")]"))
			return FALSE
	if(!msg)
		if(sender)
			to_chat(sender, span_brass("You cannot transmit nothing!"))
		return FALSE
	if(use_sanitisation)
		msg = sanitize(msg)
	if(sender)
		if(say)
			sender.say("#[text2ratvar(msg)]")
		msg = sender.treat_message_min(msg)
		var/datum/antagonist/servant_of_ratvar/SoR = IS_SERVANT_OF_RATVAR(sender)
		var/prefix = "Clockbrother"
		switch(SoR.prefix)
			if(CLOCKCULT_PREFIX_EMINENCE)
				prefix = "Master"
			if(CLOCKCULT_PREFIX_MASTER)
				prefix = sender.gender == MALE\
					? "Clockfather"\
					: sender.gender == FEMALE\
						? "Clockmother"\
						: "Clockmaster"
				hierophant_message = "<span class='leader_brass'>"
			if(CLOCKCULT_PREFIX_RECRUIT)
				var/role = sender.mind?.assigned_role
				//Ew, this could be done better with a dictionary list, but this isn't much slower
				if(role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND))
					prefix = "High Priest"
				else if(role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_ENGINEERING))
					prefix = "Cogturner"
				else if(role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_MEDICAL))
					prefix = "Rejuvinator"
				else if(role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SCIENCE))
					prefix = "Calculator"
				else if(role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CARGO))
					prefix = "Pathfinder"
				else if(role in JOB_NAME_ASSISTANT)
					prefix = "Helper"
				else if(role in JOB_NAME_MIME)
					prefix = "Cogwatcher"
				else if(role in JOB_NAME_CLOWN)
					prefix = "Clonker"
				else if((role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CIVILIAN)))
					prefix = "Cogworker"
				else if(role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY))
					prefix = "Warrior"
				else if(role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SILICON))
					prefix = "CPU"
			//Fallthrough is default of "Clockbrother"
		hierophant_message += "<b>[prefix] [sender.name]</b> transmits, \"[msg]\""
	else
		hierophant_message += msg
	if(span)
		hierophant_message += "</span>"
	for(var/datum/mind/mind in GLOB.all_servants_of_ratvar)
		send_hierophant_message_to(sender, mind, hierophant_message)
	for(var/mob/dead/observer/O in GLOB.dead_mob_list)
		if(istype(sender))
			to_chat(O, "[FOLLOW_LINK(O, sender)] [hierophant_message]", type = MESSAGE_TYPE_RADIO)
		else
			to_chat(O, hierophant_message, type = MESSAGE_TYPE_RADIO)

	sender?.log_talk(msg, LOG_SAY, tag = "clock cult")

/proc/send_hierophant_message_to(mob/living/sender, datum/mind/mind, hierophant_message)
	var/mob/M = mind.current
	if(!isliving(M) || QDELETED(M))
		return
	if(M.reagents)
		if(M.reagents.has_reagent(/datum/reagent/water/holywater, 1))
			if(pick(20))
				to_chat(M, span_nezbere("You hear the cogs whispering to you, but cannot understand their words."))
			return
	to_chat(M, hierophant_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = M == sender)
