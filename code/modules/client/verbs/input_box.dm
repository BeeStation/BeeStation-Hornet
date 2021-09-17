/client/proc/create_input_window(id, title, accept_verb, cancel_verb)
	if(winexists(src, id))
		return

	// Create a macro set for handling enter presses
	winclone(src, "input_box_macro", "persist_[id]_macro")
	winset(src, "[id]_macro_returnup", "parent=persist_[id]_macro;name=Return+UP;command=\".winset \\\"[id].is-visible=false\\\"\"")
	// Return+UP allows us to close the window after typing in a command, pressing enter and releasing enter.
	// Can't use just Return for this, because when there's text in the box Return is handled by BYOND and doesn't run the macro.

	// Create the actual window and set its title and macro set
	winclone(src, "input_box", id)
	winset(src, id, "title=\"[title]\";macro=persist_[id]_macro")

	if(accept_verb)
		winset(src, "[id].input", "command=\"[accept_verb] \\\"\"")
		winset(src, "[id].accept", "command=\".winset \\\"command=\\\"[accept_verb] \\\\\\\"\[\[[id].input.text as escaped\]\]\\\";[id].is-visible=false\\\"\"")

	if(cancel_verb)
		winset(src, "[id].cancel", "command=\".winset \\\"command=\\\"[cancel_verb]\\\";[id].is-visible=false\\\"\"")
		winset(src, "[id]_macro_return", "parent=persist_[id]_macro;name=Return;command=\".winset \\\"command=\\\"[cancel_verb]\\\";[id].is-visible=false\\\"\"")
		winset(src, "[id]_macro_escape", "parent=persist_[id]_macro;name=Escape;command=\".winset \\\"command=\\\"[cancel_verb]\\\";[id].is-visible=false\\\"\"")
		winset(src, id, "on-close=\"[cancel_verb]\"")
	else
		winset(src, "[id]_macro_return", "parent=persist_[id]_macro;name=Return;command=\".winset \\\"[id].is-visible=false\\\"\"")
		winset(src, "[id]_macro_escape", "parent=persist_[id]_macro;name=Escape;command=\".winset \\\"[id].is-visible=false\\\"\"")

	//Center the window on the main window
	//The window size is hardcoded to be 410x133, taken from skin.dmf
	var/data = params2list(winget(src, "mainwindow", "pos;outer-size;size;inner-size;is-maximized"))
	var/mainwindow_pos = splittext(data["pos"], ",")
	var/mainwindow_size = splittext(data["size"], "x")
	var/mainwindow_innersize = splittext(data["inner-size"], "x")
	var/mainwindow_outersize = splittext(data["outer-size"], "x")

	var/maximized = (data["is-maximized"] == "true")

	if(!maximized)
		//If the window is anchored (for example win+right), is-maximized is false but pos is no longer reliable
		//In that case, compare inner-size and size to guess if it's actually anchored
		maximized = text2num(mainwindow_size[1]) != text2num(mainwindow_innersize[1])\
			|| abs(text2num(mainwindow_size[2]) - text2num(mainwindow_innersize[2])) > 30

	var/target_x
	var/target_y

	// If the window is maximized or anchored, pos is the last position when the window was free-floating
	if(maximized)
		target_x = text2num(mainwindow_outersize[1])/2-410/2
		target_y = text2num(mainwindow_outersize[2])/2-133/2
	else
		target_x = text2num(mainwindow_pos[1])+text2num(mainwindow_outersize[1])/2-410/2
		target_y = text2num(mainwindow_pos[2])+text2num(mainwindow_outersize[2])/2-133/2

	winset(src, id, "pos=[target_x],[target_y]")
	//End centering

	//Show the window and focus on the textbox
	winshow(src, id, TRUE)
	winset(src, "[id].input", "focus=true")

/client/verb/init_say()
	set name = ".init_say"
	set hidden = TRUE

	create_input_window("saywindow", "Say \\\"text\\\"", ".say", ".cancel_typing say")

/client/verb/init_me()
	set name = ".init_me"
	set hidden = TRUE

	create_input_window("mewindow", "me (text)", ".me", ".cancel_typing me")
