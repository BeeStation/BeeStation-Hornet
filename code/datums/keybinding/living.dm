/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)


/datum/keybinding/living/resist
	key = "B"
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffs, on fire, being trapped in an alien nest? Resist!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user)
	. = ..()
	if(. || !isliving(user.mob))
		return
	var/mob/living/L = user.mob
	L.resist()
	return TRUE


/datum/keybinding/living/rest
	key = "V"
	name = "rest"
	full_name = "Rest"
	description = "Lay down, or get up."
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN

/datum/keybinding/living/rest/down(client/user)
	. = ..()
	if(. || !isliving(user.mob))
		return
	var/mob/living/L = user.mob
	L.lay_down()
	return TRUE

/datum/keybinding/living/look_up
	key = "L"
	name = "look up"
	full_name = "Look Up"
	description = "Look up at the next z-level. Only works if below any nearby open space within a 3x3 square."
	keybind_signal = COMSIG_KB_LIVING_LOOKUP_DOWN

/datum/keybinding/living/look_up/down(client/user)
	. = ..()
	if(. || !isliving(user.mob))
		return
	var/mob/living/L = user.mob
	L.look_up(lock = TRUE)
	return TRUE

/datum/keybinding/living/look_up/up(client/user)
	. = ..()
	if(. || !isliving(user.mob))
		return
	var/mob/living/L = user.mob
	L.look_reset()
	return TRUE

/datum/keybinding/living/look_down
	key = ";"
	name = "look down"
	full_name = "Look Down"
	description = "Look down at the previous z-level. Only works if above any nearby open space within a 3x3 square."
	keybind_signal = COMSIG_KB_LIVING_LOOKDOWN_DOWN

/datum/keybinding/living/look_down/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_down(lock = TRUE)
	return TRUE

/datum/keybinding/living/look_down/up(client/user)
	. = ..()
	if(. || !isliving(user.mob))
		return
	var/mob/living/L = user.mob
	L.look_reset()
	return TRUE

//Keybind for sense
/datum/keybinding/living/primary_species_action
	key = "Shift-Space"
	name = "species_primary"
	full_name = "Primary Species Action"
	description = "Activates a species primary action."
	keybind_signal = COMSIG_SPECIES_ACTION_PRIMARY

/datum/keybinding/living/primary_species_action/down(client/user)
	. = ..()
	if(. || !iscarbon(user.mob)) 
		return
	var/mob/living/carbon/L = user.mob
	L.dna.species.primary_species_action()
	return TRUE
