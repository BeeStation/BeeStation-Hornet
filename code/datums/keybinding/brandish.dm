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
