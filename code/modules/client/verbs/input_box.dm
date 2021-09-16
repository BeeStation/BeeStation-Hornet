/client/proc/create_input_window(id, title, accept_verb, cancel_verb)
	if(winexists(src, id))
		return

	winclone(src, "input_box", id)
	winset(src, id, "title=[title]")

	if(accept_verb)
		winset(src, "[id].input", "command=\"[accept_verb] \\\"\"")
		winset(src, "[id].accept", "command=\".winset \\\"command=\\\"[accept_verb] \[\[[id].input.text as escaped\]\]\\\";[id].is-visible=false\\\"\"")

	if(cancel_verb)
		winset(src, "[id].cancel", "command=\".winset \\\"command=\\\"[cancel_verb]\\\";[id].is-visible=false\\\"\"")

	winshow(src, id, TRUE)
	winset(src, "[id].input", "focus=true")

/client/verb/init_say()
	set instant = TRUE
	set name = ".init_say"

	create_input_window("saywindow", "Say \"test\"", ".say", ".cancel_typing")

/client/verb/init_me() // Currently unused
	set instant = TRUE
	set name = ".init_me"

	create_input_window("saywindow", "me (text)", ".me", ".cancel_typing")