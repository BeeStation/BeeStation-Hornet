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

/datum/discipline/auspex/level_up(datum/antagonist/vampire/clan_owner)
	. = ..()
	var/mob/living/ownermob = clan_owner.owner.current
	if(level >= 4)
		to_chat(ownermob, span_cultbold("You have reached level 3 in Auspex, sharpening your senses to such a degree that you can now hear through walls."), type = MESSAGE_TYPE_INFO)
		if(!HAS_TRAIT(ownermob, TRAIT_XRAY_HEARING))
			ADD_TRAIT(ownermob, TRAIT_XRAY_HEARING, "Auspex")

/datum/discipline/auspex/apply_discipline_quirks(datum/antagonist/vampire/clan_owner)
	var/mob/living/ownermob = clan_owner.owner.current
	if(!HAS_TRAIT(ownermob, TRAIT_GOOD_HEARING))
		to_chat(ownermob, span_cultbold("You have reached level 1 in Auspex. You are now able to clearly hear whispering of others."), type = MESSAGE_TYPE_INFO)
		ADD_TRAIT(ownermob, TRAIT_GOOD_HEARING, "Auspex")

/datum/discipline/auspex/malkavian
	level_5 = list(/datum/action/vampire/auspex/four, /datum/action/vampire/astral_projection)

/**
 *	# Auspex
 */
/datum/action/vampire/auspex
	name = "Auspex"
	desc = "Sense the vitae of any creature directly, and use your keen senses to widen your perception."
	button_icon_state = "power_auspex"
	power_explanation = "- Level 1: When Activated, you will see further. \n\
					- Level 2: When Activated, you will see further, and hear faint whispers as clearly as normal speech.\n\
					- Level 3: When Activated, You get meson vision, with even more range. \n\
					- Level 4: When Activated, you will see much, much further, and be able to sense anything in sight, seeing through walls and barriers as if they were glass, and hearing speech through them too."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 20
	constant_vitaecost = 0.25
	cooldown_time = 1 SECONDS
	var/add_meson = FALSE
	var/add_xray = FALSE
	var/add_good_hearing = FALSE
	var/add_xray_hearing = FALSE
	var/zoom_out_amt = 5
	var/zoom_amt = 10

	var/looking = FALSE
	var/mob/listeningTo

/datum/action/vampire/auspex/two
	name = "Auspex"
	vitaecost = 20
	constant_vitaecost = 0.5
	zoom_out_amt = 10
	zoom_amt = 10
	add_good_hearing = TRUE

/datum/action/vampire/auspex/three
	name = "Auspex"
	vitaecost = 20
	constant_vitaecost = 0.75
	zoom_out_amt = 20
	zoom_amt = 5
	add_meson = TRUE

/datum/action/vampire/auspex/four
	name = "Auspex"
	vitaecost = 20
	constant_vitaecost = 1
	zoom_out_amt = 30
	zoom_amt = 0
	add_xray = TRUE
	add_xray_hearing = TRUE

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
	C.pixel_x = ICON_SIZE_X * _x
	C.pixel_y = ICON_SIZE_Y * _y
	looking = TRUE

	if(add_meson && !HAS_TRAIT(owner, TRAIT_MESON_VISION))
		ADD_TRAIT(owner, TRAIT_MESON_VISION, "Auspex")
		owner.update_sight()

	if(add_xray && !HAS_TRAIT(owner, TRAIT_XRAY_VISION))
		ADD_TRAIT(owner, TRAIT_XRAY_VISION, "Auspex")
		owner.update_sight()

/datum/action/vampire/auspex/proc/unlooky()
	SIGNAL_HANDLER

	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

	if(owner?.client)
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
