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
	"GamepadStart" = 1, "GamepadSelect" = 1, "VolumeUp" = 1, "VolumeDown" = 1, "VolumeMute" = 1, "MediaPlayPause" = 1, "MediaStop" = 1, "MediaNext" = 1,
	"MediaPrev" = 1
))

/proc/input_sanity_check(client/C, key)
	if(GLOB.valid_keys[key])
		return FALSE

	if(length(key) > 32)
		log_admin("[key_name(C)] just attempted to send an invalid keypress with length over 32 characters, likely malicious.")
		message_admins("Mob [(C.mob)] with the ckey [(C.ckey)] just attempted to send an invalid keypress with length over 32 characters, likely malicious.")
	else
		log_admin_private("[key_name(C)] just attempted to send an invalid keypress - \"[key]\", possibly malicious.")
		message_admins("Mob [(C.mob)] with the ckey [(C.ckey)] just attempted to send an invalid keypress - \"[key]\", possibly malicious.")

	return TRUE

/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	if(input_sanity_check(src, _key))
		return

	keys_held[_key] = world.time
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_sub & movement) && !keys_held["Ctrl"])
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
	kbs = sortList(kbs, /proc/cmp_keybinding_dsc)
	for (var/datum/keybinding/kb in kbs)
		if (kb.down(src))
			break

	if(holder)
		holder.key_down(full_key, src)
	if(mob.focus)
		mob.focus.key_down(full_key, src)

/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	if(input_sanity_check(src, _key))
		return

	keys_held -= _key
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	// We don't do full key for release, because for mod keys you
	// can hold different keys and releasing any should be handled by the key binding specifically
	var/list/kbs = list()
	for (var/kb_name in prefs.key_bindings[_key])
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		kbs += kb
	kbs = sortList(kbs, /proc/cmp_keybinding_dsc)
	for (var/datum/keybinding/kb in kbs)
		if (kb.up(src))
			break

	if(holder)
		holder.key_up(_key, src)
	if(mob.focus)
		mob.focus.key_up(_key, src)

// Called every game tick
/client/keyLoop()
	if(holder)
		holder.keyLoop(src)
	if(mob?.focus)
		mob.focus.keyLoop(src)
