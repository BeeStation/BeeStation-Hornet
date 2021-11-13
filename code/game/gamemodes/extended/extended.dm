/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	report_type = "extended"
	false_report_weight = 0
	required_players = 0

	announce_span = "notice"
	announce_text = "Just have fun and enjoy the game!"

	title_icon = "extended_white"

	var/secret = FALSE

/datum/game_mode/extended/secret
	name = "secret extended"
	config_tag ="secret_extended"
	report_type = "traitor"	//So this won't appear with traitor report
	secret = TRUE

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/generate_report()
	return "The transmission mostly failed to mention your sector. It is possible that there is nothing in the Syndicate that could threaten your station during this shift."

/datum/game_mode/extended/generate_station_goals()
	if(secret)
		return ..()
	for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/G = new T
		station_goals += G
		G.on_report()

/datum/game_mode/extended/announced/send_intercept()
	var/greenshift_message = "Thanks to the tireless efforts of our security and intelligence divisions, there are currently no credible threats to [station_name()]. All station construction projects have been authorized. Have a secure shift!"
	. += "<b><i>Central Command Status Summary</i></b><hr>"
	. += greenshift_message

	print_command_report(., "Central Command Status Summary", announce = FALSE)
	priority_announce(greenshift_message, "Security Report", SSstation.announcer.get_rand_report_sound())
