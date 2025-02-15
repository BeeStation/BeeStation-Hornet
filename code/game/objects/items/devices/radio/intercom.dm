/obj/item/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	dog_fashion = null
	unscrewed = FALSE
	layer = ABOVE_WINDOW_LAYER

/obj/item/radio/intercom/unscrewed
	unscrewed = TRUE

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/radio/intercom)

/obj/item/radio/intercom/Initialize(mapload, ndir, building)
	. = ..()
	var/area/current_area = get_area(src)
	if(!current_area)
		return
	RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(AreaPowerCheck))
	GLOB.intercoms_list += src

/obj/item/radio/intercom/Destroy()
	. = ..()
	GLOB.intercoms_list -= src

/obj/item/radio/intercom/examine(mob/user)
	. = ..()
	. += span_notice("Use [MODE_TOKEN_INTERCOM] when nearby to speak into it.")
	if(!unscrewed)
		. += span_notice("It's <b>screwed</b> and secured to the wall.")
	else
		. += span_notice("It's <i>unscrewed</i> from the wall, and can be <b>detached</b>.")

/obj/item/radio/intercom/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(unscrewed)
			user.visible_message(span_notice("[user] starts tightening [src]'s screws..."), span_notice("You start screwing in [src]..."))
			if(I.use_tool(src, user, 30, volume=50))
				user.visible_message(span_notice("[user] tightens [src]'s screws!"), span_notice("You tighten [src]'s screws."))
				unscrewed = FALSE
		else
			user.visible_message(span_notice("[user] starts loosening [src]'s screws..."), span_notice("You start unscrewing [src]..."))
			if(I.use_tool(src, user, 40, volume=50))
				user.visible_message(span_notice("[user] loosens [src]'s screws!"), span_notice("You unscrew [src], loosening it from the wall."))
				unscrewed = TRUE
		return
	else if(I.tool_behaviour == TOOL_WRENCH)
		if(!unscrewed)
			to_chat(user, span_warning("You need to unscrew [src] from the wall first!"))
			return
		user.visible_message(span_notice("[user] starts unsecuring [src]..."), span_notice("You start unsecuring [src]..."))
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 80))
			user.visible_message(span_notice("[user] unsecures [src]!"), span_notice("You detach [src] from the wall."))
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			new/obj/item/wallframe/intercom(get_turf(src))
			qdel(src)
		return
	return ..()

/obj/item/radio/intercom/attack_silicon(mob/user)
	interact(user)

/obj/item/radio/intercom/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/radio/intercom/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	interact(user)

/obj/item/radio/intercom/interact(mob/user)
	..()
	ui_interact(user)

/obj/item/radio/intercom/ui_state(mob/user)
	if(issilicon(user)) // Silicons can't use physical state remotely
		return GLOB.default_state

	return GLOB.physical_state // But monkeys can't use default state, and they can already use hotkeys

/obj/item/radio/intercom/can_receive(freq, list/levels)
	if(levels != RADIO_NO_Z_LEVEL_RESTRICTION)
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.get_virtual_z_level() in levels))
			return FALSE
	if(freq == FREQ_SYNDICATE)
		if(!(syndie))
			return FALSE//Prevents broadcast of messages over devices lacking the encryption

	return TRUE


/obj/item/radio/intercom/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, list/message_mods = list())
	if(message_mods[RADIO_EXTENSION] == MODE_INTERCOM)
		return  // Avoid hearing the same thing twice
	return ..()

/obj/item/radio/intercom/emp_act(severity)
	. = ..() // Parent call here will set `on` to FALSE.
	update_icon()

/obj/item/radio/intercom/end_emp_effect(curremp)
	. = ..()
	AreaPowerCheck() // Make sure the area/local APC is powered first before we actually turn back on.

/obj/item/radio/intercom/update_icon()
	. = ..()
	if(on)
		icon_state = initial(icon_state)
	else
		icon_state = "intercom-p"
	cut_overlays()
	if(listening)
		add_overlay("intercom-mic")
	if(broadcasting)
		add_overlay("intercom-bc")

/obj/item/radio/intercom/ui_act(action, params, datum/tgui/ui)
	. = ..()
	update_icon()

/obj/item/radio/intercom/AltClick(mob/user)
	. = ..()
	update_icon()

/obj/item/radio/intercom/CtrlShiftClick(mob/user)
	. = ..()
	update_icon()

/**
 * Proc called whenever the intercom's area loses or gains power. Responsible for setting the `on` variable and calling `update_icon()`.
 *
 * Normally called after the intercom's area receives the `COMSIG_AREA_POWER_CHANGE` signal, but it can also be called directly.
 * Arguments:
 * * source - the area that just had a power change.
 */
/obj/item/radio/intercom/proc/AreaPowerCheck(datum/source)
	SIGNAL_HANDLER

	var/area/current_area = get_area(src)
	if(!current_area)
		set_on(FALSE)
	else
		set_on(current_area.powered(AREA_USAGE_EQUIP)) // set "on" to the equipment power status of our area.
	update_icon()

/obj/item/radio/intercom/add_blood_DNA(list/blood_dna)
	return FALSE

//Created through the autolathe or through deconstructing intercoms. Can be applied to wall to make a new intercom on it!
/obj/item/wallframe/intercom
	name = "intercom frame"
	desc = "A ready-to-go intercom. Just slap it on a wall and screw it in!"
	icon_state = "intercom"
	result_path = /obj/item/radio/intercom/unscrewed
	pixel_shift = 26
	custom_materials = list(/datum/material/iron = 75, /datum/material/glass = 25)

MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom, 26)

/obj/item/radio/intercom/chapel
	name = "Confessional intercom"
	anonymize = TRUE

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/radio/intercom/chapel)

/obj/item/radio/intercom/chapel/Initialize(mapload, ndir, building)
	. = ..()
	set_frequency(1481)
	set_broadcasting(TRUE)

//MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/prison, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/chapel, 26)
