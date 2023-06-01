/datum/keybinding/shell
	category = CATEGORY_ROBOT
	weight = WEIGHT_ROBOT

/datum/keybinding/shell/can_use(client/user)
	if(iscyborg(user.mob))
		var/mob/living/silicon/robot/shell/our_shell = user.mob
		if(our_shell.shell)
			return TRUE
		else
			return FALSE
	else
		return FALSE

/datum/keybinding/shell/undeploy
	category = CATEGORY_AI
	key = "="
	name = "undeploy"
	full_name = "Disconnect from shell"
	description = "Returns you to your AI core"
	keybind_signal = COMSIG_KB_SILION_UNDEPLOY_DOWN

/datum/keybinding/shell/undeploy/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/shell/our_shell = user.mob
	our_shell.undeploy()
	return TRUE
