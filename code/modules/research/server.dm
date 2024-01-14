/// Default master server machine state. Use a special screwdriver to get to the next state.
#define HDD_PANEL_CLOSED 0
/// Front master server HDD panel has been removed. Use a special crowbar to get to the next state.
#define HDD_PANEL_OPEN 1
/// Master server HDD has been pried loose and is held in by only cables. Use a special set of wirecutters to finish stealing the objective.
#define HDD_PRIED 2
/// Master server HDD has been cut loose.
#define HDD_CUT_LOOSE 3
/// The ninja has blown the HDD up.
#define HDD_OVERLOADED 4

/obj/machinery/rnd/server
	name = "\improper R&D Server"
	desc = "A computer system running a deep neural network that processes arbitrary information to produce data useable in the development of new technologies. In layman's terms, it makes research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	var/datum/techweb/stored_research
	//Code for point mining here.
	var/overheated = FALSE
	var/working = TRUE
	var/research_disabled = FALSE
	var/server_id = 0
	var/heat_gen = 1
	// some notes on this number
	// as of 4/29/2020, the techweb was set that fed a constant of 52.3 no matter how many servers there were
	// A coeffecent of sqrt(100/<servercount>) is set up on a per some older code.  Since there are normaly 2 servers this comes out to
	// sqrt(100/2) = 7.07, then 52.3 /  7.07 = 7.40.  Since we have two servers per map, these are added together
	// 7.40./2 = 3.70 (note, all these values are rounded).  This is howw this number was found.
	var/base_mining_income = 3.70

	// Heating is weird.  Since  the servers are stored in a room that sucks air in one vent, into a pipe network, to a
	// T1 freezer, then out another vent at standard presure, the rooms temps could vary as wieldy as 100K.  The T1 freezer
	// has 10000 heat power at the start, so each of the servers produce that but only heat a quarter of the turf
	// This allows the servers to rapidly heat up in under 5 min to the shut off point and make it annoying to cool back
	// down, giving time for RD to fire the guy who shut off the cooler

	var/heating_power = 10000		// Changed the value from 40000.  Just enough for a T1 freezer to keep up with 2 of them
	var/heating_effecency = 0.25
	var/temp_tolerance_low = T0C
	var/temp_tolerance_high = T20C
	var/temp_tolerance_damage = T0C + 200		// Most CPUS get up to 200C they start breaking.  TODO: Start doing damage to the server?
	var/temp_penalty_coefficient = 0.5	//1 = -1 points per degree above high tolerance. 0.5 = -0.5 points per degree above high tolerance.
	var/current_temp = -1
	req_access = list(ACCESS_RD_SERVER) //ONLY THE R&D, AND WHO HAVE THE ACCESS TO CAN CHANGE SERVER SETTINGS.

/obj/machinery/rnd/server/Initialize(mapload)
	. = ..()

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
	// The +10 is so the sparks work
	RefreshParts()

/obj/machinery/rnd/server/Destroy()
	SSresearch.servers -= src
	return ..()

/obj/machinery/rnd/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	heat_gen = initial(src.heat_gen) / max(1, tot_rating)

/obj/machinery/rnd/server/update_icon()
	if (panel_open)
		icon_state = "RD-server-on_t"
		return
	if (machine_stat & EMPED || machine_stat & NOPOWER)
		icon_state = "RD-server-off"
		return
	if (research_disabled || overheated)
		icon_state = "RD-server-halt"
		return
	icon_state = "RD-server-on"

/obj/machinery/rnd/server/power_change()
	. = ..()
	refresh_working()
	return

/obj/machinery/rnd/server/process()
	if(!working)
		current_temp = -1
		return
	var/turf/L = get_turf(src)
	var/datum/gas_mixture/env
	if(istype(L))
		env = L.return_air()
		// This is from the RD server code.  It works well enough but I need to move over the
		// sspace heater code so we can caculate power used per tick as well and making this both
		// exothermic and an endothermic component
		if(env)
			var/perc = max((get_env_temp() - temp_tolerance_high), 0) * temp_penalty_coefficient / base_mining_income

			env.adjust_heat(heating_power * perc * heat_gen)
			air_update_turf()
			src.air_update_turf()
		else
			current_temp = env ? env.return_temperature() : -1

/obj/machinery/rnd/server/proc/get_env_temp()
	// if we are on and ran though one tick
	if(working && current_temp >= 0)
		return current_temp
	else
		// otherwise we get the temp from the turf
		var/turf/L = get_turf(src)
		var/datum/gas_mixture/env
		if(istype(L))
			env = L.return_air()
		return env ? env.return_temperature() : T20C			// env might be null at round start.  This stops runtimes

