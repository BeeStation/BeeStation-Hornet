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
	/// Additional bays set aside for expansion
	var/max_bays = 0
	/// Hardware flags. TODO: Maybe move this somewhere else?
	var/hardware_flag = 0
	/// Whether this modpc should be hidden from messaging TODO: Move this to the messenger app or maybe the network card
	var/messenger_invisible = FALSE
	/// If we need to override the default themes with the syndicate one
	var/syndicate_themed = FALSE

	/// If it's bypassing the icon state variables below
	var/bypass_icon_state = FALSE
	var/icon_state_unpowered = null
	var/icon_state_powered = null
	var/icon_state_menu = "menu"

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

	/// A list of hardware components we want to add by ComponentInitialize()
	var/list/obj/item/computer_hardware/install_components
	/// The internal cell type we also want to add
	var/obj/item/stock_parts/install_cell

/obj/item/modular_computer/Initialize(mapload, list/obj/item/computer_hardware/override_hardware, obj/item/stock_parts/override_cell)
	. = ..()
	if(!isnull(override_hardware))
		src.install_components = override_hardware
	if(!isnull(override_cell))
		src.install_cell = override_cell.type
	set_light_color(comp_light_color)
	set_light_range(comp_light_luminosity)
	if(has_light)
		light_action = new(src)
	update_icon()

/obj/item/modular_computer/ComponentInitialize()
	SHOULD_CALL_PARENT(TRUE) // just incase we forget somehow
	. = ..()

	AddComponent(/datum/component/modular_computer_integration, null, TRUE, CALLBACK(src, PROC_REF(install_modpc_hardware)), CALLBACK(src, PROC_REF(install_modpc_software)), max_hardware_size, max_bays)

/obj/item/modular_computer/proc/install_modpc_hardware(obj/item/mainboard/MB)
	SHOULD_CALL_PARENT(TRUE) // should always prevent forgetting hardware unless we explicity require it

	if(!isnull(install_cell))
		MB.install_component(new /obj/item/computer_hardware/battery(MB, install_cell))

	for(var/T in install_components)
		MB.install_component(new T)

	MB.update_id_display()
	if(syndicate_themed)
		MB.device_theme = THEME_SYNDICATE
		MB.theme_locked = TRUE

/obj/item/modular_computer/proc/install_modpc_software(obj/item/computer_hardware/hard_drive/hard_drive)
	SHOULD_CALL_PARENT(TRUE) // should always prevent missing software
	return

/obj/item/modular_computer/update_icon_state()
	. = ..()
	if(bypass_icon_state)
		return
	icon_state = mainboard.enabled ? icon_state_powered : icon_state_unpowered

/obj/item/modular_computer/update_overlays()
	. = ..()

	var/init_icon = initial(icon)
	if(!init_icon)
		return

	if(mainboard.enabled)
		. += mainboard.active_program ? mutable_appearance(init_icon, mainboard.active_program.program_icon_state) : mutable_appearance(init_icon, icon_state_menu)

	var/obj/item/computer_hardware/goober/pai/pai_slot = mainboard.all_components[MC_PAI]
	if(istype(pai_slot))
		. += istype(pai_slot.stored_card) ? mutable_appearance(init_icon, "pai-overlay") : mutable_appearance(init_icon, "pai-off-overlay")

	// if(obj_integrity <= integrity_failure * max_integrity)
	// 	add_overlay(mutable_appearance(init_icon, "bsod"))
	// 	add_overlay(mutable_appearance(init_icon, "broken"))

/obj/item/modular_computer/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, light_action))
		toggle_flashlight()
	else
		..()

/obj/item/modular_computer/GetAccess()
	var/obj/item/computer_hardware/id_slot/id_slot = mainboard.all_components[MC_ID_AUTH]
	if(!istype(id_slot))
		return

	return id_slot.GetAccess_parent()

/obj/item/modular_computer/GetID()
	var/obj/item/computer_hardware/id_slot/id_slot = mainboard.all_components[MC_ID_AUTH]
	if(!istype(id_slot))
		return

	return id_slot.GetID_parent()

// Big TODO: Make all of this into a component that responds to signals

/obj/item/modular_computer/proc/can_turn_on(mob/user)
	return TRUE

// /obj/item/modular_computer/on_emag(mob/user)
// 	if(istype(mainboard))
// 		return mainboard.on_emag(user)
// 	return ..()

// /obj/item/modular_computer/should_emag(mob/user)
// 	if(istype(mainboard))
// 		return mainboard.should_emag(user)
// 	return ..()

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
