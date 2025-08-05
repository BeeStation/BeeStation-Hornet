SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 10

	flags = SS_KEEP_TIMING|SS_NO_INIT

	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/mode
	var/question
	var/initiator
	var/started_time
	var/time_remaining = 0
	var/list/voted = list()
	var/list/voting = list()
	var/list/choices = list()
	var/list/choice_by_ckey = list()
	var/list/generated_actions = list()

/datum/controller/subsystem/vote/fire()	//called by master_controller
	if(!mode)
		return
	time_remaining = round((started_time + CONFIG_GET(number/vote_period) - world.time)/10)
	if(time_remaining < 0)
		result()
		SStgui.close_uis(src)
		reset()

/datum/controller/subsystem/vote/proc/reset()
	mode = null
	voted.Cut()
	voting.Cut()
	choices.Cut()
	question = null
	initiator = null
	time_remaining = 0
	choice_by_ckey.Cut()

	remove_action_buttons()

/datum/controller/subsystem/vote/proc/get_result()
	//get the highest number of votes
	var/greatest_votes = 0
	var/total_votes = 0
	for(var/option in choices)
		var/votes = choices[option]
		total_votes += votes
		if(votes > greatest_votes)
			greatest_votes = votes
	//default-vote for everyone who didn't vote
	if(!CONFIG_GET(flag/default_no_vote) && choices.len)
		var/list/non_voters = GLOB.directory.Copy()
		non_voters -= voted
		for (var/non_voter_ckey in non_voters)
			var/client/C = non_voters[non_voter_ckey]
			if (!C || C.is_afk())
				non_voters -= non_voter_ckey
		if(non_voters.len > 0)
			switch(mode)
				if("restart")
					choices["Continue Playing"] += non_voters.len
					if(choices["Continue Playing"] >= greatest_votes)
						greatest_votes = choices["Continue Playing"]
				if("map")
					for (var/non_voter_ckey in non_voters)
						var/client/C = non_voters[non_voter_ckey]
						var/preferred_map = C.prefs.read_player_preference(/datum/preference/choiced/preferred_map)
						if(preferred_map && preferred_map != "Default")
							choices[preferred_map] += 1
							greatest_votes = max(greatest_votes, choices[preferred_map])
						else if(global.config.defaultmap)
							var/default_map = global.config.defaultmap.map_name
							choices[default_map] += 1
							greatest_votes = max(greatest_votes, choices[default_map])
				if("transfer")
					var/factor = 1 // factor defines how non-voters are weighted towards calling the shuttle
					switch(world.time / (1 MINUTES))
						if(0 to 60)
							factor = 0.5
						if(61 to 120)
							factor = 0.8
						if(121 to 240)
							factor = 1
						if(241 to 300)
							factor = 1.2
						else
							factor = 1.4
					choices["Initiate Crew Transfer"] += round(non_voters.len * factor)
	. = list()
	if(mode == "map")
		. += pick_weight(choices) //map is chosen by drawing votes from a hat, instead of automatically going to map with the most votes.
		return .
	//get all options with that many votes and return them in a list
	if(greatest_votes)
		for(var/option in choices)
			if(choices[option] == greatest_votes)
				. += option
	return .

/datum/controller/subsystem/vote/proc/announce_result()
	var/total_votes = 0
	for(var/option in choices)
		var/votes = choices[option]
		total_votes += votes
	var/list/winners = get_result()
	var/text
	if(winners.len > 0)
		if(question)
			text += "<b>[question]</b>"
		else
			text += "<b>[capitalize(mode)] Vote</b>"
		for(var/i in 1 to choices.len)
			var/votes = choices[choices[i]]
			if(!votes)
				votes = 0
			text += "\n<b>[choices[i]]:</b> [votes] ([total_votes ? (round((votes/total_votes), 0.01)*100) : "0"]%"
			if(mode == "map")
				text += " chance)"
			else
				text += ")"
		if(mode != "custom")
			if(winners.len > 1)
				text = "\n<b>Vote Tied Between:</b>"
				for(var/option in winners)
					text += "\n\t[option]"
			. = pick(winners)
			text += "\n<b>Vote Result: [.]</b>"
		else
			text += "\n<b>Did not vote:</b> [GLOB.clients.len-voted.len]"
	else
		text += "<b>Vote Result: Inconclusive - No Votes!</b>"
	log_vote(text)
	remove_action_buttons()
	to_chat(world, "\n<font color='purple'>[text]</font>")
	return .