/obj/machinery/rnd/server/proc/refresh_working()
	var/current_temp  = get_env_temp()

	// Once we go over the damage temp, the breaker is flipped
	// Power is still going to the server
	if(!overheated && current_temp >= temp_tolerance_damage)
		investigate_log("[src] overheated!", INVESTIGATE_RESEARCH)		// Do we need this?
		overheated = TRUE

	// If we are over heated, the server will not restart till
	// eveything is at a safe temp
	if(overheated && current_temp <= temp_tolerance_low)
		overheated = FALSE

	// If we are overheateed, start shooting out sparks
	// don't shoot them if we have no power
	if(overheated && !(machine_stat & NOPOWER) && prob(40))
		do_sparks(5, FALSE, src)

	if(overheated || research_disabled || machine_stat & EMPED || machine_stat & NOPOWER)
		working = FALSE
	else
		working = TRUE

	update_icon()

/obj/machinery/rnd/server/emp_act()
	. = ..()
	refresh_working()

/obj/machinery/rnd/server/emp_reset()
	..()
	refresh_working()

/obj/machinery/rnd/server/proc/toggle_disable()
	research_disabled = !research_disabled
	refresh_working()

/obj/machinery/rnd/server/proc/mine()
	// Cheap way to refresh if we are operational or not.  mine() is run on the tech web
	// subprocess.  This saves us having to run our own subprocess
	refresh_working()
	if(working)
		var/penalty = max((get_env_temp() - temp_tolerance_high), 0) * temp_penalty_coefficient
		return list(TECHWEB_POINT_TYPE_GENERIC = max(base_mining_income - penalty, 0))
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
	for(var/obj/machinery/rnd/server/S in SSresearch.servers)
		servers += list(list(
			"name" = S.name,
			"server_id" = S.server_id,
			"temperature" = S.get_env_temp(),
			"temperature_warning" = S.temp_tolerance_high,
			"temperature_max" = S.temp_tolerance_damage,
			"enabled" = !S.research_disabled,
			"overheated" = S.overheated,
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
				test_id = text2num(test_id)		// Not sure why its sent as a string

			for(var/obj/machinery/rnd/server/S in SSresearch.servers)
				if(S.server_id == test_id)
					S.toggle_disable()

					investigate_log("[S.name] was turned [S.research_disabled ? "off" : "on"] by [key_name(usr)]", INVESTIGATE_RESEARCH)
					. = TRUE
					break

/obj/machinery/computer/rdservercontrol/on_emag(mob/user)
	..()
	playsound(src, "sparks", 75, 1)
	to_chat(user, "<span class='notice'>You disable the security protocols.</span>")

/// Master R&D server. As long as this still exists and still holds the HDD for the theft objective, research points generate at normal speed. Destroy it or an antag steals the HDD? Half research speed.
/obj/machinery/rnd/server/master
	var/obj/item/computer_hardware/hard_drive/cluster/hdd_theft/source_code_hdd
	var/deconstruction_state = HDD_PANEL_CLOSED
	var/front_panel_screws = 4
	var/hdd_wires = 6

/obj/machinery/rnd/server/master/Initialize(mapload)
	. = ..()
	name = "master " + name
	source_code_hdd = new(src)
	SSresearch.master_servers += src

	add_overlay("RD-server-objective-stripes")

/obj/machinery/rnd/server/master/Destroy()
	if(source_code_hdd)
		QDEL_NULL(source_code_hdd)

	SSresearch.master_servers -= src

	return ..()

/obj/machinery/rnd/server/master/examine(mob/user)
	. = ..()

	switch(deconstruction_state)
		if(HDD_PANEL_CLOSED)
			. += "The front panel is closed. You can see some recesses which may have <b>screws</b>."
		if(HDD_PANEL_OPEN)
			. += "The front panel is dangling open. The hdd is in a secure housing. Looks like you'll have to <b>pry</b> it loose."
		if(HDD_PRIED)
			. += "The front panel is dangling open. The hdd has been pried from its housing. It is still connected by <b>wires</b>."
		if(HDD_CUT_LOOSE)
			. += "The front panel is dangling open. All you can see inside are cut wires and mangled metal."
		if(HDD_OVERLOADED)
			. += "The front panel is dangling open. The hdd inside is destroyed and the wires are all burned."

/obj/machinery/rnd/server/master/tool_act(mob/living/user, obj/item/tool, tool_type)
	// Only antags are given the training and knowledge to disassemble this thing.
	if(is_special_character(user))
		return ..()

	balloon_alert(user, "you can't find an obvious maintenance hatch!")
	return TRUE

/obj/machinery/rnd/server/master/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/computer_hardware/hard_drive/cluster/hdd_theft))
		switch(deconstruction_state)
			if(HDD_PANEL_CLOSED)
				balloon_alert(user, "you can't find a place to insert it!")
				return TRUE
			if(HDD_PANEL_OPEN)
				balloon_alert(user, "you weren't trained to install this!")
				return TRUE
			if(HDD_PRIED)
				balloon_alert(user, "the hdd housing is completely broken, it won't fit!")
				return TRUE
			if(HDD_CUT_LOOSE)
				balloon_alert(user, "the hdd housing is completely broken and all the wires are cut!")
				return TRUE
			if(HDD_OVERLOADED)
				balloon_alert(user, "the inside is scorched and all the wires are burned!")
				return TRUE
	return ..()

