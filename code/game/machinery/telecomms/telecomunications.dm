
/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The telecom machines were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

GLOBAL_LIST_EMPTY(telecomms_list)

/obj/machinery/telecomms
	icon = 'icons/obj/machines/telecomms.dmi'
	critical_machine = TRUE
	light_color = LIGHT_COLOR_CYAN
	network_id = __NETWORK_SERVER
	/// /// list of machines this machine is linked to
	var/list/links = list()
	/**
	 * associative lazylist list of the telecomms_type of linked telecomms machines and a list of said machines.
	 * eg list(telecomms_type1 = list(everything linked to us with that type), telecomms_type2 = list(everything linked to us with THAT type)...)
	 */
	var/list/links_by_telecomms_type
	/// value increases as traffic increases
	var/traffic = 0
	/// how much traffic to lose per second (50 gigabytes/second * netspeed)
	var/netspeed = 2.5
	/// list of text/number values to link with
	var/list/autolinkers = list()
	/// identification string
	var/id = "NULL"
	/// the relevant type path of this telecomms machine eg /obj/machinery/telecomms/server but not server/preset. used for links_by_telecomms_type
	var/telecomms_type = null
	/// the network of the machinery
	var/network = "NULL"

	// list of frequencies to tune into: if none, will listen to all
	var/list/freq_listening = list()

	var/on = TRUE
	/// Is it toggled on
	var/toggled = TRUE
	/// Can you link it across Z levels or on the otherside of the map? (Relay & Hub)
	var/long_range_link = FALSE
	/// Is it a hidden machine?
	var/hide = FALSE

	var/datum/component/server/server_component

/// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending
/obj/machinery/telecomms/proc/relay_information(datum/signal/subspace/signal, filter, copysig, amount = 20)

	if(!on)
		return

	if(!filter || !ispath(filter, /obj/machinery/telecomms))
		CRASH("null or non /obj/machinery/telecomms typepath given as the filter argument! given typepath: [filter]")

	var/send_count = 0
	// Apply some lag based on traffic rates
	var/netlag = round(traffic / 50)
	if(netlag > signal.data["slow"])
		signal.data["slow"] = netlag

	// Aply some lag from throttling
	var/efficiency = get_efficiency()
	var/throttling = (10 - 10 * efficiency)
	signal.data["slow"] += throttling

	// Loop through all linked machines and send the signal or copy.

	for(var/obj/machinery/telecomms/filtered_machine in links_by_telecomms_type?[filter])
		if(!filtered_machine.on)
			continue
		if(amount && send_count >= amount)
			break
		if(get_virtual_z_level() != filtered_machine.loc.get_virtual_z_level() && !long_range_link && !filtered_machine.long_range_link)
			continue

		send_count++
		if(filtered_machine.is_freq_listening(signal))
			filtered_machine.traffic++

		if(copysig)
			filtered_machine.receive_information(signal.copy(), src)
		else
			filtered_machine.receive_information(signal, src)

	if(send_count > 0 && is_freq_listening(signal))
		traffic++
	use_power(active_power_usage)
	return send_count

/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	// send signal directly to a machine
	machine.receive_information(signal, src)

///receive information from linked machinery
/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	return

/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	// return TRUE if found, FALSE if not found
	return signal && (!length(freq_listening) || (signal.frequency in freq_listening))

/obj/machinery/telecomms/Initialize(mapload)
	. = ..()
	server_component = AddComponent(/datum/component/server) // they generate heat
	update_network() // we try to connect to NTnet
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, PROC_REF(ntnet_receive))
	GLOB.telecomms_list += src
	if(mapload && autolinkers.len)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/telecomms/LateInitialize()
	..()
	for(var/obj/machinery/telecomms/telecomms_machine in GLOB.telecomms_list)
		if (long_range_link || IN_GIVEN_RANGE(src, telecomms_machine, 20))
			add_automatic_link(telecomms_machine)

/obj/machinery/telecomms/Destroy()
	UnregisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE)
	server_component = null
	GLOB.telecomms_list -= src
	for(var/obj/machinery/telecomms/comm in GLOB.telecomms_list)
		remove_link(comm)
	links = list()
	return ..()

/obj/machinery/telecomms/proc/get_temperature()
	return server_component.temperature

/obj/machinery/telecomms/proc/get_efficiency()
	return server_component.efficiency

/obj/machinery/telecomms/proc/get_overheat_temperature()
	return server_component.overheated_temp

// Used in auto linking
/obj/machinery/telecomms/proc/add_automatic_link(obj/machinery/telecomms/T)
	var/turf/position = get_turf(src)
	var/turf/T_position = get_turf(T)
	var/same_zlevel = FALSE
	if(position && T_position)	//Stops a bug with a phantom telecommunications interceptor which is spawned by circuits caching their components into nullspace
		if(position.get_virtual_z_level() == T_position.get_virtual_z_level())
			same_zlevel = TRUE
	if(same_zlevel || (long_range_link && T.long_range_link))
		if(src == T)
			return
		for(var/autolinker_id in autolinkers)
			if(autolinker_id in T.autolinkers)
				add_new_link(T)
				return

/obj/machinery/telecomms/proc/update_network()
	var/area/A = get_area(src)
	if(!network || network == "NULL" || !A)
		return
	var/new_network_id = NETWORK_NAME_COMBINE(__NETWORK_SERVER, network) // should result in something like SERVER.TCOMMSAT
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

/obj/machinery/telecomms/proc/ntnet_receive(datum/source, datum/netdata/data)

	//Check radio signal jamming
	if(is_jammed(JAMMER_PROTECTION_WIRELESS) || machine_stat & (BROKEN|NOPOWER|MAINT|EMPED))
		return

	switch(data.data["type"])
		if(PACKET_TYPE_PING) // we respond to the ping with our status
			var/list/send_data = list()
			send_data["type"] = PACKET_TYPE_THERMALDATA
			send_data["name"] = name
			send_data["temperature"] = get_temperature()
			send_data["overheat_temperature"] = get_overheat_temperature()
			send_data["efficiency"] = get_efficiency()
			send_data["overheated"] = (machine_stat & OVERHEATED)

			ntnet_send(send_data, data.sender_id)

/obj/machinery/telecomms/update_icon()
	if(on)
		if(panel_open)
			icon_state = "[initial(icon_state)]_o"
		else
			icon_state = initial(icon_state)
	else
		if(panel_open)
			icon_state = "[initial(icon_state)]_o_off"
		else
			icon_state = "[initial(icon_state)]_off"

/obj/machinery/telecomms/proc/update_power()
	var/newState = on

	if(toggled)
		if(machine_stat & (BROKEN|NOPOWER|EMPED|OVERHEATED)) // if powered, on. if not powered, off. if too damaged, off
			newState = FALSE
		else
			newState = TRUE
	else
		newState = FALSE

	if(newState != on)
		on = newState
		ui_update()
		set_light(on)

/obj/machinery/telecomms/process(delta_time)
	update_power()

	// Update the icon
	update_icon()

	if(traffic > 0)
		traffic -= netspeed * delta_time

/obj/machinery/telecomms/atom_break(damage_flag)
	. = ..()
	update_power()

/obj/machinery/telecomms/power_change()
	..()
	update_power()
