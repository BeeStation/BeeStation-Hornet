/obj/machinery/rnd/server
	name = "\improper R&D Server"
	desc = "A computer system running a deep neural network that processes arbitrary information to produce data useable in the development of new technologies. In layman's terms, it makes research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	circuit = /obj/item/circuitboard/machine/rdserver

	idle_power_usage = 5 // having servers online uses a little bit of power
	active_power_usage = 50 // mining uses a lot of power

	var/datum/techweb/stored_research
	var/server_id = 0
	var/heat_gen = 1
	// some notes on this number
	// as of 4/29/2020, the techweb was set that fed a constant of 52.3 no matter how many servers there were
	// A coeffecent of sqrt(100/<servercount>) is set up on a per some older code.  Since there are normaly 2 servers this comes out to
	// sqrt(100/2) = 7.07, then 52.3 /  7.07 = 7.40.  Since we have two servers per map, these are added together
	// 7.40./2 = 3.70 (note, all these values are rounded).  This is howw this number was found.
	var/base_mining_income = 3.70

	req_access = list(ACCESS_RD_SERVER) //ONLY THE R&D, AND WHO HAVE THE ACCESS TO CAN CHANGE SERVER SETTINGS.
	var/datum/component/server/server_component

/obj/machinery/rnd/server/Initialize(mapload)
	. = ..()
	server_component = AddComponent(/datum/component/server)
	server_id = 0
	while(server_id == 0)
		var/test_id = rand(1,65535)
		// Humm. we should make a lookup in glob for a hash look up on machines...latter
		for(var/obj/machinery/rnd/server/S in SSresearch.servers)
			if(test_id == S.server_id)
				test_id = 0
		server_id = test_id

	name += " [uppertext(num2hex(server_id, -1))]" //gives us a random four-digit hex number as part of the name. Y'know, for fluff.
	SSresearch.servers |= src
	stored_research = SSresearch.science_tech

/obj/machinery/rnd/server/Destroy()
	server_component = null
	SSresearch.servers -= src
	return ..()

/obj/machinery/rnd/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	active_power_usage = initial(src.active_power_usage) / max(1, tot_rating)

/obj/machinery/rnd/server/update_icon()
	if (panel_open)
		icon_state = "RD-server-on_t"
		return
	if (machine_stat & EMPED || machine_stat & NOPOWER)
		icon_state = "RD-server-off"
		return
	if (machine_stat & (TURNED_OFF|OVERHEATED))
		icon_state = "RD-server-halt"
		return
	icon_state = "RD-server-on"


/obj/machinery/rnd/server/proc/toggle_disable()
	set_machine_stat(machine_stat ^ TURNED_OFF)

/obj/machinery/rnd/server/proc/mine()
	use_power(active_power_usage, power_channel)
	var/efficiency = get_efficiency()
	if(!powered() || efficiency <= 0 || machine_stat)
		return null
	return list(TECHWEB_POINT_TYPE_GENERIC = max(base_mining_income * efficiency, 0))

/obj/machinery/rnd/server/proc/get_temperature()
	return server_component.temperature

/obj/machinery/rnd/server/proc/get_overheat_temperature()
	return server_component.overheated_temp

/obj/machinery/rnd/server/proc/get_warning_temperature()
	return server_component.warning_temp

/obj/machinery/rnd/server/proc/get_efficiency()
	return server_component.efficiency

/obj/machinery/rnd/server/on_set_machine_stat(old_value)
	. = ..()
	update_appearance()

/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Used to manage access to research and manufacturing databases."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	req_access = list(ACCESS_RD_SERVER)
	circuit = /obj/item/circuitboard/computer/rdservercontrol

/obj/machinery/computer/rdservercontrol/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RDConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/rdservercontrol/ui_data(mob/user)
	var/list/data = list()
	var/servers[0]
	for(var/obj/machinery/rnd/server/S in SSresearch.servers)
		servers += list(list(
			"name" = S.name,
			"server_id" = S.server_id,
			"temperature" = S.get_temperature(),
			"temperature_warning" = S.get_warning_temperature(),
			"temperature_max" = S.get_overheat_temperature(),
			"enabled" = !(S.machine_stat & TURNED_OFF), // displays state of the power button as you can turn on/off servers using this console
			"overheated" = (S.machine_stat & OVERHEATED),
		))
	data["servers"] = servers

	var/datum/techweb/stored_research = SSresearch.science_tech
	if(stored_research.research_logs.len)
		var/rlogs[0]
		for(var/i=stored_research.research_logs.len, i>0, i--)
			var/list/L = stored_research.research_logs[i]
			rlogs += list(list(
				"entry" = i,
				"research_name" = L[1],
				"cost" = L[2],
				"researcher_name" = L[3],
				"location" = L[4],
			))
		data["logs"] = rlogs

	return data

/obj/machinery/computer/rdservercontrol/ui_act(action, params)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("enable_server")
			var/test_id = params["server_id"]
			if(istext(test_id))
				test_id = text2num(test_id)		// Not sure why its sent as a string

			for(var/obj/machinery/rnd/server/S in SSresearch.servers)
				if(S.server_id == test_id)
					S.toggle_disable()

					investigate_log("[S.name] was turned [(S.machine_stat & TURNED_OFF) ? "off" : "on"] by [key_name(usr)]", INVESTIGATE_RESEARCH)
					. = TRUE
					break

/obj/machinery/computer/rdservercontrol/on_emag(mob/user)
	..()
	playsound(src, "sparks", 75, 1)
	to_chat(user, span_notice("You disable the security protocols."))
