GLOBAL_VAR(common_report) //! Contains common part of roundend report
GLOBAL_VAR(survivor_report) //! Contains shared survivor report for roundend report (part of personal report)

#define POPCOUNT_SURVIVORS "survivors"					//Not dead at roundend
#define POPCOUNT_ESCAPEES "escapees"					//Not dead and on centcom/shuttles marked as escaped
#define POPCOUNT_SHUTTLE_ESCAPEES "shuttle_escapees" 	//Emergency shuttle only.

/datum/controller/subsystem/ticker/proc/gather_roundend_feedback()
	gather_antag_data()
	record_nuke_disk_location()
	var/json_file = file("[GLOB.log_directory]/round_end_data.json")
	// All but npcs sublists and ghost category contain only mobs with minds
	var/list/file_data = list("escapees" = list("humans" = list(), "silicons" = list(), "others" = list(), "npcs" = list()), "abandoned" = list("humans" = list(), "silicons" = list(), "others" = list(), "npcs" = list()), "ghosts" = list(), "additional data" = list())
	var/num_survivors = 0 //Count of non-brain non-camera mobs with mind that are alive
	var/num_escapees = 0 //Above and on centcom z
	var/num_shuttle_escapees = 0 //Above and on escape shuttle
	var/list/area/shuttle_areas
	if(SSshuttle?.emergency)
		shuttle_areas = SSshuttle.emergency.shuttle_areas

	for(var/mob/M in GLOB.mob_list)
		var/list/mob_data = list()
		if(isnewplayer(M))
			continue

		var/escape_status = "abandoned" //default to abandoned
		var/category = "npcs" //Default to simple count only bracket
		var/count_only = TRUE //Count by name only or full info

		mob_data["name"] = M.name
		if(M.mind)
			count_only = FALSE
			mob_data["ckey"] = M.mind.key
			if(M.stat != DEAD && !isbrain(M) && !iscameramob(M))
				num_survivors++
				if(EMERGENCY_ESCAPED_OR_ENDGAMED && (M.onCentCom() || M.onSyndieBase()))
					num_escapees++
					escape_status = "escapees"
					if(shuttle_areas[get_area(M)])
						num_shuttle_escapees++
			if(isliving(M))
				var/mob/living/L = M
				mob_data["location"] = get_area(L)
				mob_data["health"] = L.health
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					category = "humans"
					if(H.mind)
						mob_data["job"] = H.mind.assigned_role
					else
						mob_data["job"] = "Unknown"
					mob_data["species"] = H.dna.species.name
				else if(issilicon(L))
					category = "silicons"
					if(isAI(L))
						mob_data["module"] = "AI"
					else if(ispAI(L))
						mob_data["module"] = "pAI"
					else if(iscyborg(L))
						var/mob/living/silicon/robot/R = L
						mob_data["module"] = R.model.name
				else
					category = "others"
					mob_data["typepath"] = M.type
		//Ghosts don't care about minds, but we want to retain ckey data etc
		if(isobserver(M))
			count_only = FALSE
			escape_status = "ghosts"
			if(!M.mind)
				mob_data["ckey"] = M.key
			category = null //ghosts are one list deep
		//All other mindless stuff just gets counts by name
		if(count_only)
			var/list/npc_nest = file_data["[escape_status]"]["npcs"]
			var/name_to_use = initial(M.name)
			if(ishuman(M))
				name_to_use = "Unknown Human" //Monkeymen and other mindless corpses
			if(npc_nest.Find(name_to_use))
				file_data["[escape_status]"]["npcs"][name_to_use] += 1
			else
				file_data["[escape_status]"]["npcs"][name_to_use] = 1
		else
			//Mobs with minds and ghosts get detailed data
			if(category)
				var/pos = length(file_data["[escape_status]"]["[category]"]) + 1
				file_data["[escape_status]"]["[category]"]["[pos]"] = mob_data
			else
				var/pos = length(file_data["[escape_status]"]) + 1
				file_data["[escape_status]"]["[pos]"] = mob_data

	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)
	file_data["additional data"]["station integrity"] = station_integrity
	WRITE_FILE(json_file, json_encode(file_data))

	SSblackbox.record_feedback("nested tally", "round_end_stats", num_survivors, list("survivors", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", num_escapees, list("escapees", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", GLOB.joined_player_list.len, list("players", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", GLOB.joined_player_list.len - num_survivors, list("players", "dead"))
	sendtodiscord(num_survivors, num_escapees, station_integrity)
	. = list()
	.[POPCOUNT_SURVIVORS] = num_survivors
	.[POPCOUNT_ESCAPEES] = num_escapees
	.[POPCOUNT_SHUTTLE_ESCAPEES] = num_shuttle_escapees
	.["station_integrity"] = station_integrity


/datum/controller/subsystem/ticker/proc/gather_antag_data()
	var/team_gid = 1
	var/list/team_ids = list()

	var/list/greentexters = list()

	for(var/datum/antagonist/A as() in GLOB.antagonists)
		if(!A.owner)
			continue

		var/list/antag_info = list()
		antag_info["key"] = A.owner.key
		antag_info["name"] = A.owner.name
		antag_info["antagonist_type"] = A.type
		antag_info["antagonist_name"] = A.name //For auto and custom roles
		antag_info["objectives"] = list()
		antag_info["team"] = list()
		var/datum/team/T = A.get_team()
		if(T)
			antag_info["team"]["type"] = T.type
			antag_info["team"]["name"] = T.name
			if(!team_ids[T])
				team_ids[T] = team_gid++
			antag_info["team"]["id"] = team_ids[T]


		var/greentexted = TRUE

		if(A.objectives.len)
			for(var/datum/objective/O as() in A.objectives)
				var/result = O.check_completion() ? "SUCCESS" : "FAIL"

				if (result == "FAIL")
					greentexted = FALSE

				antag_info["objectives"] += list(list("objective_type"=O.type,"text"=O.explanation_text,"result"=result))
		SSblackbox.record_feedback("associative", "antagonists", 1, antag_info)

		if (greentexted)
			if (A.owner && A.owner.key)
				if (A.type != /datum/antagonist/custom)
					var/client/C = GLOB.directory[ckey(A.owner.key)]
					if (C)
						greentexters |= C

	for (var/client/C in greentexters)
		C.process_greentext()



/datum/controller/subsystem/ticker/proc/record_nuke_disk_location()
	var/obj/item/disk/nuclear/N = locate() in GLOB.poi_list
	if(N)
		var/list/data = list()
		var/turf/T = get_turf(N)
		if(T)
			data["x"] = T.x
			data["y"] = T.y
			data["z"] = T.z
		var/atom/outer = get_atom_on_turf(N,/mob/living)
		if(outer != N)
			if(isliving(outer))
				var/mob/living/L = outer
				data["holder"] = L.real_name
			else
				data["holder"] = outer.name

		SSblackbox.record_feedback("associative", "roundend_nukedisk", 1 , data)

/datum/controller/subsystem/ticker/proc/gather_newscaster()
	var/json_file = file("[GLOB.log_directory]/newscaster.json")
	var/list/file_data = list()
	var/pos = 1
	for(var/V in GLOB.news_network.network_channels)
		var/datum/feed_channel/channel = V
		if(!istype(channel))
			stack_trace("Non-channel in newscaster channel list")
			continue
		file_data["[pos]"] = list("channel name" = "[channel.channel_name]", "author" = "[channel.author]", "censored" = channel.censored ? 1 : 0, "author censored" = channel.author_censor ? 1 : 0, "messages" = list())
		for(var/M in channel.messages)
			var/datum/feed_message/message = M
			if(!istype(message))
				stack_trace("Non-message in newscaster channel messages list")
				continue
			var/list/comment_data = list()
			for(var/C in message.comments)
				var/datum/feed_comment/comment = C
				if(!istype(comment))
					stack_trace("Non-message in newscaster message comments list")
					continue
				comment_data += list(list("author" = "[comment.author]", "time stamp" = "[comment.time_stamp]", "body" = "[comment.body]"))
			file_data["[pos]"]["messages"] += list(list("author" = "[message.author]", "time stamp" = "[message.time_stamp]", "censored" = message.body_censor ? 1 : 0, "author censored" = message.author_censor ? 1 : 0, "photo file" = "[message.photo_file]", "photo caption" = "[message.caption]", "body" = "[message.body]", "comments" = comment_data))
		pos++
	if(GLOB.news_network.wanted_issue.active)
		file_data["wanted"] = list("author" = "[GLOB.news_network.wanted_issue.scanned_user]", "criminal" = "[GLOB.news_network.wanted_issue.criminal]", "description" = "[GLOB.news_network.wanted_issue.body]", "photo file" = "[GLOB.news_network.wanted_issue.photo_file]")
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/ticker/proc/declare_completion()
	set waitfor = FALSE

	for(var/I in round_end_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_end_events)

	for(var/client/C in GLOB.clients)
		if(C)

			C?.process_endround_metacoin()
			C?.playtitlemusic(40)

			if(CONFIG_GET(flag/allow_crew_objectives))
				var/mob/M = C?.mob
				if(M?.mind?.current && LAZYLEN(M.mind.crew_objectives))
					for(var/datum/objective/crew/CO as() in M.mind.crew_objectives)
						if(!C) //Yes, the client can be null here. BYOND moment.
							break
						if(CO.check_completion())
							C?.inc_metabalance(METACOIN_CO_REWARD, reason="Completed your crew objective!")
							CO.declared_complete = TRUE
							break

	to_chat(world, "<BR><BR><BR>[span_bigbold("The round has ended.")]")
	log_game("The round has ended.")
	SSstat.send_global_alert("Round Over", "The round has ended, the game will restart soon.")
	if(LAZYLEN(GLOB.round_end_notifiees))
		send2tgs("Notice", "[GLOB.round_end_notifiees.Join(", ")] the round has ended.")

	RollCredits()

	var/popcount = gather_roundend_feedback()
	display_report(popcount)

	CHECK_TICK

	// Add AntagHUD to everyone, see who was really evil the whole time!
	for(var/datum/atom_hud/antag/H in GLOB.huds)
		for(var/m in GLOB.player_list)
			var/mob/M = m
			H.add_hud_to(M)

	CHECK_TICK

	//Set news report and mode result
	SSdynamic.set_round_result()

	send2tgs("Server", "Round just ended.")

	if(length(CONFIG_GET(keyed_list/cross_server)))
		send_news_report()

	CHECK_TICK

	set_observer_default_invisibility(0, span_warning("The round is over! You are now visible to the living."))
	//These need update to actually reflect the real antagonists
	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!(A.name in total_antagonists))
			total_antagonists[A.name] = list()
		total_antagonists[A.name] += "[key_name(A.owner)]"

	CHECK_TICK

	//Process veteran achievements
	for(var/client/C as() in GLOB.clients)
		var/hours = round(C?.get_exp_living(TRUE)/60)
		if(hours > 1000)
			C?.give_award(/datum/award/achievement/misc/onekhours, C.mob)
		if(hours > 2000)
			C?.give_award(/datum/award/achievement/misc/twokhours, C.mob)
		if(hours > 3000)
			C?.give_award(/datum/award/achievement/misc/threekhours, C.mob)
		if(hours > 4000)
			C?.give_award(/datum/award/achievement/misc/fourkhours, C.mob)

	CHECK_TICK

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/antag_name in total_antagonists)
		var/list/L = total_antagonists[antag_name]
		log_game("[antag_name]s :[L.Join(", ")].")

	CHECK_TICK
	SSdbcore.SetRoundEnd()

	//Collects persistence features
	SSpersistence.CollectData()
	SSpersistent_paintings.save_paintings()

	//stop collecting feedback during grifftime
	SSblackbox.Seal()

	if(CONFIG_GET(flag/automapvote))
		if((world.time - SSticker.round_start_time) >= (CONFIG_GET(number/automapvote_threshold) MINUTES))
			SSvote.initiate_vote("map", "BeeBot", forced=TRUE, popup=TRUE) //automatic map voting

	sleep(50)
	ready_for_reboot = TRUE
	standard_reboot()

/datum/controller/subsystem/ticker/proc/standard_reboot()
	if(ready_for_reboot)
		if(GLOB.station_was_nuked)
			Reboot("Station destroyed by Nuclear Device.", "nuke")
		else
			Reboot("Round ended.", "proper completion")
	else
		CRASH("Attempted standard reboot without ticker roundend completion")

//Common part of the report
/datum/controller/subsystem/ticker/proc/build_roundend_report()
	var/list/parts = list()

	CHECK_TICK

	//AI laws
	parts += law_report()

	CHECK_TICK

	//Antagonists
	parts += antag_report()

	CHECK_TICK
	//Medals
	parts += medal_report()
	//Station Goals
	parts += goal_report()
	//Economy & Money
	parts += market_report()

	list_clear_nulls(parts)

	return parts.Join()

/datum/controller/subsystem/ticker/proc/survivor_report(popcount)
	var/list/parts = list()
	var/station_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED

	if(GLOB.round_id)
		var/statspage = CONFIG_GET(string/roundstatsurl)
		var/info = statspage ? "<a href='byond://?action=openLink&link=[rustg_url_encode(statspage)][GLOB.round_id]'>[GLOB.round_id]</a>" : GLOB.round_id
		parts += "[GLOB.TAB]Round ID: <b>[info]</b>"
	parts += "[GLOB.TAB]Shift Duration: <B>[DisplayTimeText(world.time - SSticker.round_start_time)]</B>"
	parts += "[GLOB.TAB]Station Integrity: <B>[GLOB.station_was_nuked ? span_redtext("Destroyed") : "[popcount["station_integrity"]]%"]</B>"
	parts += "[GLOB.TAB]Station Traits: <B>[english_list(SSstation.station_traits, nothing_text="none")]</B>"
	var/total_players = GLOB.joined_player_list.len
	if(total_players)
		parts+= "[GLOB.TAB]Total Population: <B>[total_players]</B>"
		if(station_evacuated)
			parts += "<BR>[GLOB.TAB]Evacuation Rate: <B>[popcount[POPCOUNT_ESCAPEES]] ([PERCENT(popcount[POPCOUNT_ESCAPEES]/total_players)]%)</B>"
			parts += "[GLOB.TAB](on emergency shuttle): <B>[popcount[POPCOUNT_SHUTTLE_ESCAPEES]] ([PERCENT(popcount[POPCOUNT_SHUTTLE_ESCAPEES]/total_players)]%)</B>"
		parts += "[GLOB.TAB]Survival Rate: <B>[popcount[POPCOUNT_SURVIVORS]] ([PERCENT(popcount[POPCOUNT_SURVIVORS]/total_players)]%)</B>"
		if(SSblackbox.first_death)
			var/list/ded = SSblackbox.first_death
			if(ded.len)
				parts += "[GLOB.TAB]First Death: <b>[ded["name"]], [ded["role"]], at [ded["area"]]. Damage taken: [ded["damage"]].[ded["last_words"] ? " Their last words were: \"[ded["last_words"]]\"" : ""]</b>"
			//ignore this comment, it fixes the broken sytax parsing caused by the " above
			else
				parts += "[GLOB.TAB]<i>Nobody died this shift!</i>"

	// Roundstart
	var/list/roundstart_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in SSdynamic.roundstart_executed_rulesets)
		if(roundstart_rule_counts[rule])
			roundstart_rule_counts[rule]++
		else
			roundstart_rule_counts[rule] = 1

	if(length(roundstart_rule_counts))
		parts += "[FOURSPACES]Executed roundstart rulesets:"
		for(var/datum/dynamic_ruleset/rule in roundstart_rule_counts)
			parts += "<b>[FOURSPACES][FOURSPACES][rule.name]</b>" + (roundstart_rule_counts[rule] > 1 ? " - [roundstart_rule_counts[rule]]x" : "")

	// Midround
	var/list/midround_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in SSdynamic.midround_executed_rulesets)
		if(midround_rule_counts[rule])
			midround_rule_counts[rule]++
		else
			midround_rule_counts[rule] = 1

	if(length(midround_rule_counts))
		parts += "[FOURSPACES]Executed midround rulesets:"
		for(var/datum/dynamic_ruleset/rule in midround_rule_counts)
			parts += "<b>[FOURSPACES][FOURSPACES][rule.name]</b>" + (midround_rule_counts[rule] > 1 ? " - [midround_rule_counts[rule]]x" : "")

	// Latejoin
	var/list/latejoin_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in SSdynamic.latejoin_executed_rulesets)
		if(latejoin_rule_counts[rule])
			latejoin_rule_counts[rule]++
		else
			latejoin_rule_counts[rule] = 1

	if(length(latejoin_rule_counts))
		parts += "[FOURSPACES]Executed latejoin rulesets:"
		for(var/datum/dynamic_ruleset/rule in latejoin_rule_counts)
			parts += "<b>[FOURSPACES][FOURSPACES][rule.name]</b>" + (latejoin_rule_counts[rule] > 1 ? " - [latejoin_rule_counts[rule]]x" : "")

	return parts.Join("<br>")

