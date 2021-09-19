/// A blank slate gamemode for running events. Like the old secret_extended. Can be inherited
/datum/game_mode/event
	name = "event"
	config_tag = "event"
	announce_text = "An admin is running an event!"
	false_report_weight = 0
	required_players = 0

	title_icon = null

	// A few vars that the admins can set if they wish
	var/endround_report = "The event has concluded!"
	var/intercept_message

/datum/game_mode/event/pre_setup()
	return 1

/datum/game_mode/event/generate_report()
	return endround_report

/datum/game_mode/event/send_intercept(report = 0)
	if(intercept_message)
		priority_announce(intercept_message, "Security Report", SSstation.announcer.get_rand_report_sound())

/datum/game_mode/event/generate_station_goals()
	return
