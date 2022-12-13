VERB_MANAGER_SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	use_default_stats = FALSE

	var/list/macro_sets

	///running average of how many clicks inputted by a player the server processes every second. used for the subsystem stat entry
	var/clicks_per_second = 0
	///count of how many clicks onto atoms have elapsed before being cleared by fire(). used to average with clicks_per_second.
	var/current_clicks = 0
	///acts like clicks_per_second but only counts the clicks actually processed by SSinput itself while clicks_per_second counts all clicks
	var/delayed_clicks_per_second = 0
	///running average of how many movement iterations from player input the server processes every second. used for the subsystem stat entry
	var/movements_per_second = 0
	///running average of the amount of real time clicks take to truly execute after the command is originally sent to the server.
	///if a click isnt delayed at all then it counts as 0 deciseconds.
	var/average_click_delay = 0

	var/list/movement_keys

/datum/controller/subsystem/verb_manager/input/Initialize()
	setup_default_macro_sets()

	setup_default_movement_keys()

	initialized = TRUE

	refresh_client_macro_sets()

	return ..()

// This is for when macro sets are eventualy datumized
/datum/controller/subsystem/verb_manager/input/proc/setup_default_macro_sets()
	var/list/static/default_macro_sets

	if(default_macro_sets)
		macro_sets = default_macro_sets
		return

	default_macro_sets = list(
		"default" = list(
			"Tab" = "\".winset \\\"input.focus=true?map.focus=true input.background-color=[COLOR_INPUT_DISABLED]:input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
			"O" = "ooc",
			"T" = "\".winset \\\"command=\\\".start_typing say\\\";command=.init_say;saywindow.is-visible=true;saywindow.input.focus=true\\\"\"",
			"M" = "\".winset \\\"command=\\\".start_typing me\\\";command=.init_me;mewindow.is-visible=true;mewindow.input.focus=true\\\"\"",
			"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"", // This makes it so backspace can remove default inputs
			"Any" = "\"KeyDown \[\[*\]\]\"",
			"Any+UP" = "\"KeyUp \[\[*\]\]\"",
			),
		"old_default" = list(
			"Tab" = "\".winset \\\"mainwindow.macro=old_hotkeys map.focus=true input.background-color=[COLOR_INPUT_DISABLED]\\\"\"",
			"Ctrl+T" = "\".winset \\\"command=\\\".start_typing say\\\";command=.init_say;saywindow.is-visible=true;saywindow.input.focus=true\\\"\"",
			"Ctrl+O" = "ooc",
			),
		"old_hotkeys" = list(
			"Tab" = "\".winset \\\"mainwindow.macro=old_default input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
			"O" = "ooc",
			"T" = "\".winset \\\"command=\\\".start_typing say\\\";command=.init_say;saywindow.is-visible=true;saywindow.input.focus=true\\\"\"",
			"M" = "\".winset \\\"command=\\\".start_typing me\\\";command=.init_me;mewindow.is-visible=true;mewindow.input.focus=true\\\"\"",
			"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"", // This makes it so backspace can remove default inputs
			"Any" = "\"KeyDown \[\[*\]\]\"",
			"Any+UP" = "\"KeyUp \[\[*\]\]\"",
			),
		)

	// Because i'm lazy and don't want to type all these out twice
	var/list/old_default = default_macro_sets["old_default"]

	var/list/static/oldmode_keys = list(
		"North", "East", "South", "West",
		"Northeast", "Southeast", "Northwest", "Southwest",
		"Insert", "Delete", "Ctrl", "Alt",
		"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
		)

	for(var/i in 1 to oldmode_keys.len)
		var/key = oldmode_keys[i]
		old_default[key] = "\"KeyDown [key]\""
		old_default["[key]+UP"] = "\"KeyUp [key]\""

	var/list/static/oldmode_ctrl_override_keys = list(
		"W" = "W", "A" = "A", "S" = "S", "D" = "D", // movement
		"1" = "1", "2" = "2", "3" = "3", "4" = "4", // intent
		"B" = "B", // resist
		"E" = "E", // quick equip
		"F" = "F", // intent left
		"G" = "G", // intent right
		"H" = "H", // stop pulling
		"Q" = "Q", // drop
		"R" = "R", // throw
		"X" = "X", // switch hands
		"Y" = "Y", // activate item
		"Z" = "Z", // activate item
		)

	for(var/i in 1 to oldmode_ctrl_override_keys.len)
		var/key = oldmode_ctrl_override_keys[i]
		var/override = oldmode_ctrl_override_keys[key]
		old_default["Ctrl+[key]"] = "\"KeyDown [override]\""
		old_default["Ctrl+[key]+UP"] = "\"KeyUp [override]\""

	macro_sets = default_macro_sets

// For initially setting up or resetting to default the movement keys
/datum/controller/subsystem/verb_manager/input/proc/setup_default_movement_keys()
	var/static/list/default_movement_keys = list(
		"North" = NORTH, "West" = WEST, "South" = SOUTH, "East" = EAST,
		)

	movement_keys = default_movement_keys.Copy()

// Badmins just wanna have fun ♪
/datum/controller/subsystem/verb_manager/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to clients.len)
		var/client/user = clients[i]
		user.set_macros()

/datum/controller/subsystem/verb_manager/input/can_queue_verb(datum/callback/verb_callback/incoming_callback, control)
	//make sure the incoming verb is actually something we specifically want to handle
	if(control != "mapwindow.map")
		return FALSE
	if(average_click_delay > MAXIMUM_CLICK_LATENCY || !..())
		current_clicks++
		average_click_delay = MC_AVG_FAST_UP_SLOW_DOWN(average_click_delay, 0)
		return FALSE

	return TRUE

///stupid workaround for byond not recognizing the /atom/Click typepath for the queued click callbacks
/atom/proc/_Click(location, control, params)
	if(usr)
		Click(location, control, params)


/datum/controller/subsystem/verb_manager/input/fire()
	..()

	var/moves_this_run = 0
	for(var/mob/user in GLOB.player_list)
		moves_this_run += user.focus?.keyLoop(user.client)//only increments if a player moves due to their own input

	movements_per_second = MC_AVG_SECONDS(movements_per_second, moves_this_run, wait TICKS)

/datum/controller/subsystem/verb_manager/input/run_verb_queue()
	var/deferred_clicks_this_run = 0 //acts like current_clicks but doesnt count clicks that dont get processed by SSinput

	for(var/datum/callback/verb_callback/queued_click as anything in verb_queue)
		if(!istype(queued_click))
			stack_trace("non /datum/callback/verb_callback instance inside SSinput's verb_queue!")
			continue

		average_click_delay = MC_AVG_FAST_UP_SLOW_DOWN(average_click_delay, TICKS2DS((DS2TICKS(world.time) - queued_click.creation_time)))
		queued_click.InvokeAsync()

		current_clicks++
		deferred_clicks_this_run++

	verb_queue.Cut() //is ran all the way through every run, no exceptions

	clicks_per_second = MC_AVG_SECONDS(clicks_per_second, current_clicks, wait SECONDS)
	delayed_clicks_per_second = MC_AVG_SECONDS(delayed_clicks_per_second, deferred_clicks_this_run, wait SECONDS)

	current_clicks = 0

/datum/controller/subsystem/verb_manager/input/stat_entry(msg)
	. = ..()
	. += "M/S:[round(movements_per_second,0.01)] | C/S:[round(clicks_per_second,0.01)] ([round(delayed_clicks_per_second,0.01)] | CD: [round(average_click_delay / (1 SECONDS),0.01)])"
