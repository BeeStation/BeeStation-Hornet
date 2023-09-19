#ifdef TESTING
/datum/dynamic_simulation
	var/datum/game_mode/dynamic/gamemode
	var/datum/dynamic_simulation_config/config
	var/list/mock_candidates = list()

/datum/dynamic_simulation/proc/initialize_gamemode(forced_threat, roundstart_players)
	gamemode = new

	if (forced_threat)
		gamemode.create_threat(forced_threat)
	else
		gamemode.generate_threat()

	gamemode.generate_budgets()
	gamemode.set_cooldowns()

/datum/dynamic_simulation/proc/create_candidates(players)
	GLOB.new_player_list.Cut()

	for (var/_ in 1 to players)
		var/mob/dead/new_player/mock_new_player = new
		mock_new_player.ready = PLAYER_READY_TO_PLAY

		var/datum/mind/mock_mind = new
		mock_new_player.mind = mock_mind

		var/datum/client_interface/mock_client = new

		var/datum/preferences/prefs = new
		mock_client.prefs = prefs

		mock_new_player.mock_client = mock_client

		mock_candidates += mock_new_player

/datum/dynamic_simulation/proc/simulate(datum/dynamic_simulation_config/config)
	src.config = config

	initialize_gamemode(config.forced_threat_level, config.roundstart_players)
	create_candidates(config.roundstart_players)
	gamemode.pre_setup()
	gamemode.simulated = TRUE

	var/total_antags = 0
	for (var/_ruleset in gamemode.executed_rules)
		var/datum/dynamic_ruleset/ruleset = _ruleset
		total_antags += ruleset.assigned.len

	var/midround_threat = gamemode.mid_round_budget

	var/list/roundstart_rules = gamemode.executed_rules.Copy()

	var/list/midround_rules = list()

	// Generate midround threats
	SSticker.round_start_time = 0
	var/simulated_time = 1
	gamemode.simulated_alive_players = config.roundstart_players
	while (simulated_time < gamemode.midround_upper_bound)
		// Simulate deaths and leaves
		gamemode.simulated_alive_players = FLOOR(gamemode.simulated_alive_players * rand(90, 100) / 100, 1)
		// Set the new world time
		simulated_time = gamemode.next_midround_injection()
		// Simulate an injection
		gamemode.forced_injection = TRUE
		// Set the simulated time
		gamemode.simulated_time = simulated_time
		// Run a midround injection
		var/datum/dynamic_ruleset/simulated_result = gamemode.try_midround_roll(TRUE)
		if (!simulated_result)
			continue
		midround_rules += list(list(
			"ruleset" = simulated_result.name,
			"weight" = simulated_result.weight,
			"cost" = simulated_result.cost,
			"execution_time" = simulated_time,
			"remaining_threat" = gamemode.mid_round_budget,
			"simulated_alive_players" = gamemode.simulated_alive_players,
			"is_lategame" = gamemode.is_lategame()
		))

	return list(
		"roundstart_players" = config.roundstart_players,
		"threat_level" = gamemode.threat_level,
		"snapshot" = list(
			"antag_percent" = total_antags / config.roundstart_players,
			"remaining_threat" = midround_threat,
			"rulesets" = roundstart_rules,
		),
		"midround_rules" = midround_rules,
	)

/datum/dynamic_simulation_config
	/// How many players round start should there be?
	var/roundstart_players

	/// Optional, force this threat level instead of picking randomly through the lorentz distribution
	var/forced_threat_level

/client/proc/run_dynamic_simulations()
	set name = "Run Dynamic Simulations"
	set category = "Debug"

	var/simulations = input(usr, "Enter number of simulations") as num
	var/roundstart_players = input(usr, "Enter number of round start players") as num
	var/forced_threat_level = input(usr, "Enter forced threat level, if you want one") as num | null

	SSticker.mode = config.pick_mode("dynamic")
	message_admins("Running dynamic simulations...")

	var/list/outputs = list()

	var/datum/dynamic_simulation_config/dynamic_config = new

	if (roundstart_players)
		dynamic_config.roundstart_players = roundstart_players

	if (forced_threat_level)
		dynamic_config.forced_threat_level = forced_threat_level

	for (var/count in 1 to simulations)
		var/datum/dynamic_simulation/simulator = new
		var/output = simulator.simulate(dynamic_config)
		outputs += list(output)

		if (CHECK_TICK)
			log_world("[count]/[simulations]")

	message_admins("Writing file...")
	WRITE_FILE(file("[GLOB.log_directory]/dynamic_simulations.json"), json_encode(outputs))
	message_admins("Writing complete.")



/proc/export_dynamic_json_of(ruleset_list)
	var/list/export = list()

	for (var/_ruleset in ruleset_list)
		var/datum/dynamic_ruleset/ruleset = _ruleset
		export[ruleset.name] = list(
			"repeatable_weight_decrease" = ruleset.repeatable_weight_decrease,
			"weight" = ruleset.weight,
			"cost" = ruleset.cost,
			"scaling_cost" = ruleset.scaling_cost,
			"antag_cap" = ruleset.antag_cap,
			"pop_per_requirement" = ruleset.pop_per_requirement,
			"requirements" = ruleset.requirements,
			"base_prob" = ruleset.base_prob,
		)

	return export


#endif
