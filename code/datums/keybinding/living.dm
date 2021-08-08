/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB


/datum/keybinding/living/resist
	key = "B"
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffs, on fire, being trapped in an alien nest? Resist!"

/datum/keybinding/living/resist/down(client/user)
	if (!isliving(user.mob)) return
	var/mob/living/L = user.mob
	L.resist()
	return TRUE

/datum/keybinding/living/rest
	key = "V"
	name = "rest"
	full_name = "Rest"
	description = "Lay down, or get up."

/datum/keybinding/living/rest/down(client/user)
	if(!isliving(user.mob))
		return
	var/mob/living/L = user.mob
	L.lay_down()
	return TRUE