/obj/machinery/rnd/server/master/screwdriver_act(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PANEL_CLOSED)
		return FALSE

	to_chat(user, "<span class='danger'>You can see [front_panel_screws] screw\s. You start unscrewing [front_panel_screws == 1 ? "it" : "them"]...</span>")
	while(tool.use_tool(src, user, 7.5 SECONDS, volume=100))
		front_panel_screws--

		if(front_panel_screws <= 0)
			deconstruction_state = HDD_PANEL_OPEN
			to_chat(user, "<span class='danger'>You remove the last screw from [src]'s front panel.</span>")
			add_overlay("RD-server-hdd-panel-open")
			return TRUE
		to_chat(user, "<span class='danger'>The screw breaks as you remove it. Only [front_panel_screws] left...")
	return TRUE

/obj/machinery/rnd/server/master/crowbar_act(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PANEL_OPEN)
		return FALSE

	to_chat(user, "<span class='danger'>You can see [source_code_hdd] in a secure housing behind the front panel. You begin to pry it loose...")
	if(tool.use_tool(src, user, 15 SECONDS, volume=100))
		to_chat(user, "<span class='danger'>You destroy the housing, prying [source_code_hdd] free.</span>")
		deconstruction_state = HDD_PRIED
	return TRUE

/obj/machinery/rnd/server/master/wirecutter_act(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PRIED)
		return FALSE

	to_chat(user, "<span class='danger'>There are [hdd_wires] wire\s connected to [source_code_hdd]. You start cutting [hdd_wires == 1 ? "it" : "them"]...</span>")
	while(tool.use_tool(src, user, 7.5 SECONDS, volume=100))
		hdd_wires--

		if(hdd_wires <= 0)
			deconstruction_state = HDD_CUT_LOOSE
			to_chat(user, "<span class='danger'>You cut the final wire and remove [source_code_hdd].</span>")
			user.put_in_hands(source_code_hdd)
			source_code_hdd = null
			return TRUE
		to_chat(user, "<span class='danger'>You delicately cut the wire. [hdd_wires] wire\s left...</span>")
	return TRUE

/obj/machinery/rnd/server/master/on_deconstruction()
	// If the machine contains a source code HDD, destroying it will negatively impact research speed. Safest to log this.
	if(source_code_hdd)
		// If there's a usr, this was likely a direct deconstruction of some sort. Extra logging info!
		if(usr)
			var/mob/user = usr

			message_admins("[key_name_admin(user)] deconstructed [ADMIN_JMP(src)], destroying [source_code_hdd] inside.")
			log_game("[key_name(user)] deconstructed [src], destroying [source_code_hdd] inside.")
			return ..()

		message_admins("[ADMIN_JMP(src)] has been deconstructed by an unknown user, destroying [source_code_hdd] inside.")
		log_game("[src] has been deconstructed by an unknown user, destroying [source_code_hdd] inside.")

	return ..()

/// Destroys the source_code_hdd if present and sets the machine state to overloaded, adding the panel open overlay if necessary.
/obj/machinery/rnd/server/master/proc/overload_source_code_hdd()
	if(source_code_hdd)
		QDEL_NULL(source_code_hdd)

	if(deconstruction_state == HDD_PANEL_CLOSED)
		add_overlay("RD-server-hdd-panel-open")

	front_panel_screws = 0
	hdd_wires = 0
	deconstruction_state = HDD_OVERLOADED

#undef HDD_PANEL_CLOSED
#undef HDD_PANEL_OPEN
#undef HDD_PRIED
#undef HDD_CUT_LOOSE
