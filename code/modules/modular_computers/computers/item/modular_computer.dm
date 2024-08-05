GLOBAL_LIST_EMPTY(TabletMessengers) // a list of all active messengers, similar to GLOB.PDAs (used primarily with ntmessenger.dm)

// This is the base type that does all the hardware stuff.
// Other types expand it - tablets use a direct subtypes, and
// consoles and laptops use "procssor" item that is held inside machinery piece
/obj/item/modular_computer
	name = "modular microcomputer"
	desc = "A small portable microcomputer."
	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop"
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 0.6
	light_color = "#FFFFFF"
	light_on = FALSE

	/// Maximal hardware size. Currently, tablets have 1, laptops 2 and consoles 3. Limits what hardware types can be installed.
	var/max_hardware_size = 0
	/// Hardware flags. TODO: Maybe move this somewhere else?
	var/hardware_flag = 0
	/// Whether this modpc should be hidden from messaging TODO: Move this to the messenger app or maybe the network card
	var/messenger_invisible = FALSE
	/// If it's bypassing the set icon state
	var/bypass_icon_state = FALSE
	/// If we need to override the default themes with the syndicate one
	var/syndicate_themed = FALSE

	/// The ringtone that will be set on initialize
	var/init_ringtone = "beep"
	/// If the device starts with its ringer on
	var/init_ringer_on = TRUE

	/// If the computer has a flashlight/LED light/what-have-you installed
	var/has_light = FALSE
	/// How far the computer's light can reach, is not editable by players.
	var/comp_light_luminosity = 3
	/// The built-in light's color, editable by players.
	var/comp_light_color = "#FFFFFF"
	/// The action for enabling/disabling the flashlight
	var/datum/action/item_action/toggle_computer_light/light_action

	/// The main item that handles most ModPC logic while this type only handles power and other specific things.
	var/obj/item/mainboard/mainboard = null

/obj/item/modular_computer/Initialize(mapload)
	SHOULD_CALL_PARENT(TRUE)
	mainboard = new(src)
	mainboard.physical_holder = src
	. = ..()
	mainboard.max_hardware_w_class = max_hardware_size
	set_light_color(comp_light_color)
	set_light_range(comp_light_luminosity)
	mainboard.update_id_display()
	if(has_light)
		light_action = new(src)
	if(syndicate_themed)
		// Force syndie theme
		mainboard.device_theme = THEME_SYNDICATE
		mainboard.theme_locked = TRUE
	update_icon()
	return INITIALIZE_HINT_LATELOAD

/obj/item/modular_computer/LateInitialize()
	. = ..()
	install_programs(mainboard.all_components[MC_HDD])

/obj/item/modular_computer/proc/install_programs(obj/item/computer_hardware/hard_drive/hard_drive)
	return

/obj/item/modular_computer/Destroy()
	QDEL_NULL(mainboard)
	return ..()

/obj/item/modular_computer/examine(mob/user)
	. = ..()
	if(istype(mainboard))
		. += mainboard.internal_parts_examine(user)

/obj/item/modular_computer/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, light_action))
		toggle_flashlight()
	else
		..()

// Big TODO: Make all of this into a component that responds to signals

/obj/item/modular_computer/AltClick(mob/user)
	if(istype(mainboard))
		return mainboard.AltClick(user)

/obj/item/modular_computer/attack_ai(mob/user)
	if(istype(mainboard))
		return mainboard.attack_ai_parent(user)
	return ..()

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	if(istype(mainboard))
		return mainboard.attack_ghost_parent(user)
	return ..()

// this computer was used to attack an object
/obj/item/modular_computer/attack_obj(obj/O, mob/living/user)
	if(istype(mainboard))
		return mainboard.attack_obj_parent(O, user)
	return ..()

/obj/item/modular_computer/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(isturf(loc))
		return attack_self(user)

// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs. (They are now!! you are welcome - itsmeow)
/obj/item/modular_computer/GetAccess()
	if(istype(mainboard))
		return mainboard.GetAccess()
	return ..()

/obj/item/modular_computer/GetID()
	if(istype(mainboard))
		return mainboard.GetID()
	return ..()

/obj/item/modular_computer/RemoveID()
	if(istype(mainboard))
		return mainboard.RemoveID()
	return ..()

/obj/item/modular_computer/InsertID(obj/item/inserting_item)
	if(istype(mainboard))
		return mainboard.InsertID()
	return ..()

/obj/item/modular_computer/MouseDrop(obj/over_object, src_location, over_location)
	if(istype(mainboard))
		return mainboard.MouseDrop(over_object, src_location, over_location)
	return ..()

/obj/item/modular_computer/should_emag(mob/user)
	if(istype(mainboard))
		return mainboard.should_emag(user)
	return ..()

/obj/item/modular_computer/on_emag(mob/user)
	if(istype(mainboard))
		return mainboard.on_emag(user)
	return ..()

/obj/item/modular_computer/examine(mob/user)
	if(istype(mainboard))
		return mainboard.on_emag(user)
	. = ..()

/obj/item/modular_computer/proc/turn_on(mob/user, open_ui = TRUE)
	if(istype(mainboard))
		return mainboard.turn_on(user, open_ui)
	return FALSE

/obj/item/modular_computer/proc/install_component(obj/item/computer_hardware/install, mob/living/user = null)
	if(isnull(mainboard))
		stack_trace("Called install_component() without a mainboard installed.")
	mainboard.install_component(install, user)

/**
  * Toggles the computer's flashlight, if it has one.
  *
  * Called from ui_act(), does as the name implies.
  * It is separated from ui_act() to be overwritten as needed.
*/
/obj/item/modular_computer/proc/toggle_flashlight()
	if(!has_light)
		return FALSE
	set_light_on(!light_on)
	update_icon()
	// Show the light_on overlay on top of the action button icon
	if(light_action?.owner)
		light_action.UpdateButtonIcon(force = TRUE)
	return TRUE

/**
  * Sets the computer's light color, if it has a light.
  *
  * Called from ui_act(), this proc takes a color string and applies it.
  * It is separated from ui_act() to be overwritten as needed.
  * Arguments:
  ** color is the string that holds the color value that we should use. Proc auto-fails if this is null.
*/
/obj/item/modular_computer/proc/set_flashlight_color(color)
	if(!has_light || !color)
		return FALSE
	comp_light_color = color
	set_light_color(color)
	return TRUE
