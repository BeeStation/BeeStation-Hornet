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

	/// The ringtone that will be set on initialize
	var/init_ringtone = "beep"
	/// If the device starts with its ringer on
	var/init_ringer_on = TRUE

	/// Whether this modpc should be hidden from messaging TODO: Move this to the messenger app or maybe the network card
	var/messenger_invisible = FALSE
	/// The main backbone that handles most ModPC logic while this type only handles power and other specific things.
	var/obj/item/mainboard/mainboard = null

/obj/item/modular_computer/Initialize(mapload)
	. = ..()
	mainboard = new(src)
	mainboard.physical_holder = src
	mainboard.max_hardware_w_class = max_hardware_size

/obj/item/modular_computer/Destroy()
	QDEL_NULL(mainboard)
	return ..()

/obj/machinery/modular_computer/examine(mob/user)
	. = ..()
	if(istype(mainboard))
		. += mainboard.internal_parts_examine(user)

/obj/item/modular_computer/ui_action_click(mob/user, actiontype)
	// if(istype(actiontype, light_action))
	// 	toggle_flashlight()
	// else
	// 	..()

/obj/item/modular_computer/AltClick(mob/user)
	if(istype(mainboard))
		. = mainboard.AltClick(user)

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

/obj/item/modular_computer/attack_ai(mob/user)
	if(istype(mainboard))
		return mainboard.attack_ai(user)
	return ..()

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	if(istype(mainboard))
		return mainboard.attack_ghost(user)
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
