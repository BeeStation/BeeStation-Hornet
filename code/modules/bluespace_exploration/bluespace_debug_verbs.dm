GLOBAL_LIST_INIT(bluespace_debug_verbs, list())

/client/verb/enable_exploration_verbs()
	set category = "Debug"
	set name = "Bluespace Exploration Verbs - Enable"
	if(!check_rights(R_DEBUG))
		return
	verbs -= /client/proc/enable_exploration_verbs
	verbs.Add(/client/proc/disable_exploration_verbs, GLOB.bluespace_debug_verbs)

/client/verb/disable_exploration_verbs()
	set category = "Debug"
	set name = "Bluespace Exploration Verbs - Disable"
	if(!check_rights(R_DEBUG))
		return
	verbs += /client/proc/enable_exploration_verbs
	verbs.Remove(/client/proc/disable_exploration_verbs, GLOB.bluespace_debug_verbs)