/client/proc/roundend_report_file()
	return "data/roundend_reports/[ckey].html"

/datum/controller/subsystem/ticker/proc/show_roundend_report(client/C, previous = FALSE)
	var/datum/browser/roundend_report = new(C, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	var/content
	var/filename = C.roundend_report_file()
	if(!previous)
		var/list/report_parts = list(personal_report(C), GLOB.common_report)
		content = report_parts.Join()
		C.remove_verb(/client/proc/show_previous_roundend_report)
		fdel(filename)
		rustg_file_append(content, filename)
	else
		content = rustg_file_read(filename)
	roundend_report.set_content(content)
	roundend_report.scripts = list()
	roundend_report.add_script("radarchart", 'html/radarchart.js')
	roundend_report.stylesheets = list()
	roundend_report.add_stylesheet("roundend", 'html/browser/roundend.css')
	roundend_report.add_stylesheet("font-awesome", 'html/font-awesome/css/all.min.css')
	roundend_report.open(FALSE)

/datum/controller/subsystem/ticker/proc/personal_report(client/C, popcount)
	var/list/parts = list()
	var/mob/M = C.mob
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(EMERGENCY_ESCAPED_OR_ENDGAMED)
				if(!M.onCentCom() && !M.onSyndieBase())
					parts += "<div class='panel stationborder'>"
					parts += span_marooned("You managed to survive, but were marooned on [station_name()]...")
				else
					parts += "<div class='panel greenborder'>"
					parts += span_greentext("You managed to survive the events on [station_name()] as [M.real_name].")
			else
				parts += "<div class='panel greenborder'>"
				parts += span_greentext("You managed to survive the events on [station_name()] as [M.real_name].")

		else
			parts += "<div class='panel redborder'>"
			parts += span_redtext("You did not survive the events on [station_name()]...")

		if(CONFIG_GET(flag/allow_crew_objectives))
			if(M.mind.current && LAZYLEN(M.mind.crew_objectives))
				for(var/datum/objective/crew/CO as() in M.mind.crew_objectives)
					if(CO.declared_complete)
						parts += "<br><br><B>Your optional objective</B>: [CO.explanation_text] [span_greentext("<B>Success!</B>")]<br>"
					else
						parts += "<br><br><B>Your optional objective</B>: [CO.explanation_text] [span_redtext("<B>Failed.</B>")]<br>"

	else
		parts += "<div class='panel stationborder'>"
	parts += "<br>"
	parts += GLOB.survivor_report
	parts += "</div>"

	return parts.Join()

/datum/controller/subsystem/ticker/proc/display_report(popcount)
	GLOB.common_report = build_roundend_report()
	GLOB.survivor_report = survivor_report(popcount)
	for(var/client/C in GLOB.clients)
		show_roundend_report(C, FALSE)
		give_show_report_button(C)
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/law_report()
	var/list/parts = list()
	var/borg_spacer = FALSE //inserts an extra linebreak to separate AIs from independent borgs, and then multiple independent borgs.
	//Silicon laws report
	for (var/mob/living/silicon/ai/aiPlayer as anything in GLOB.ai_list)
		if(aiPlayer.mind)
			parts += "<b>[aiPlayer.name]</b>'s laws [aiPlayer.stat != DEAD ? "at the end of the round" : "when it was [span_redtext("deactivated")]"] were:"
			parts += aiPlayer.laws.get_law_list(include_zeroth=TRUE)

		parts += "<b>Total law changes: [aiPlayer.law_change_counter]</b>"

		if(aiPlayer.law_change_counter >= 15)
			if (aiPlayer.client)
				aiPlayer.client.give_award(/datum/award/achievement/misc/laws)


		if (aiPlayer.connected_robots.len)
			var/borg_num = aiPlayer.connected_robots.len
			parts += "<br><b>[aiPlayer.real_name]</b>'s minions were:"
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				borg_num--
				if(robo.mind)
					parts += "<b>[robo.name]</b> [robo.stat == DEAD ? " [span_redtext("(Deactivated)")]" : ""][borg_num ?", ":""]"
		if(!borg_spacer)
			borg_spacer = TRUE

	for (var/mob/living/silicon/robot/robo as anything in GLOB.cyborg_list)
		if (!robo.connected_ai && robo.mind)
			parts += "[borg_spacer?"<br>":""]<b>[robo.name]</b> [(robo.stat != DEAD)? "[span_greentext("survived")] as an AI-less borg!" : "was [span_redtext("unable to survive")] the rigors of being a cyborg without an AI."] Its laws were:"

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				parts += robo.laws.get_law_list(include_zeroth=TRUE)

			if(!borg_spacer)
				borg_spacer = TRUE

	if(parts.len)
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	else
		return ""

/datum/controller/subsystem/ticker/proc/goal_report()
	var/list/goals = SSstation.get_station_goals()
	if(!length(goals))
		return null

	var/list/parts = list()
	for(var/datum/station_goal/goal as anything in SSstation.get_station_goals())
		parts += goal.get_result()
	return "<div class='panel stationborder'><ul>[parts.Join()]</ul></div>"

///Generate a report for how much money is on station, as well as the richest crewmember on the station.
/datum/controller/subsystem/ticker/proc/market_report()
	var/list/parts = list()

	///This is the richest account on station at roundend.
	var/datum/bank_account/mr_moneybags
	///This is the station's total wealth at the end of the round.
	var/station_vault = 0
	///How many players joined the round.
	var/total_players = GLOB.joined_player_list.len
	var/static/list/typecache_bank = typecacheof(list(/datum/bank_account/department, /datum/bank_account/remote))
	for(var/datum/bank_account/current_acc as anything in SSeconomy.bank_accounts)
		if(typecache_bank[current_acc.type])
			continue
		station_vault += current_acc.account_balance
		if(!mr_moneybags || mr_moneybags.account_balance < current_acc.account_balance)
			mr_moneybags = current_acc
	parts += "<div class='panel stationborder'>[span_header("Station Economic Summary:")]<br>"
	/* Tourist Bots
	parts += "[span_service("Service Statistics:")]<br>"
	for(var/venue_path in SSrestaurant.all_venues)
		var/datum/venue/venue = SSrestaurant.all_venues[venue_path]
		tourist_income += venue.total_income
		parts += "The [venue] served [venue.customers_served] customer\s and made [venue.total_income] credits.<br>"
	parts += "In total, they earned [tourist_income] credits[tourist_income ? "!" : "..."]<br>"
	log_econ("Roundend service income: [tourist_income] credits.")
	switch(tourist_income)
		if(0)
			parts += "[span_redtext("Service did not earn any credits...")]<br>"
		if(1 to 2000)
			parts += "[span_redtext("Centcom is displeased. Come on service, surely you can do better than that.")]<br>"
			award_service(/datum/award/achievement/jobs/service_bad)
		if(2001 to 4999)
			parts += "[span_greentext("Centcom is satisfied with service's job today.")]<br>"
			award_service(/datum/award/achievement/jobs/service_okay)
		else
			parts += "[span_reallybiggreentext("Centcom is incredibly impressed with service today! What a team!")]<br>"
			award_service(/datum/award/achievement/jobs/service_good)

	parts += "<b>General Statistics:</b><br>"
	*/
	parts += "There were [station_vault] credits collected by crew this shift.<br>"
	if(total_players > 0)
		parts += "An average of [station_vault/total_players] credits were collected.<br>"
		log_econ("Roundend credit total: [station_vault] credits. Average Credits: [station_vault/total_players]")
	if(mr_moneybags)
		parts += "The most affluent crew member at shift end was <b>[mr_moneybags.account_holder] with [mr_moneybags.account_balance]</b> cr!</div>"
	else
		parts += "Somehow, nobody made any money this shift! This'll result in some budget cuts...</div>"
	return parts

/datum/controller/subsystem/ticker/proc/medal_report()
	if(GLOB.commendations.len)
		var/list/parts = list()
		parts += span_header("Medal Commendations:")
		for (var/com in GLOB.commendations)
			parts += com
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	return ""

/datum/controller/subsystem/ticker/proc/antag_report()
	var/list/result = list()
	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/team/A in GLOB.antagonist_teams)
		if(!A.members)
			continue
		all_teams |= A

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		all_antagonists |= A

	for(var/datum/team/T in all_teams)
		result += T.roundend_report()
		for(var/datum/antagonist/X in all_antagonists)
			if(X.get_team() == T)
				all_antagonists -= X
		result += " "//newline between teams
		CHECK_TICK

	var/currrent_category
	var/datum/antagonist/previous_category

	sortTim(all_antagonists, GLOBAL_PROC_REF(cmp_antag_category))

	for(var/datum/antagonist/A in all_antagonists)
		if(!A.show_in_roundend)
			continue
		if(A.roundend_category != currrent_category)
			if(previous_category)
				result += previous_category.roundend_report_footer()
				result += "</div>"
			result += "<div class='panel redborder'>"
			result += A.roundend_report_header()
			currrent_category = A.roundend_category
			previous_category = A
		result += A.roundend_report()
		result += "<br><br>"
		CHECK_TICK

	if(all_antagonists.len)
		var/datum/antagonist/last = all_antagonists[all_antagonists.len]
		result += last.roundend_report_footer()
		result += "</div>"

	return result.Join()

