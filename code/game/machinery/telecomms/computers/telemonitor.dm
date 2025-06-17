
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


/obj/machinery/computer/telecomms/monitor/Initialize(mapload)
	. = ..()
	update_network()
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, PROC_REF(ntnet_receive))

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
	data["servers"] = servers

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
	servers[data.sender_id] = data.data
	servers[data.sender_id]["last_update"] = world.time
	servers[data.sender_id]["sender_id"] = data.sender_id

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
		else
			log_telecomms("Created [src]([REF(src)] in nullspace, assuming network to be in station")
			new_network_id = NETWORK_NAME_COMBINE(STATION_NETWORK_ROOT, new_network_id) // should result in something like SS13.SERVER.TCOMMSAT
	new_network_id = simple_network_name_fix(new_network_id) // make sure the network name is valid
	var/datum/ntnet/new_network = SSnetworks.create_network_simple(new_network_id)
	new_network.move_interface(GetComponent(/datum/component/ntnet_interface), new_network_id, network_id)
	network_id = new_network_id
