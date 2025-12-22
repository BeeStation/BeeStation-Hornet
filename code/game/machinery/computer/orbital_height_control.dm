/obj/machinery/computer/orbital_height_control
	name = "orbital height control console"
	desc = "A console used to monitor and control the station's orbital height and positioning systems."
	icon_screen = "comm_logs"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/orbital_height_control
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/orbital_height_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrbitalHeightControl", name)
		ui.open()

/obj/machinery/computer/orbital_height_control/ui_data(mob/user)
	var/list/data = list()
	// Boilerplate data - can be expanded later
	return data

/obj/machinery/computer/orbital_height_control/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	// Future actions can be added here
	return TRUE

/obj/machinery/computer/orbital_height_control/ui_state(mob/user)
	return GLOB.default_state
