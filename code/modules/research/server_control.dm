/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Used to manage access to research and manufacturing databases."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	req_access = list(ACCESS_RD_SERVER)
	circuit = /obj/item/circuitboard/computer/rdservercontrol

	/// Connected techweb node the server is connected to.
	var/datum/techweb/stored_research

/obj/machinery/computer/rdservercontrol/LateInitialize()
	. = ..()
	if(!stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/rdservercontrol)
DEFINE_BUFFER_HANDLER(/obj/machinery/computer/rdservercontrol)
	if(istype(buffer, /datum/techweb))
		balloon_alert(user, "techweb connected")
		stored_research = buffer
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/computer/rdservercontrol/on_emag(mob/user)
	..()
	balloon_alert(user, "security protocols disabled")
	playsound(src, "sparks", 75, TRUE)

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ServerControl")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/rdservercontrol/ui_data(mob/user)
	var/list/data = list()

	data["server_connected"] = !!stored_research

	if(stored_research)
		data["logs"] += stored_research.research_logs

		for(var/obj/machinery/rnd/server/server as anything in stored_research.techweb_servers)
			data["servers"] += list(list(
				"server_name" = server.name,
				"server_details" = server.get_status_text(),
				"server_enabled" = (server.powered() && !server.machine_stat),
				"server_efficiency" = server.get_efficiency(),
				"server_temperature" = server.get_temperature(),
				"server_temperature_warning" = server.get_warning_temperature(),
				"server_temperature_overheat" = server.get_overheat_temperature(),
				"server_ref" = REF(server),
			))

		for(var/obj/machinery/computer/rdconsole/console as anything in stored_research.consoles_accessing)
			data["consoles"] += list(list(
				"console_name" = console,
				"console_location" = get_area(console),
				"console_locked" = console.locked,
				"console_ref" = REF(console),
			))

	return data

/obj/machinery/computer/rdservercontrol/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE
	if(!allowed(usr) && !(obj_flags & EMAGGED))
		balloon_alert(usr, "access denied!")
		playsound(src, 'sound/machines/click.ogg', 20, TRUE)
		return FALSE

	switch(action)
		if("toggle_server")
			var/obj/machinery/rnd/server/server_selected = locate(params["selected_server"]) in stored_research.techweb_servers
			if(!server_selected)
				return FALSE
			server_selected.toggle_disable(usr)
			return TRUE
		if("lock_console")
			var/obj/machinery/computer/rdconsole/console_selected = locate(params["selected_console"]) in stored_research.consoles_accessing
			if(!console_selected)
				return FALSE
			console_selected.locked = !console_selected.locked
			return TRUE
