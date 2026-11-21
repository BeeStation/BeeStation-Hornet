/// These bindings are intercepted before ordinary input dispatch while the
/// camera owns the body. They deliberately share keys with ordinary movement.
/datum/keybinding/brandish
	abstract_type = /datum/keybinding/brandish
	category = CATEGORY_BRANDISH
	keybind_signal = "brandish_movement"
	any_modifier = TRUE

/datum/keybinding/brandish/can_use(client/user)
	return FALSE

/datum/keybinding/brandish/forward
	name = "brandish_forward"
	full_name = "Forward"
	keys = list("W")

/datum/keybinding/brandish/backward
	name = "brandish_backward"
	full_name = "Backward"
	keys = list("S")
	description = "Backpedal at half forward speed."

/datum/keybinding/brandish/turn_left
	name = "brandish_turn_left"
	full_name = "Turn left"
	keys = list("A")

/datum/keybinding/brandish/turn_right
	name = "brandish_turn_right"
	full_name = "Turn right"
	keys = list("D")

/datum/keybinding/brandish/strafe_left
	name = "brandish_strafe_left"
	full_name = "Strafe left"
	keys = list("ShiftA")
	description = "Move sideways at three quarters of forward speed."

/datum/keybinding/brandish/strafe_right
	name = "brandish_strafe_right"
	full_name = "Strafe right"
	keys = list("ShiftD")
	description = "Move sideways at three quarters of forward speed."

/// Lazy migration of the four existing, rebindable movement actions. An empty
/// saved list means deliberately unbound and must survive this migration.
/proc/migrate_brandish_keybindings(list/bindings)
	var/list/movement_actions = list(
		"brandish_forward" = "move_north",
		"brandish_backward" = "move_south",
		"brandish_turn_left" = "move_west",
		"brandish_turn_right" = "move_east",
	)
	var/changed = FALSE
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/binding = GLOB.keybindings_by_name[name]
		if(!istype(binding, /datum/keybinding/brandish) || (name in bindings))
			continue
		var/old_action = movement_actions[name]
		var/list/old_keys = old_action ? bindings[old_action] : null
		bindings[name] = islist(old_keys) ? old_keys.Copy() : binding.keys.Copy()
		changed = TRUE
	return changed

/// Sharing ordinary keys is expected. Only another Brandish action conflicts.
/proc/brandish_keybind_conflicts(list/bindings, name, list/hotkeys)
	if(!istype(GLOB.keybindings_by_name[name], /datum/keybinding/brandish))
		return FALSE
	for(var/other in bindings)
		if(other == name || !istype(GLOB.keybindings_by_name[other], /datum/keybinding/brandish))
			continue
		for(var/key in hotkeys)
			if(key != "Unbound" && (key in bindings[other]))
				return TRUE
	return FALSE

/// Exact modifier bindings win; unmodified Brandish actions also accept held
/// modifiers, just as normal movement does (e.g. Ctrl for facing lock).
/proc/brandish_action_for_key(list/bindings_by_key, key, full_key)
	for(var/name in bindings_by_key[full_key])
		if(istype(GLOB.keybindings_by_name[name], /datum/keybinding/brandish))
			return name
	if(full_key != key)
		for(var/name in bindings_by_key[key])
			var/datum/keybinding/binding = GLOB.keybindings_by_name[name]
			if(istype(binding, /datum/keybinding/brandish) && binding.any_modifier)
				return name

/// The preference format concatenates modifiers in Alt/Ctrl/Shift order.
/proc/keybinding_base_key(key)
	var/static/list/modifier_keys = list("Alt", "Ctrl", "Shift")
	for(var/modifier in modifier_keys)
		if(length(key) > length(modifier) && findtext(key, modifier) == 1)
			key = copytext(key, length(modifier) + 1)
	return key
