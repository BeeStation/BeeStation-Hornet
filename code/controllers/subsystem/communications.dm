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
		var/list/message_data = user.treat_message(input)
		if(emagged)
			priority_announce(html_decode(message_data["message"]), null, 'sound/misc/announce_syndi.ogg', ANNOUNCEMENT_TYPE_SYNDICATE, has_important_message = TRUE)
		else
			priority_announce(html_decode(message_data["message"]), null, 'sound/misc/announce.ogg', ANNOUNCEMENT_TYPE_CAPTAIN, has_important_message = TRUE)
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

/datum/controller/subsystem/communications/proc/send_roundstart_report()
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

	if(CONFIG_GET(flag/intercept_report))
		. += generate_security_report(TRUE)

	print_command_report(., "[station_name()] Situation & Security Report")

/datum/controller/subsystem/communications/proc/generate_security_report(has_hidden_modes)
	. = ""
	var/list/gamemodes = list()
	var/list/blacklisted_types = list()
	var/obvious_shown = FALSE
	// Add all of the rulesets that did executed
	for (var/datum/dynamic_ruleset/ruleset in SSdynamic.gamemode_executed_rulesets)
		gamemodes += ruleset
		blacklisted_types += ruleset.type
		if (ruleset.ruleset_flags & IS_OBVIOUS_RULESET)
			obvious_shown = TRUE
	// Throw in some rulesets that could execute but didn't
	while (length(gamemodes) < 3)
		var/datum/dynamic_ruleset/false_alarm = SSdynamic.pick_ruleset(SSdynamic.gamemode_configured_rulesets, TRUE, TRUE, blacklisted_types)
		if (!false_alarm)
			break
		blacklisted_types += false_alarm.type
		// Check the obvious ruleset flag
		if (false_alarm.ruleset_flags & IS_OBVIOUS_RULESET)
			// Skip if we already showed an obvious one
			if (obvious_shown)
				continue
			obvious_shown = TRUE
		gamemodes += false_alarm
	// If we didn't have any gamemodes to bluff with, then throw in some random ones
	while (length(gamemodes) < 3)
		var/list/random_rulesets = list()
		for (var/datum/dynamic_ruleset/ruleset in SSdynamic.gamemode_configured_rulesets)
			if (!(ruleset.type in blacklisted_types))
				random_rulesets += ruleset
		if (!length(random_rulesets))
			break
		var/datum/dynamic_ruleset/selected_random = pick(random_rulesets)
		blacklisted_types += selected_random.type
		gamemodes += selected_random
	// So the first one isn't always the one that was executed
	shuffle_inplace(gamemodes)
	// Add on the gamemode reports
	. += "<hr><b>Recent Security Incidents</b><br>"
	for (var/datum/dynamic_ruleset/gamemode/gamemode_ruleset in gamemodes)
		var/report = gamemode_ruleset.security_report()
		if (report && (prob(95) || !has_hidden_modes))
			. += "[report]<br><br>"
		else
			. += "Additional risk-assessment incidents were unable to be compiled prior to the report deadline, the information on the underlying threat was unable \
			to be evaluated. Please be aware of any security incidents which are not present on this compilation.<br><br>"
	. += "It is most likely that the most serious risks to the station have already infiltrated the crew. Additional crew have been screened against some \
	major risks but new threats may have developed since the screening system was put in place.<br>"

#undef COMMUNICATION_COOLDOWN
#undef COMMUNICATION_COOLDOWN_AI
