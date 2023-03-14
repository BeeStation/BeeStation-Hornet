// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events

GLOBAL_LIST_INIT(valid_keys, list(
	"F1" = 1, "F2" = 1, "F3" = 1, "F4" = 1, "F5" = 1, "F6" = 1, "F7" = 1, "F8" = 1, "F9" = 1, "F10" = 1, "F11" = 1, "F12" = 1,
	"F13" = 1, "F14" = 1, "F15" = 1, "F16" = 1, "F17" = 1, "F18" = 1, "F19" = 1, "F20" = 1, "F21" = 1, "F22" = 1, "F23" = 1, "F24" = 1,
	"A" = 1, "B" = 1, "C" = 1, "D" = 1, "E" = 1, "F" = 1, "G" = 1, "H" = 1, "I" = 1, "J" = 1, "K" = 1, "L" = 1, "M" = 1,
	"N" = 1, "O" = 1, "P" = 1, "Q" = 1, "R" = 1, "S" = 1, "T" = 1, "U" = 1, "V" = 1, "W" = 1, "X" = 1, "Y" = 1, "Z" = 1,
	"0" = 1, "1" = 1, "2" = 1, "3" = 1, "4" = 1, "5" = 1, "6" = 1, "7" = 1, "8" = 1, "9" = 1,
	"-" = 1, "=" = 1, "+" = 1, "\[" = 1, "\]" = 1, "\\" = 1, "." = 1, "," = 1, "<" = 1, ">" = 1, "/" = 1, "`" = 1, "Capslock" = 1,
	"Numpad0" = 1, "Numpad1" = 1, "Numpad2" = 1, "Numpad3" = 1, "Numpad4" = 1, "Numpad5" = 1, "Numpad6" = 1, "Numpad7" = 1, "Numpad8" = 1, "Numpad9" = 1,
	"North" = 1, "South" = 1, "East" = 1, "West" = 1, "Northwest" = 1, "Southwest" = 1, "Northeast" = 1, "Southeast" = 1,
	"Center" = 1, "Return" = 1, "Escape" = 1, "Tab" = 1, "Space" = 1, "Back" = 1, "Insert" = 1, "Delete" = 1, "Pause" = 1, "Snapshot" = 1,
	"LWin" = 1, "RWin" = 1, "Apps" = 1, "Multiply" = 1, "Add" = 1, "Subtract" = 1, "Divide" = 1, "Separator" = 1, "Decimal" = 1,
	"Shift" = 1, "Ctrl" = 1, "Numlock" = 1, "Scroll" = 1, "Alt" = 1, "'" = 1, ";" = 1, "#" = 1, "GamepadUp" = 1, "GamepadDown" = 1, "GamepadLeft" = 1,
	"GamepadRight" = 1, "GamepadDownLeft" = 1, "GamepadDownRight" = 1, "GamepadUpLeft" = 1, "GamepadUpRight" = 1, "GamepadFace1" = 1, "GamepadFace2" = 1,
	"GamepadFace3" = 1, "GamepadFace4" = 1, "GamepadR1" = 1, "GamepadR2" = 1, "GamepadR3" = 1, "GamepadL1" = 1, "GamepadL2" = 1, "GamepadL3" = 1,
	"GamepadStart" = 1, "GamepadSelect" = 1, "Gamepad2Up" = 1, "Gamepad2Down" = 1, "Gamepad2Left" = 1, "Gamepad2Right" = 1, "Gamepad2DownLeft" = 1,
	"Gamepad2DownRight" = 1, "Gamepad2UpLeft" = 1, "Gamepad2UpRight" = 1, "Gamepad2Face1" = 1, "Gamepad2Face2" = 1, "Gamepad2Face3" = 1, "Gamepad2Face4" = 1,
	"Gamepad2R1" = 1, "Gamepad2R2" = 1, "Gamepad2R3" = 1, "Gamepad2L1" = 1, "Gamepad2L2" = 1, "Gamepad2L3" = 1,	"Gamepad2Start" = 1, "Gamepad2Select" = 1,
	"Gamepad3Up" = 1, "Gamepad3Down" = 1, "Gamepad3Left" = 1, "Gamepad3Right" = 1, "Gamepad3DownLeft" = 1, "Gamepad3DownRight" = 1, "Gamepad3UpLeft" = 1,
	"Gamepad3UpRight" = 1, "Gamepad3Face1" = 1, "Gamepad3Face2" = 1, "Gamepad3Face3" = 1, "Gamepad3Face4" = 1, "Gamepad3R1" = 1, "Gamepad3R2" = 1, "Gamepad3R3" = 1,
	"Gamepad3L1" = 1, "Gamepad3L2" = 1, "Gamepad3L3" = 1, "Gamepad3Start" = 1, "Gamepad3Select" = 1, "Gamepad4Up" = 1, "Gamepad4Down" = 1, "Gamepad4Left" = 1,
	"Gamepad4Right" = 1, "Gamepad4DownLeft" = 1,"Gamepad4DownRight" = 1, "Gamepad4UpLeft" = 1, "Gamepad4UpRight" = 1, "Gamepad4Face1" = 1, "Gamepad4Face2" = 1,
	"Gamepad4Face3" = 1, "Gamepad4Face4" = 1, "Gamepad4R1" = 1, "Gamepad4R2" = 1, "Gamepad4R3" = 1, "Gamepad4L1" = 1, "Gamepad4L2" = 1, "Gamepad4L3" = 1,
	"Gamepad4Start" = 1, "Gamepad4Select" = 1, "VolumeUp" = 1, "VolumeDown" = 1, "VolumeMute" = 1, "MediaPlayPause" = 1, "MediaStop" = 1, "MediaNext" = 1,	"MediaPrev" = 1
))