/proc/cmp_antag_category(datum/antagonist/A,datum/antagonist/B)
	return sorttext(B.roundend_category,A.roundend_category)


/datum/controller/subsystem/ticker/proc/give_show_report_button(client/C)
	var/datum/action/report/R = new
	C.player_details.player_actions += R
	R.Grant(C.mob)
	to_chat(C,"<a href='byond://?src=[REF(R)];report=1'>Show roundend report again</a>")

/datum/action/report
	name = "Show roundend report"
	button_icon_state = "round_end"

/datum/action/report/on_activate()
	if(owner && GLOB.common_report && SSticker.current_state == GAME_STATE_FINISHED)
		SSticker.show_roundend_report(owner.client, FALSE)

/datum/action/report/is_available()
	return 1

/datum/action/report/Topic(href,href_list)
	if(usr != owner)
		return
	if(href_list["report"])
		trigger()
		return

///Returns a custom title for the roundend credit/report
/proc/get_custom_title_from_id(datum/mind/mind, newline=FALSE)
	if(!mind)
		return

	var/custom_title
	var/obj/item/card/id/I = mind.current?.get_idcard()
	if(I)
		if(I.registered_name == mind.name) // card must be yours
			custom_title = I.assignment // get the custom title
		if(custom_title == mind.assigned_role) // non-custom title, lame
			custom_title = null
	if(!custom_title) // still no custom title? it seems you don't have a ID card
		var/datum/record/crew/R = find_record(mind.name, GLOB.manifest.general)
		if(R)
			custom_title = R.rank // get a custom title from manifest
		if(custom_title == mind.assigned_role) // lame...
			return

	if(custom_title)
		return "[newline ? "<br/>" : " "](as [custom_title])" // i.e. " (as Plague Doctor)"