/datum/controller/subsystem/vote/proc/result()
	. = announce_result()
	var/restart = FALSE
	if(.)
		switch(mode)
			if("restart")
				if(. == "Restart Round")
					restart = TRUE
			if("map")
				SSmapping.changemap(global.config.maplist[.])
				SSmapping.map_voted = TRUE
	if(restart)
		var/active_admins = FALSE
		for(var/client/C in GLOB.admins+GLOB.deadmins)
			if(!C.is_afk() && check_rights_for(C, R_SERVER))
				active_admins = TRUE
				break
		if(!active_admins)
			SSticker.Reboot("Restart vote successful.", "restart vote")
		else
			to_chat(world, span_boldannounce("Notice:Restart vote will not restart the server automatically because there are active admins on."))
			message_admins("A restart vote has passed, but there are active admins on with +server, so it has been canceled. If you wish, you may restart the server.")

	return .

/datum/controller/subsystem/vote/proc/submit_vote(vote)
	if(!mode)
		return FALSE
	if(CONFIG_GET(flag/no_dead_vote) && (usr.stat == DEAD && !isnewplayer(usr)) && !usr.client.holder && mode != "map")
		return FALSE
	if(!(vote && 1<=vote && vote<=choices.len))
		return FALSE
	// If user has already voted
	if(usr.ckey in voted)
		choices[choices[choice_by_ckey[usr.ckey]]]--
	else
		voted += usr.ckey

	choice_by_ckey[usr.ckey] = vote
	choices[choices[vote]]++	//check this
	return vote

/datum/controller/subsystem/vote/proc/initiate_vote(vote_type, initiator_key, forced=FALSE, popup=FALSE)
	//Server is still intializing.
	if(!MC_RUNNING(init_stage))
		to_chat(usr, span_warning("Cannot start vote, server is not done initializing."))
		return FALSE
	if(!mode)
		if(started_time)
			var/next_allowed_time = (started_time + CONFIG_GET(number/vote_delay))
			if(mode)
				to_chat(usr, span_warning("There is already a vote in progress! please wait for it to finish."))
				return 0

			var/lower_admin = FALSE
			var/ckey = ckey(initiator_key)
			if(GLOB.admin_datums[ckey] || forced)
				lower_admin = TRUE

			if(next_allowed_time > world.time && !lower_admin)
				to_chat(usr, span_warning("A vote was initiated recently, you must wait [DisplayTimeText(next_allowed_time-world.time)] before a new vote can be started!"))
				return 0

		reset()
		switch(vote_type)
			if("restart")
				choices.Add("Restart Round","Continue Playing")
			if("map")
				// Randomizes the list so it isn't always METASTATION
				var/list/maps = list()
				for(var/map in global.config.maplist)
					var/datum/map_config/VM = config.maplist[map]
					if(!VM.is_votable() || SSmapping.config.map_name == VM.map_name) //Always rotate away from current map
						continue
					maps += VM.map_name
					shuffle_inplace(maps)
				for(var/valid_map in maps)
					choices.Add(valid_map)
			if("custom")
				question = tgui_input_text(usr, "What is the vote for?", "Vote Title")
				if(!question) // no input so we return
					to_chat(usr, span_warning("You must enter a title for the vote."))
					return 0
				for(var/i in 1 to 10)
					var/option = capitalize(tgui_input_text(usr, "Please enter an option or hit cancel to finish (only already submitted answers will be shown)", "Question [i]:"))
					if(!option || mode || !usr.client)
						if (i == 1)
							to_chat(usr, span_warning("You must enter at least one option."))
							return 0
						else
							break
					choices.Add(option)
			else
				return 0
		mode = vote_type
		initiator = initiator_key
		started_time = world.time
		var/text = "[capitalize(mode)] vote started by [initiator ? initiator : "CentCom"]."
		if(mode == "custom")
			text += "\n[question]"
		log_vote(text)
		var/vp = CONFIG_GET(number/vote_period)
		to_chat(world, "\n<font color='purple'><b>[text]</b>\nType <b>vote</b> or click <a href='byond://winset?command=vote'>here</a> to place your votes.\nYou have [DisplayTimeText(vp)] to vote.</font>")
		sound_to_playing_players('sound/misc/server-ready.ogg')
		time_remaining = round(vp/10)
		for(var/c in GLOB.clients)
			var/client/C = c
			var/datum/action/vote/V = new
			if(question)
				V.name = "Vote: [question]"
			C.player_details.player_actions += V
			V.Grant(C.mob)
			generated_actions += V

			if(popup)
				C?.vote() // automatically popup the vote

		return 1
	return 0

