/datum/keybinding/robot
	category = CATEGORY_ROBOT
	weight = WEIGHT_ROBOT

/datum/keybinding/robot/can_use(client/user)
	return iscyborg(user.mob)


/datum/keybinding/robot/toggle_module_1
	keys = list("1")
	name = "toggle_module_1"
	full_name = "Toggle Module 1"
	description = "Toggle your first module as a robot."
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULEONE_DOWN

/datum/keybinding/robot/toggle_module_1/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/M = user.mob
	M.toggle_module(1)
	return TRUE


/datum/keybinding/robot/toggle_module_2
	keys = list("2")
	name = "toggle_module_2"
	full_name = "Toggle Module 2"
	description = "Toggle your second module as a robot."
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULETWO_DOWN

/datum/keybinding/robot/toggle_module_2/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/M = user.mob
	M.toggle_module(2)
	return TRUE


/datum/keybinding/robot/toggle_module_3
	keys = list("3")
	name = "toggle_module_3"
	full_name = "Toggle Module 3"
	description = "Toggle your third module as a robot."
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULETHREE_DOWN

/datum/keybinding/robot/toggle_module_3/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/M = user.mob
	M.toggle_module(3)
	return TRUE

/datum/keybinding/robot/unequip_module
	keys = list("Q")
	name = "unequip_module"
	full_name = "Unequip Module"
	description = "Unequip a robot module."
	keybind_signal = COMSIG_KB_SILICON_UNEQUIPMODULE_DOWN

/datum/keybinding/robot/unequip_module/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/M = user.mob
	M.uneq_active()
	return TRUE
