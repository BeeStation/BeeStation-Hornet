/datum/keybinding/xeno
	category = CATEGORY_XENO
	weight = WEIGHT_MOB


/datum/keybinding/xeno/drop_weeds
	key = "V"
	name = "drop_weeds"
	full_name = "Drop Weed"
	description = "Drop weeds to help grow your hive."
	category = CATEGORY_XENO

/datum/keybinding/xeno/drop_weeds/down(client/user)
	if(!isxeno(user.mob))
		return
	var/mob/living/carbon/Xenomorph/X = user.mob
	var/datum/action/xeno_action/plant_weeds/ability = locate() in X.actions
	if (!ability)
		to_chat(user, "<span class='notice'>You don't have this ability.</span>") // TODO Is this spammy?
		return TRUE

	if(ability.can_use_action(FALSE, null, TRUE))
		ability.action_activate()
	else
		ability.fail_activate()
	return TRUE