/datum/controller/subsystem/vote/proc/remove_action_buttons()
	for(var/v in generated_actions)
		var/datum/action/vote/V = v
		if(!QDELETED(V))
			V.remove_from_client()
			V.Remove(V.owner)
	generated_actions = list()

AUTH_CLIENT_VERB(vote)
	set category = "OOC"
	set name = "Vote"
	if(src.mob)
		SSvote.ui_interact(src.mob)

/datum/controller/subsystem/vote/ui_state()
	return GLOB.always_state

/datum/controller/subsystem/vote/ui_interact(mob/user, datum/tgui/ui)
	// Tracks who is voting
	if(!(user.client?.ckey in voting))
		voting += user.client?.ckey
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vote")
		ui.open()

/datum/controller/subsystem/vote/ui_data(mob/user)
	var/list/data = list(
		"mode" = mode,
		"voted" = voted,
		"voting" = voting,
		"choices" = list(),
		"question" = question,
		"initiator" = initiator,
		"started_time" = started_time,
		"time_remaining" = time_remaining,
		"lower_admin" = !!user.client?.holder,
		"generated_actions" = generated_actions,
		"avmap" = CONFIG_GET(flag/allow_vote_map),
		"avr" = CONFIG_GET(flag/allow_vote_restart),
		"selectedChoice" = choice_by_ckey[user.client?.ckey],
		"upper_admin" = check_rights_for(user.client, R_ADMIN),
	)

	for(var/key in choices)
		data["choices"] += list(list(
			"name" = key,
			"votes" = choices[key] || 0
		))

	return data

/datum/controller/subsystem/vote/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/upper_admin = 0
	if(usr.client.holder)
		if(check_rights_for(usr.client, R_ADMIN))
			upper_admin = 1

	switch(action)
		if("cancel")
			if(usr.client.holder)
				reset()
		if("toggle_restart")
			if(usr.client.holder && upper_admin)
				CONFIG_SET(flag/allow_vote_restart, !CONFIG_GET(flag/allow_vote_restart))
		if("toggle_map")
			if(usr.client.holder && upper_admin)
				CONFIG_SET(flag/allow_vote_map, !CONFIG_GET(flag/allow_vote_map))
		if("restart")
			if(CONFIG_GET(flag/allow_vote_restart) || usr.client.holder)
				initiate_vote("restart", usr.key, forced=TRUE, popup=TRUE)
		if("map")
			if(CONFIG_GET(flag/allow_vote_map) || usr.client.holder)
				initiate_vote("map", usr.key, forced=TRUE, popup=TRUE)
		if("custom")
			if(usr.client.holder)
				initiate_vote("custom", usr.key, forced=TRUE, popup=TRUE)
		if("vote")
			submit_vote(round(text2num(params["index"])))
	return TRUE

/datum/controller/subsystem/vote/ui_close(mob/user, datum/tgui/tgui)
	voting -= user.client?.ckey

/datum/action/vote
	name = "Vote!"
	button_icon_state = "vote"

/datum/action/vote/on_activate()
	if(owner?.client)
		owner.client.vote()
		remove_from_client()
		Remove(owner)

/datum/action/vote/is_available()
	return 1

/datum/action/vote/proc/remove_from_client()
	if(!owner)
		return
	if(owner.client?.player_details)
		owner.client.player_details.player_actions -= src
	else if(owner.ckey)
		var/datum/player_details/P = GLOB.player_details[owner.ckey]
		if(P)
			P.player_actions -= src
