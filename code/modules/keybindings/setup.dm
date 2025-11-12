/client
	/// A list of any keys held currently
	var/list/keys_held = list()
	/// A buffer for combinations such of modifiers + keys (ex: CtrlD, AltE, ShiftT). Format: ["key"] -> ["combo"] (ex: ["D"] -> ["CtrlD"])
	var/list/key_combos_held = list()
	// These next two vars are to apply movement for keypresses and releases made while move delayed.
	// Because discarding that input makes the game less responsive.
	var/next_move_dir_add // On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_sub // On next move, subtract this dir from the move that would otherwise be done

// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/key_down(key, client/user, full_key) // Called when a key is pressed down initially
	SHOULD_CALL_PARENT(TRUE)
	return
/datum/proc/key_up(key, client/user) // Called when a key is released
	return
/datum/proc/keyLoop(client/user) // Called once every frame
	set waitfor = FALSE
	return

// removes all the existing macros
/client/proc/erase_all_macros()
	var/list/macro_sets = params2list(winget(src, null, "macros"))
	var/erase_output = ""
	for(var/i in 1 to macro_sets.len)
		var/setname = macro_sets[i]
		if(copytext(setname, 1, 9) == "persist_") // Don't remove macro sets not handled by input. Used in input_box.dm by create_input_window
			continue
		var/list/macro_set = params2list(winget(src, "[setname].*", "command")) // The third arg doesnt matter here as we're just removing them all
		for(var/k in 1 to macro_set.len)
			var/list/split_name = splittext(macro_set[k], ".")
			var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
			erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)

/client/proc/set_macros()
	set waitfor = FALSE

	var/list/macro_sets = SSinput.macro_sets
	if(!length(macro_sets))
		return

	erase_all_macros()

	for(var/i in 1 to macro_sets.len)
		var/setname = macro_sets[i]
		if(setname != "default")
			winclone(src, "default", setname)
		var/list/macro_set = macro_sets[setname]
		for(var/k in 1 to macro_set.len)
			var/key = macro_set[k]
			var/command = macro_set[key]
			winset(src, "[setname]-[REF(key)]", "parent=[setname];name=[key];command=[command]")
		winset(src, "[setname]-close-tgui-say", "parent=[setname];name=Escape;command=[tgui_say_create_close_command()]")
	if(hotkeys)
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=default")
	else
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=old_default")

	update_special_keybinds()
	winset(src, "tgui_say.browser", "focus=true")


/**
  * Updates the keybinds for special keys
  *
  * Handles adding macros for the keys that need it
  * At the time of writing this, communication(OOC, Say, IC) require macros
  * Arguments:
  * * direct_prefs - the preference we're going to get keybinds from
  */
/client/proc/update_special_keybinds(datum/preferences/direct_prefs)
	var/datum/preferences/D = prefs || direct_prefs
	if(!D?.key_bindings)
		return

	var/list/macro_sets = SSinput.macro_sets
	if(!length(macro_sets))
		return

	var/use_tgui_say = !prefs || prefs.read_player_preference(/datum/preference/toggle/tgui_say)
	var/use_tgui_asay = !prefs || prefs.read_player_preference(/datum/preference/toggle/tgui_asay)
	var/say = use_tgui_say ? tgui_say_create_open_command(SAY_CHANNEL) : "\".winset \\\"command=\\\".start_typing say\\\";command=.init_say;saywindow.is-visible=true;saywindow.input.focus=true\\\"\""
	var/me = use_tgui_say ? tgui_say_create_open_command(ME_CHANNEL) : "\".winset \\\"command=\\\".start_typing me\\\";command=.init_me;mewindow.is-visible=true;mewindow.input.focus=true\\\"\""
	var/ooc = use_tgui_say ? tgui_say_create_open_command(OOC_CHANNEL) : "ooc"
	var/asay = use_tgui_asay ? tgui_say_create_open_command(ASAY_CHANNEL, "tgui_asay") : null
	var/dsay = use_tgui_asay ? tgui_say_create_open_command(DSAY_CHANNEL, "tgui_asay") : null
	var/msay = use_tgui_asay ? tgui_say_create_open_command(MSAY_CHANNEL, "tgui_asay") : null
	var/radio = tgui_say_create_open_command(RADIO_CHANNEL)
	var/looc = tgui_say_create_open_command(LOOC_CHANNEL)

	var/is_mentor = is_mentor()

	for(var/kb_name in D.key_bindings)
		for(var/key in D.key_bindings[kb_name])
			for(var/i in 1 to macro_sets.len)
				var/setname = macro_sets[i]
				switch(kb_name)
					if("say")
						winset(src, "[setname]-say", "parent=[setname];name=[key];command=[say]")
					if("ooc")
						winset(src, "[setname]-ooc", "parent=[setname];name=[key];command=[ooc]")
					if("me")
						winset(src, "[setname]-me", "parent=[setname];name=[key];command=[me]")
				if(use_tgui_say)
					switch(kb_name)
						if("radio")
							winset(src, "[setname]-radio", "parent=[setname];name=[key];command=[radio]")
						if("looc")
							winset(src, "[setname]-looc", "parent=[setname];name=[key];command=[looc]")
				else
					switch(kb_name)
						if("radio")
							winset(src, "[setname]-radio", "parent=null")
						if("looc")
							winset(src, "[setname]-looc", "parent=null")
				if(holder)
					switch(kb_name)
						if("admin_say")
							winset(src, "[setname]-asay", "parent=[setname];name=[key];command=[asay]")
						if("dead_say")
							winset(src, "[setname]-dsay", "parent=[setname];name=[key];command=[dsay]")
				else
					switch(kb_name)
						if("admin_say")
							winset(src, "[setname]-asay", "parent=null")
						if("dead_say")
							winset(src, "[setname]-dsay", "parent=null")
				if(kb_name == "mentor_say")
					if(is_mentor)
						winset(src, "[setname]-msay", "parent=[setname];name=[key];command=[msay]")
					else
						winset(src, "[setname]-msay", "parent=null")
