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
	key_bindings[keybind_name] = hotkeys
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	mark_undatumized_dirty_player()