/proc/printplayer(datum/mind/ply, fleecheck)
	var/jobtext = ""
	if(ply.assigned_role || ply.special_role)
		if(ply.assigned_role != "Unassigned")
			jobtext = ply.assigned_role
		if(!jobtext)
			jobtext = ply.special_role
		if(jobtext)
			jobtext = " the <b>[jobtext]</b>"
	var/jobtext_custom = get_custom_title_from_id(ply) // support the custom job title to the roundend report

	var/text = "<b>[ply.name]</b>[jobtext][jobtext_custom] and [ply.current?.p_they() || "they"]"
	if(ply.cryoed)
		text += " [span_bluetext("entered cryosleep")]"
	else if(ply.current)
		if(ply.current.stat == DEAD)
			text += " [span_redtext("died")]"
		else
			text += " [span_greentext("survived")]"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !is_station_level(T.z))
				text += " while [span_redtext("fleeing the station")]"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " [span_redtext("had their body destroyed")]"
	return text

/proc/printplayerlist(list/players,fleecheck)
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/M in players)
		parts += "<li>[printplayer(M,fleecheck)]</li>"
	parts += "</ul>"
	return parts.Join()


/proc/printobjectives(list/objectives)
	if(!objectives || !objectives.len)
		return
	var/list/objective_parts = list()
	var/count = 1
	for(var/datum/objective/objective as() in objectives)
		objective_parts += "<b>Objective #[count++]</b>: [objective.get_completion_message()]"
	return objective_parts.Join("<br>")

