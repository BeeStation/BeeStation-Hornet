/datum/keybinding
	var/list/keys
	var/name
	var/full_name
	var/description = ""
	var/category = CATEGORY_MISC
	var/weight = WEIGHT_LOWEST
	var/keybind_signal
	/// Does this keybind apply regardless of any modifier keys (SHIFT-, ALT-, CTRL-)?
	/// Important for movement keys, which need to still activate despite other "hold to toggle" bindings on the modifier keys.
	var/any_modifier = FALSE
	/// The typepath of the preference that we must have set to a specific value in order to show
	var/required_pref_type = null
	/// The value of the preference outlined in required_pref_type that must be set in order to show this keybinding to the user.
	var/required_pref_value = null

//I don't know why this is done in New() and not down() when it says down(), but that's how it's currently on tg
/datum/keybinding/New()
	if(!keybind_signal)
		CRASH("Keybind [src] called unredefined down() without a keybind_signal.")

/datum/keybinding/proc/down(client/user)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(user.mob, keybind_signal) & COMSIG_KB_ACTIVATED

/datum/keybinding/proc/up(client/user)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(user.mob, DEACTIVATE_KEYBIND(keybind_signal))
	return FALSE

/datum/keybinding/proc/can_use(client/user)
	if (!required_pref_type)
		return TRUE
	return user.prefs.read_preference(required_pref_type) == required_pref_value
