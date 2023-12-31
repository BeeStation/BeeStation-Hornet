/obj/machinery/server/rnd
	name = "\improper R&D Server"
	desc = "A computer system running a deep neural network that processes arbitrary information to produce data useable in the development of new technologies. In layman's terms, it makes research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	idle_power_usage = 40
	var/datum/techweb/stored_research
	//Code for point mining here.
	var/research_disabled = FALSE
	var/server_id = 0
	var/base_mining_income = 3.70
	req_access = list(ACCESS_RD_SERVER)

/obj/machinery/server/rnd/Initialize(mapload)
	. = ..()

	server_id = 0
	while(server_id == 0)
		var/test_id = rand(1,65535)
		for(var/obj/machinery/server/rnd/S in SSresearch.servers)
			if(test_id == S.server_id)
				test_id = 0
		server_id = test_id

	name += " [uppertext(num2hex(server_id, -1))]"
	SSresearch.servers |= src
	stored_research = SSresearch.science_tech
	RefreshParts()

/obj/machinery/server/rnd/Destroy()
	SSresearch.servers -= src
	return ..()

// better parts mean better power efficiency and less heat generated
/obj/machinery/server/rnd/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	idle_power_usage = initial(src.idle_power_usage) / max(1, tot_rating)

/obj/machinery/server/rnd/update_icon()
	if (panel_open)
		icon_state = "RD-server-on_t"
		return
	if (machine_stat & EMPED || machine_stat & NOPOWER)
		icon_state = "RD-server-off"
		return
	if (research_disabled || machine_stat & OVERHEATED)
		icon_state = "RD-server-halt"
		return
	icon_state = "RD-server-on"



/obj/machinery/server/rnd/proc/toggle_disable()
	set_machine_stat(machine_stat ^ TURNED_OFF)

/obj/machinery/server/rnd/proc/mine()
	auto_use_power()
	if(efficiency > 0)
		return list(TECHWEB_POINT_TYPE_GENERIC = max(base_mining_income * efficiency, 0))
	else
		return list(TECHWEB_POINT_TYPE_GENERIC = 0)

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
	for(var/obj/machinery/server/rnd/S in SSresearch.servers)
		servers += list(list(
			"name" = S.name,
			"server_id" = S.server_id,
			"temperature" = S.temperature,
			"overheating_temp" = S.overheating_temp,
			"temperature_max" = S.overheated_temp,
			"enabled" = !(S.machine_stat & TURNED_OFF),
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
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(action)
		if("enable_server")
			var/test_id = params["server_id"]
			if(istext(test_id))
				test_id = text2num(test_id)

			for(var/obj/machinery/server/rnd/S in SSresearch.servers)
				if(S.server_id == test_id)
					S.toggle_disable()

					investigate_log("[S.name] was turned [S.machine_stat & TURNED_OFF ? "off" : "on"] by [key_name(usr)]", INVESTIGATE_RESEARCH)
					. = TRUE
					break

/obj/machinery/computer/rdservercontrol/on_emag(mob/user)
	..()
	playsound(src, "sparks", 75, 1)
	to_chat(user, "<span class='notice'>You disable the security protocols.</span>")