/datum/controller/subsystem/ticker/proc/save_admin_data()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_adminprefix("Admin rank DB Sync blocked: Advanced ProcCall detected."))
		return
	if(CONFIG_GET(flag/admin_legacy_system)) //we're already using legacy system so there's nothing to save
		return
	else if(load_admins(TRUE)) //returns true if there was a database failure and the backup was loaded from
		return
	sync_ranks_with_db()
	var/list/sql_admins = list()
	for(var/i in GLOB.protected_admins)
		var/datum/admins/A = GLOB.protected_admins[i]
		sql_admins += list(list("ckey" = A.target, "rank" = A.rank.name))
	SSdbcore.MassInsert(format_table_name("admin"), sql_admins, duplicate_key = TRUE)
	var/datum/db_query/query_admin_rank_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] p INNER JOIN [format_table_name("admin")] a ON p.ckey = a.ckey SET p.lastadminrank = a.rank")
	query_admin_rank_update.Execute()
	qdel(query_admin_rank_update)

	//json format backup file generation stored per server
	var/json_file = file("data/admins_backup.json")
	var/list/file_data = list("ranks" = list(), "admins" = list())
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		file_data["ranks"]["[R.name]"] = list()
		file_data["ranks"]["[R.name]"]["include rights"] = R.include_rights
		file_data["ranks"]["[R.name]"]["exclude rights"] = R.exclude_rights
		file_data["ranks"]["[R.name]"]["can edit rights"] = R.can_edit_rights
	for(var/i in GLOB.admin_datums+GLOB.deadmins)
		var/datum/admins/A = GLOB.admin_datums[i]
		if(!A)
			A = GLOB.deadmins[i]
			if (!A)
				continue
		file_data["admins"]["[i]"] = A.rank.name
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/ticker/proc/update_everything_flag_in_db()
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		var/list/flags = list()
		if(R.include_rights == R_EVERYTHING)
			flags += "flags"
		if(R.exclude_rights == R_EVERYTHING)
			flags += "exclude_flags"
		if(R.can_edit_rights == R_EVERYTHING)
			flags += "can_edit_flags"
		if(!flags.len)
			continue
		var/flags_to_check = flags.Join(" != [R_EVERYTHING] AND ") + " != [R_EVERYTHING]"
		var/datum/db_query/query_check_everything_ranks = SSdbcore.NewQuery(
			"SELECT flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")] WHERE rank = :rank AND ([flags_to_check])",
			list("rank" = R.name)
		)
		if(!query_check_everything_ranks.Execute())
			qdel(query_check_everything_ranks)
			return
		if(query_check_everything_ranks.NextRow()) //no row is returned if the rank already has the correct flag value
			var/flags_to_update = flags.Join(" = [R_EVERYTHING], ") + " = [R_EVERYTHING]"
			var/datum/db_query/query_update_everything_ranks = SSdbcore.NewQuery(
				"UPDATE [format_table_name("admin_ranks")] SET [flags_to_update] WHERE rank = :rank",
				list("rank" = R.name)
			)
			if(!query_update_everything_ranks.Execute())
				qdel(query_update_everything_ranks)
				return
			qdel(query_update_everything_ranks)
		qdel(query_check_everything_ranks)


