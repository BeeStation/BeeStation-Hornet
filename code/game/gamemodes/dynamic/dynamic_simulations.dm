#ifdef TESTING
/datum/dynamic_simulation
	var/datum/game_mode/dynamic/dynamic
	var/datum/dynamic_simulation_config/config
	var/list/mock_candidates = list()

/datum/dynamic_simulation/proc/create_candidates(players)
	GLOB.new_player_list.Cut()

	for(var/_ in 1 to players)
		// mock_new_player is added to new_player_list in 'new_player.dm' 'Initialize'
		var/mob/dead/new_player/mock_new_player = new
		mock_new_player.ready = PLAYER_READY_TO_PLAY

		var/datum/mind/mock_mind = new
		mock_new_player.mind = mock_mind

		var/datum/client_interface/mock_client = new

		var/datum/preferences/prefs = new
		mock_client.prefs = prefs

		mock_new_player.mock_client = mock_client

		mock_candidates += mock_new_player

/datum/dynamic_simulation/proc/simulate()
	dynamic = new

	create_candidates(config.roundstart_players)
	dynamic.pre_setup()

	var/total_antags = 0
	var/list/roundstart_rulesets = list()
	for(var/_ruleset in dynamic.executed_roundstart_rulesets)
		var/datum/dynamic_ruleset/ruleset = _ruleset
		roundstart_rulesets += ruleset.name
		total_antags += ruleset.drafted_players_amount

	return list(
		"roundstart_players" = config.roundstart_players,
		"roundstart_points" = dynamic.roundstart_points,
		"roundstart_rulesets" = roundstart_rulesets.Join(", "),
		"antag_percent" = total_antags / config.roundstart_players,
		)

/datum/dynamic_simulation_config
	/// How many players round start should there be?
	var/roundstart_players

/client/proc/run_dynamic_simulations()
	set name = "Run Dynamic Simulations"
	set category = "Debug"

	// Screen popup
	var/simulations = input(usr, "Enter number of simulations") as num
	var/roundstart_players = input(usr, "Enter number of round start players") as num

	SSticker.mode = config.pick_mode("dynamic")
	message_admins("Running dynamic simulations...")

	// Set config
	var/datum/dynamic_simulation_config/dynamic_config = new
	dynamic_config.roundstart_players = roundstart_players

	var/list/outputs = list()
	for(var/count in 1 to simulations)
		var/datum/dynamic_simulation/simulator = new
		simulator.config = dynamic_config

		var/output = simulator.simulate()
		outputs += list(output)

		if(CHECK_TICK)
			log_world("[count]/[simulations]")

	message_admins("Writing file...")
	WRITE_FILE(file("[GLOB.log_directory]/dynamic_simulations.json"), json_encode(outputs))
	message_admins("File complete.")
#endif
