#define COMMUNICATION_COOLDOWN 30 SECONDS
#define COMMUNICATION_COOLDOWN_AI 30 SECONDS

SUBSYSTEM_DEF(communications)
	name = "Communications"
	flags = SS_NO_INIT | SS_NO_FIRE

	COOLDOWN_DECLARE(silicon_message_cooldown)
	COOLDOWN_DECLARE(nonsilicon_message_cooldown)

/datum/controller/subsystem/communications/proc/can_announce(mob/living/user, is_silicon)
	if(is_silicon && COOLDOWN_FINISHED(src, silicon_message_cooldown))
		return TRUE
	else if(!is_silicon && COOLDOWN_FINISHED(src, nonsilicon_message_cooldown))
		return TRUE
	else
		return FALSE

/datum/controller/subsystem/communications/proc/make_announcement(mob/living/user, is_silicon, input, auth_id, emagged)
	if(!can_announce(user, is_silicon))
		return FALSE
	if(is_silicon)
		minor_announce(input,"[user.name] Announces:", html_encode = FALSE)
		COOLDOWN_START(src, silicon_message_cooldown, COMMUNICATION_COOLDOWN_AI)
	else
		if(emagged)
			priority_announce(html_decode(user.treat_message(input)), null, 'sound/misc/announce_syndi.ogg', ANNOUNCEMENT_TYPE_SYNDICATE, has_important_message = TRUE)
		else
			priority_announce(html_decode(user.treat_message(input)), null, 'sound/misc/announce.ogg', ANNOUNCEMENT_TYPE_CAPTAIN, has_important_message = TRUE)
		COOLDOWN_START(src, nonsilicon_message_cooldown, COMMUNICATION_COOLDOWN)
	user.log_talk(input, LOG_SAY, tag="priority announcement")
	message_admins("[ADMIN_LOOKUPFLW(user)] has made a priority announcement.")

/datum/controller/subsystem/communications/proc/send_message(datum/comm_message/sending,print = TRUE,unique = FALSE)
	for(var/obj/machinery/computer/communications/C in GLOB.machines)
		if(!(C.machine_stat & (BROKEN|NOPOWER)) && is_station_level(C.z))
			if(unique)
				C.add_message(sending)
			else //We copy the message for each console, answers and deletions won't be shared
				var/datum/comm_message/M = new(sending.title,sending.content,sending.possible_answers.Copy())
				C.add_message(M)
			if(print)
				var/obj/item/paper/printed_paper = new /obj/item/paper(C.loc)
				printed_paper.name = "paper - '[sending.title]'"
				printed_paper.add_raw_text(sending.content)
				printed_paper.update_appearance()

/// Called AFTER everyone is equipped with their job
/datum/controller/subsystem/communications/proc/queue_roundstart_report()
	addtimer(CALLBACK(src, PROC_REF(send_roundstart_report)), rand(1 MINUTES, 3 MINUTES))

/datum/controller/subsystem/communications/proc/send_roundstart_report(greenshift)
	SSstation.generate_station_goals(CONFIG_GET(number/station_goal_budget))

	var/list/datum/station_goal/goals = SSstation.get_station_goals()
	if(length(goals))
		var/list/texts = list("<hr><b>Special Orders for [station_name()]:</b><br>")
		for(var/datum/station_goal/station_goal as anything in goals)
			station_goal.on_report()
			texts += station_goal.get_report()
		. += texts.Join("<hr>")

	var/list/trait_list_strings = list()
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		trait_list_strings += "[station_trait.get_report()]<BR>"
	if(length(trait_list_strings))
		. += "<hr><b>Identified shift divergencies:</b><BR>" + trait_list_strings.Join()

	print_command_report(., "[command_name()] Status Summary")
	if(!CONFIG_GET(flag/no_intercept_report) && length(SSdynamic.roundstart_executed_rulesets))
		if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_BLUE)
			SSsecurity_level.set_level(SEC_LEVEL_BLUE)

		priority_announce(
			"[SSsecurity_level.current_security_level.elevating_to_announcement]\n\n\
				A summary has been copied and printed to all communications consoles.",
			"Security level elevated.",
			ANNOUNCER_INTERCEPT,
			color_override = SSsecurity_level.current_security_level.announcement_color,
		)

#undef COMMUNICATION_COOLDOWN
#undef COMMUNICATION_COOLDOWN_AI