/datum/controller/subsystem/ticker/proc/sendtodiscord(var/survivors, var/escapees, var/integrity)
	var/discordmsg = ""
	discordmsg += "--------------ROUND END--------------\n"
	discordmsg += "Server: [CONFIG_GET(string/servername)]\n"
	discordmsg += "Round Number: [GLOB.round_id]\n"
	discordmsg += "Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]\n"
	discordmsg += "Players: [GLOB.player_list.len]\n"
	discordmsg += "Survivors: [survivors]\n"
	discordmsg += "Escapees: [escapees]\n"
	discordmsg += "Integrity: [integrity]\n"

	// Roundstart
	var/list/roundstart_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in SSdynamic.roundstart_executed_rulesets)
		if(roundstart_rule_counts[rule])
			roundstart_rule_counts[rule]++
		else
			roundstart_rule_counts[rule] = 1

	if(length(roundstart_rule_counts))
		discordmsg += "Executed roundstart rulesets:\n"
		for(var/datum/dynamic_ruleset/rule in roundstart_rule_counts)
			discordmsg += "[rule.name]" + (roundstart_rule_counts[rule] > 1 ? " - [roundstart_rule_counts[rule]]x" : "") + "\n"

	// Midround
	var/list/midround_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in SSdynamic.midround_executed_rulesets)
		if(midround_rule_counts[rule])
			midround_rule_counts[rule]++
		else
			midround_rule_counts[rule] = 1

	if(length(midround_rule_counts))
		discordmsg += "Executed midround rulesets:\n"
		for(var/datum/dynamic_ruleset/rule in midround_rule_counts)
			discordmsg += "[rule.name]" + (midround_rule_counts[rule] > 1 ? " - [midround_rule_counts[rule]]x" : "") + "\n"

	// Latejoin
	var/list/latejoin_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in SSdynamic.latejoin_executed_rulesets)
		if(latejoin_rule_counts[rule])
			latejoin_rule_counts[rule]++
		else
			latejoin_rule_counts[rule] = 1

	if(length(latejoin_rule_counts))
		discordmsg += "Executed latejoin rulesets:\n"
		for(var/datum/dynamic_ruleset/rule in latejoin_rule_counts)
			discordmsg += "[rule.name]" + (latejoin_rule_counts[rule] > 1 ? " - [latejoin_rule_counts[rule]]x" : "") + "\n"

	var/list/ded = SSblackbox.first_death
	if(ded)
		discordmsg += "First Death: [ded["name"]], [ded["role"]], at [ded["area"]]\n"
		var/last_words = ded["last_words"] ? "Their last words were: \"[ded["last_words"]]\"\n" : "They had no last words.\n"
		discordmsg += "[last_words]\n"
	else
		discordmsg += "Nobody died!\n"
	discordmsg += "--------------------------------------\n"
	sendooc2ext(discordmsg)
