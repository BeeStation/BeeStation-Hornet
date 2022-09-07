/datum/orbital_comms_manager/station

/datum/orbital_comms_manager/station/handle_message(datum/orbital_comms_manager/source, message, emergency = FALSE)
	. = ..()
	//Send message to command channels
	var/reciever_relay = null

	for(var/obj/machinery/computer/communications/reciever in GLOB.machines)
		if (is_station_level(reciever.z))
			reciever_relay = reciever
			break

	if(!reciever_relay)
		return

	// Determine the identity information which will be attached to the signal.
	var/atom/movable/virtualspeaker/speaker = new(null, reciever_relay, null)

	// Construct the signal
	var/datum/signal/subspace/vocal/signal = new(
		reciever_relay,
		FREQ_COMMAND,
		speaker,
		/datum/language/common,
		"Incomming hyperspace communication from [source.messenger_name], '[message]'.",
		list(),
		list())

	// All radios make an attempt to use the subspace system first
	signal.send_to_receivers()

/datum/orbital_comms_manager/station/handle_emergency_message(datum/orbital_comms_manager/source, message)
	. = ..()
	//Send an announcement
	priority_announce(message, "Emergency Communication Recieved", sender_override = source.messenger_name)
