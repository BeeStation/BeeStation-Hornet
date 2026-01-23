#define GAMEMODE_FILEPATH "data/gamemode_executions.json"

/datum/controller/subsystem/persistence/var/list/gamemode_data = null

/datum/controller/subsystem/persistence/proc/get_gamemode_data()
	RETURN_TYPE(/list)
	if (!gamemode_data)
		load_gamemode_execution()
	return gamemode_data

/datum/controller/subsystem/persistence/proc/load_gamemode_execution()
	if(!fexists(GAMEMODE_FILEPATH))
		// Prime with initial data
		gamemode_data = list()
	else
		gamemode_data = json_decode(rustg_file_read(GAMEMODE_FILEPATH))
	if (!islist(gamemode_data))
		stack_trace("Gamemode data was loaded from the file as a non-list, this is not correct! It has been reset automatically.")
		gamemode_data = list()

/datum/controller/subsystem/persistence/proc/save_gamemode_execution()
	if (!gamemode_data)
		gamemode_data = list()
	// Reset the executed modes to 0
	for (var/datum/dynamic_ruleset/gamemode/executed_mode in SSdynamic.gamemode_executed_rulesets)
		gamemode_data["[executed_mode.type]"] = 0
	// Increment all gamemodes by 1
	for (var/key in gamemode_data)
		gamemode_data[key] = gamemode_data[key] + 1
	rustg_file_write(json_encode(gamemode_data), GAMEMODE_FILEPATH)

/datum/controller/subsystem/persistence/proc/get_rounds_since_execution(datum/dynamic_ruleset/gamemode/gamemode)
	var/located = gamemode_data["[gamemode.type]"]
	if (!isnum_safe(located))
		return 0
	return located

#undef GAMEMODE_FILEPATH
