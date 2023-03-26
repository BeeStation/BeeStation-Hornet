/*
	Local comms machine for ships, acts similar to the all-in-one machine.
*/

/obj/machinery/telecomms/ship
	name = "local telecommunications mainframe"
	icon_state = "comm_server"
	desc = "A compact machine used for localized subspace telecommunications processing."
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	var/obj/docking_port/ship

/obj/machinery/telecomms/ship/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(istype(A, /area/shuttle))
		var/area/shuttle/AS = A
		ship = AS.mobile_port

/obj/machinery/telecomms/ship/receive_signal(datum/signal/subspace/signal)
	if(!istype(signal) || signal.transmission_method != TRANSMISSION_SHIP)  //receives ship messages only
		return
	if(!on || !is_freq_listening(signal))  // has to be on to receive messages
		return
	if (!(get_virtual_z_level() in signal.levels) && !(0 in signal.levels) && signal.ship == ship)  // has to be on the ship and the right level
		return

	// Same as the all in one machine
	signal.data["compression"] = 0
	signal.mark_done()
	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"]) // simulate the network lag if necessary
	signal.broadcast()

/obj/machinery/telecomms/ship/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_MULTITOOL) //Using the multitool to link the ship, in case something messed it up
		var/area/A = get_area(src)
		if(istype(A, /area/shuttle))
			var/area/shuttle/AS = A
			ship = AS.mobile_port
	else if(istype(P, /obj/item/radio))
		var/obj/item/radio/R = P
		R.ship = ship
	else ..()
