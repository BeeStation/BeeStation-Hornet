/// Inverts the key_bindings list such that it can be used for key_bindings_by_key
/datum/preferences/proc/get_key_bindings_by_key(list/key_bindings)
	var/list/output = list()

	for (var/action in key_bindings)
		for (var/key in key_bindings[action])
			LAZYADD(output[key], action)

	return output

/datum/preferences/proc/set_key_bindings(list/_key_bindings)
	if(!istype(_key_bindings))
		return
	key_bindings = _key_bindings
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	mark_undatumized_dirty_player()
	parent?.update_special_keybinds(src)

/datum/preferences/proc/set_default_key_bindings(save = FALSE)
	key_bindings = deep_copy_list(GLOB.keybindings_by_name_to_key)
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	if(save)
		mark_undatumized_dirty_player()
	parent?.update_special_keybinds(src)

/datum/preferences/proc/set_keybind(keybind_name, hotkeys)
	if (!(keybind_name in GLOB.keybindings_by_name))
		return FALSE
	if(!islist(hotkeys))
		return
	if(brandish_keybind_conflicts(key_bindings, keybind_name, hotkeys))
		return FALSE
	log_preferences("[parent?.ckey]: Set keybind [keybind_name] to [english_list(hotkeys)].")
	key_bindings[keybind_name] = hotkeys
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	mark_undatumized_dirty_player()
	return TRUE

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
	for(var/modifier in list("Alt", "Ctrl", "Shift"))
		if(length(key) > length(modifier) && findtext(key, modifier) == 1)
			key = copytext(key, length(modifier) + 1)
	return key
