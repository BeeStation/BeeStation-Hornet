/datum/game_mode/battle_royale
	name = "Battle Royale"
	config_tag = "battleroyale"

	false_report_weight = -1

	announce_span = "danger"
	announce_text = "Jump off the robusting rocket to deploy to a location, be the last person standing!"

/datum/game_mode/traitor/bros/post_setup()
	GLOB.battle_royale = new()
	INVOKE_ASYNC(GLOB.battle_royale, /datum/battle_royale_controller.proc/start, TRUE, TRUE, TRUE)
	return ..()

/datum/game_mode/traitor/bros/generate_report()
	return "The new season of Garry Centcom's hit video game has been released. Watch out for any crewmembers attempting to immitate behaviours seen in his work."
