/*
	Local comms machine for ships, acts similar to the all-in-one machine.
*/

/obj/machinery/telecomms/ship
	name = "local telecommunications mainframe"
	icon_state = "comm_server"
	desc = "A compact machine used for localized subspace telecommunications processing. A multitool can relink it to the current ship, hitting it with a radio will link that radio."
	density = TRUE
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 500
	active_power_usage = 1000
	emp_disable_time = 30 SECONDS
	var/ship_port
	var/faction

/obj/machinery/telecomms/ship/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(istype(A, /area/shuttle))
		var/area/shuttle/AS = A
		ship_port = AS.mobile_port.id

/obj/machinery/telecomms/ship/receive_signal(datum/signal/subspace/signal)
	// REquires power
	if (!powered())
		return
	if(!istype(signal) || signal.transmission_method != TRANSMISSION_SHIP)  //receives ship messages only
		return
	if(!on || !is_freq_listening(signal))  // has to be on to receive messages
		return
	// Check if we can grab a faction
	if (!faction && ship_port)
		var/datum/shuttle_data/data = SSorbits.get_shuttle_data(ship_port)
		faction = data?.faction.name
	// If this is a global faction message, create a local signal and broadcast it out
	if (signal.frequency == FREQ_FACTION && signal.ship_port && signal.ship_port == faction)
		// Transmit a local signal
		var/datum/signal/subspace/copied = signal.copy()
		if (!ship_port)
			// Switch to this so that it can reach everyone on the level, even if they have no ship
			copied.transmission_method = TRANSMISSION_SUBSPACE
		copied.levels = list(get_virtual_z_level())
		copied.data["compression"] = 0
		// Clean out spans
		copied.data["spans"] = list()
		copied.mark_done()
		copied.broadcast()
		return
	if (signal.data["dont_relay"])
		return
	if (!((get_virtual_z_level() in signal.levels) && !(0 in signal.levels) && signal.ship_port == ship_port))  // has to be on the ship and the right level
		return
	// Determine if we need to relay this signal
	if (signal.frequency == FREQ_FACTION)
		// Transmit a local signal
		var/datum/signal/subspace/faction_signal = signal.copy()
		faction_signal.ship_port = faction
		faction_signal.transmission_method = TRANSMISSION_SHIP
		faction_signal.data["dont_relay"] = TRUE
		faction_signal.send_to_receivers()
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
			ship_port = AS.mobile_port.id
			var/datum/shuttle_data/data = SSorbits.get_shuttle_data(ship_port)
			faction = data.faction.name
			to_chat(user, "<span class='notice'>You like [src] to [AS.mobile_port.name].</span>")
	else if(istype(P, /obj/item/radio))
		var/obj/item/radio/R = P
		R.ship_port = ship_port
		to_chat(user, "<span class='notice'>You like [P] to [src].</span>")
	else ..()
