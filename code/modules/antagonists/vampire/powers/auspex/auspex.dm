/datum/discipline/auspex
	name = "Auspex"
	discipline_explanation = "Auspex is a Discipline that grants vampires supernatural senses, letting them peer far further and see things best left unseen.\n\
		The malkavians especially have a bond with it, being seers at heart."
	icon_state = "auspex"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/auspex)
	level_2 = list(/datum/action/vampire/auspex/two)
	level_3 = list(/datum/action/vampire/auspex/three)
	level_4 = list(/datum/action/vampire/auspex/four)

/datum/discipline/auspex/malkavian
	level_5 = list(/datum/action/vampire/auspex/four, /datum/action/vampire/astral_projection)

/**
 *	# Auspex
 *
 *	Level 1 - Raise sightrange by 2, project sight 2 tiles ahead.
 *	Level 2 - Raise sightrange by 3, project sight 4 tiles ahead. Meson Vision
 *	Level 3 - Raise sightrange by 5, project sight 6 tiles ahead.
 *	Level 4 - Raise sightrange by 7, project sight 8 tiles ahead. Xray Vision
 *	Level 5 - For Malkavians: Gain ability to astral project like a wizard.
 */
/datum/action/vampire/auspex
	name = "Auspex"
	desc = "Sense the vitae of any creature directly, and use your keen senses to widen your perception."
	button_icon_state = "power_auspex"
	power_explanation = "- Level 1: When Activated, you will see further. \n\
					- Level 2: When Activated, you will see further, and be able to sense walls and the layout of rooms. \n\
					- Level 3: When Activated, You still have meson vision, same as level 3, but even more range. \n\
					- Level 4: When Activated, you will see further, and be able to sense anything in sight, seeing through walls and barriers as if they were glass."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 50
	constant_vitaecost = 1
	cooldown_time = 10 SECONDS
	var/add_meson = FALSE
	var/add_xray = FALSE
	var/zoom_out_amt = 2
	var/zoom_amt = 6


	var/looking = FALSE
	var/mob/listeningTo

/datum/action/vampire/auspex/two
	name = "Auspex"
	vitaecost = 40
	constant_vitaecost = 2
	zoom_out_amt = 4
	zoom_amt = 7
	add_meson = TRUE

/datum/action/vampire/auspex/three
	name = "Auspex"
	vitaecost = 30
	constant_vitaecost = 3
	zoom_out_amt = 6
	zoom_amt = 8
	add_meson = TRUE

/datum/action/vampire/auspex/four
	name = "Auspex"
	vitaecost = 20
	constant_vitaecost = 4
	zoom_out_amt = 10
	zoom_amt = 10
	add_xray = TRUE

/datum/action/vampire/auspex/activate_power()
	. = ..()
	if(!looking)
		lookie()

/datum/action/vampire/auspex/deactivate_power()
	. = ..()
	if(looking)
		unlooky()

/datum/action/vampire/auspex/proc/lookie()
	SIGNAL_HANDLER

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(deactivate_power))
	listeningTo = owner
	if(!owner?.client)
		return
	var/client/C = owner.client
	var/_x = 0
	var/_y = 0
	switch(owner.dir)
		if(NORTH)
			_y = zoom_amt
		if(EAST)
			_x = zoom_amt
		if(SOUTH)
			_y = -zoom_amt
		if(WEST)
			_x = -zoom_amt

	C.change_view(get_zoomed_view(world.view, zoom_out_amt))
	C.pixel_x = world.icon_size*_x
	C.pixel_y = world.icon_size*_y
	looking = TRUE

	if(add_meson)
		if(HAS_TRAIT(owner, TRAIT_MESON_VISION))
			return
		else
			ADD_TRAIT(owner, TRAIT_MESON_VISION, "Auspex")
			owner.update_sight()
			return

	if(add_xray)
		if(HAS_TRAIT(owner, TRAIT_XRAY_VISION))
			return
		else
			ADD_TRAIT(owner, TRAIT_XRAY_VISION, "Auspex")
			owner.update_sight()
			return

/datum/action/vampire/auspex/proc/unlooky()
	SIGNAL_HANDLER

	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null
	if(owner && owner.client)
		var/client/C = owner.client
		C.change_view(CONFIG_GET(string/default_view))
		owner.client.pixel_x = 0
		owner.client.pixel_y = 0

	looking = FALSE

	if(HAS_TRAIT_FROM(owner, TRAIT_MESON_VISION, "Auspex"))
		REMOVE_TRAIT(owner, TRAIT_MESON_VISION, "Auspex")

	if(HAS_TRAIT_FROM(owner, TRAIT_XRAY_VISION, "Auspex"))
		REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, "Auspex")

	owner.update_sight()

/datum/action/vampire/auspex/Destroy()
	listeningTo = null
	return ..()
