/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)


/datum/keybinding/living/resist
	keys = list("B")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffs, on fire, being trapped in an alien nest? Resist!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.resist()
	return TRUE


/datum/keybinding/living/rest
	keys = list("V")
	name = "rest"
	full_name = "Rest"
	description = "Lay down, or get up."
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN

/datum/keybinding/living/rest/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	living_mob.toggle_resting()
	return TRUE

/datum/keybinding/living/toggle_combat_mode
	keys = list("F")
	name = "toggle_combat_mode"
	full_name = "Toggle Combat Mode"
	description = "Toggles combat mode. Like Help/Harm but cooler."
	keybind_signal = COMSIG_KB_LIVING_TOGGLE_COMBAT_DOWN


/datum/keybinding/living/toggle_combat_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(!user_mob.combat_mode, FALSE)

/datum/keybinding/living/enable_combat_mode
	keys = list("4")
	name = "enable_combat_mode"
	full_name = "Enable Combat Mode"
	description = "Enable combat mode."
	keybind_signal = COMSIG_KB_LIVING_ENABLE_COMBAT_DOWN

/datum/keybinding/living/enable_combat_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(TRUE, silent = FALSE)

/datum/keybinding/living/disable_combat_mode
	keys = list("1")
	name = "disable_combat_mode"
	full_name = "Disable Combat Mode"
	description = "Disable combat mode."
	keybind_signal = COMSIG_KB_LIVING_DISABLE_COMBAT_DOWN

/datum/keybinding/living/disable_combat_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(FALSE, silent = FALSE)

/datum/keybinding/living/look_up
	keys = list()
	name = "look up"
	full_name = "Look Up"
	description = "Look up at the next z-level. Only works if below any nearby open space within a 3x3 square."
	keybind_signal = COMSIG_KB_LIVING_LOOKUP_DOWN

/datum/keybinding/living/look_up/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_up(lock = TRUE)
	return TRUE

/datum/keybinding/living/look_up/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_reset()
	return TRUE

/datum/keybinding/living/look_down
	keys = list()
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
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_reset()
	return TRUE

//Keybind for sense
/datum/keybinding/living/primary_species_action
	keys = list("Shift-Space")
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

