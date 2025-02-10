
/*
	Telecommunications Monitoring Console displays the status of the telecommunications network it's connected to.
*/


/obj/machinery/computer/telecomms/monitor
	name = "telecommunications monitoring console"
	icon_screen = "comm_monitor"
	desc = "Monitors the details of the telecommunications network it's synced with."
	circuit = /obj/item/circuitboard/computer/comm_monitor
	network_id = __NETWORK_SERVER // if its connected to the default one we will ignore it
	var/network = "NULL"		// the network to probe
	var/list/servers = list()	// the servers in the network
	var/hardware_id = ""
	var/history_size = 20


/obj/machinery/computer/telecomms/monitor/Initialize(mapload)
	. = ..()
	update_network()
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, PROC_REF(ntnet_receive))
	hardware_id = GetComponent(/datum/component/ntnet_interface).hardware_id

/obj/machinery/computer/telecomms/monitor/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE)


/obj/machinery/computer/telecomms/monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Telemonitor")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/telecomms/monitor/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "change_network")
		network = params["network_name"]
		update_network()
		return TRUE
	if(action == "delete_server")
		servers -= params["server_id"]

/obj/machinery/computer/telecomms/monitor/ui_data(mob/user)
	var/list/data = list()
	data["network_id"] = network
	data["current_time"] = world.time
	data["servers"] = get_server_data()

	return data

/obj/machinery/computer/telecomms/monitor/process()
	get_server_status()

/obj/machinery/computer/telecomms/monitor/proc/get_server_status()
	if(network_id == __NETWORK_SERVER)
		return
	var/data = list()
	data["type"] = PACKET_TYPE_PING
	ntnet_send(data, network_id)

/obj/machinery/computer/telecomms/monitor/proc/ntnet_receive(datum/source, datum/netdata/data)
	if(data.data["type"] != PACKET_TYPE_THERMALDATA)
		return // we only want thermal data
	if(!servers[data.sender_id])
		servers[data.sender_id] = new/datum/telecomm_server_data(data.data["name"], data.sender_id, data.data["overheat_temperature"])
	var/datum/telecomm_server_data/server = servers[data.sender_id]
	server.update_temperature(data.data["temperature"], data.data["efficiency"])

/obj/machinery/computer/telecomms/monitor/proc/update_network()
	servers = list()
	if(!network || network == "NULL")
		return
	var/new_network_id = NETWORK_NAME_COMBINE(__NETWORK_SERVER, network) // should result in something like SERVER.TCOMMSAT
	var/area/A = get_area(src)
	if(A)
		if(!A.network_root_id)
			log_telecomms("Area '[A.name]([REF(A)])' has no network network_root_id, force assigning in object [src]([REF(src)])")
			SSnetworks.lookup_area_root_id(A)
		new_network_id = NETWORK_NAME_COMBINE(A.network_root_id, new_network_id) // should result in something like SS13.SERVER.TCOMMSAT
	new_network_id = simple_network_name_fix(new_network_id) // make sure the network name is valid
	var/datum/ntnet/new_network = SSnetworks.create_network_simple(new_network_id)
	new_network.move_interface(GetComponent(/datum/component/ntnet_interface), new_network_id, network_id)
	network_id = new_network_id

/obj/machinery/computer/telecomms/monitor/proc/get_server_data()
	var/list/data = list()
	for(var/server_id in servers)
		var/datum/telecomm_server_data/server = servers[server_id]
		data[server_id] = server.get_tgui_data()
	return data

/datum/telecomm_server_data
	var/name = ""
	var/sender_id
	var/list/temperature_history
	var/overheat_temperature
	var/efficiency
	var/last_update
	var/overheated

	var/history_size = 40

/datum/telecomm_server_data/New(name, sender_id, overheat_temperature)
	. = ..()
	src.name = name
	src.sender_id = sender_id
	src.overheat_temperature = overheat_temperature
	temperature_history = list()
	for(var/i = 1 to history_size)
		temperature_history += 0

/datum/telecomm_server_data/proc/update_temperature(temperature, new_efficiency)
	temperature_history.Cut(1,2) // remove the oldest data
	temperature_history += temperature
	efficiency = new_efficiency
	last_update = world.time

/datum/telecomm_server_data/proc/get_tgui_data()
	var/list/data = list()
	data["name"] = name
	data["sender_id"] = sender_id
	data["temperatures"] = temperature_history
	data["overheat_temperature"] = overheat_temperature
	data["efficiency"] = efficiency
	data["last_update"] = last_update
	data["overheated"] = overheated

	return data

/mob/verb/cleanse()
	set name = "CLEANSE"

	for(var/A in GLOB.the_station_areas)
		var/area/area = GLOB.areas_by_type[A] // i hate you Kat
		area.set_dynamic_lighting(DYNAMIC_LIGHTING_DISABLED)

/mob/verb/defile() // restore
	set name = "DEFILE"

	for(var/A in GLOB.the_station_areas)
		var/area/area = GLOB.areas_by_type[A] // i hate you Kat
		area.set_dynamic_lighting(initial(area.dynamic_lighting))