/proc/input_sanity_check(client/C, key)
	if(GLOB.valid_keys[key])
		return FALSE

	if(length(key) > 32)
		log_admin("[key_name(C)] just attempted to send an invalid keypress with length over 32 characters, likely malicious.")
		message_admins("Mob [(C.mob)] with the ckey [(C.ckey)] just attempted to send an invalid keypress with length over 32 characters, likely malicious.")
	else
		log_admin_private("[key_name(C)] just attempted to send an invalid keypress - \"[key]\".")

	return TRUE

/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	if(input_sanity_check(src, _key))
		return

	keys_held[_key] = world.time
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_sub & movement) && !movement_locked)
		next_move_dir_add |= movement

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.
	var/AltMod = keys_held["Alt"] ? "Alt-" : ""
	var/CtrlMod = keys_held["Ctrl"] ? "Ctrl-" : ""
	var/ShiftMod = keys_held["Shift"] ? "Shift-" : ""
	var/full_key = "[_key]"
	if (!(_key in list("Alt", "Ctrl", "Shift")))
		full_key = "[AltMod][CtrlMod][ShiftMod][_key]"

	var/list/kbs = list()
	for (var/kb_name in prefs.key_bindings[full_key])
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		kbs += kb
	// WASD-type movement keys (not the native arrow keys) are handled through the keybind system here.
	// They have "any_modifier" set, because they need to be activated even if a modifier key is pressed,
	// since these modifier keys toggle effects like "change facing" that require the movement keys to function.
	// Note that this doesn't prevent the user from binding CTRL-W to North: In that case *only* CTRL-W will function.
	if (full_key != _key)
		for (var/kb_name in prefs.key_bindings[_key])
			var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
			if (kb.any_modifier)
				kbs += kb
	kbs = sortList(kbs, GLOBAL_PROC_REF(cmp_keybinding_dsc))
	for(var/datum/keybinding/kb in kbs)
		if(kb.can_use(src) && kb.down(src))
			break

	if(holder)
		holder.key_down(_key, src)  //full_key is not necessary here, _key is enough
	if(mob.focus)
		mob.focus.key_down(_key, src) //same as above

/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	if(input_sanity_check(src, _key))
		return

	keys_held -= _key
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_add & movement) && !movement_locked)
		next_move_dir_sub |= movement

	// We don't do full key for release, because for mod keys you
	// can hold different keys and releasing any should be handled by the key binding specifically
	var/list/kbs = list()
	for (var/kb_name in prefs.key_bindings[_key])
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		kbs += kb
	kbs = sortList(kbs, GLOBAL_PROC_REF(cmp_keybinding_dsc))
	for(var/datum/keybinding/kb in kbs)
		if(kb.can_use(src) && kb.up(src))
			break

	if(holder)
		holder.key_up(_key, src)
	if(mob.focus)
		mob.focus.key_up(_key, src)
