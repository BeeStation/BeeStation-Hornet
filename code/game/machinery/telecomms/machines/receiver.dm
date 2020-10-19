/*
	The receiver idles and receives messages from subspace-compatible radio equipment;
	primarily headsets. They then just relay this information to all linked devices,
	which can would probably be network hubs.

	Link to Processor Units in case receiver can't send to bus units.
*/

/obj/machinery/telecomms/receiver
	name = "subspace receiver"
	icon_state = "broadcast receiver"
	desc = "This machine has a dish-like shape and green lights. It is designed to detect and process subspace radio activity."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	circuit = /obj/item/circuitboard/machine/telecomms/receiver

/obj/machinery/telecomms/receiver/receive_signal(datum/signal/subspace/signal)
	if(!on || !istype(signal) || !check_receive_level(signal) || signal.transmission_method != TRANSMISSION_SUBSPACE)
		return
	if(!is_freq_listening(signal))
		return

	signal.levels = list()

	// send the signal to the hub if possible, or a bus otherwise
	if(!relay_information(signal, /obj/machinery/telecomms/hub))
		relay_information(signal, /obj/machinery/telecomms/bus)

/obj/machinery/telecomms/receiver/proc/check_receive_level(datum/signal/subspace/signal)
	if (z in signal.levels)
		return TRUE

	for(var/obj/machinery/telecomms/hub/H in links)
		for(var/obj/machinery/telecomms/relay/R in H.links)
			if(R.can_receive(signal) && (R.z in signal.levels))
				return TRUE

	return FALSE

//Preset Receivers

//--PRESET LEFT--//

/obj/machinery/telecomms/receiver/preset_left
	id = "Receiver A"
	network = "tcommsat"
	autolinkers = list("receiverA") // link to relay
	freq_listening = list(FREQ_SCIENCE, FREQ_MEDICAL, FREQ_SUPPLY, FREQ_SERVICE)


//--PRESET RIGHT--//

/obj/machinery/telecomms/receiver/preset_right
	id = "Receiver B"
	network = "tcommsat"
	autolinkers = list("receiverB") // link to relay
	freq_listening = list(FREQ_COMMAND, FREQ_ENGINEERING, FREQ_SECURITY)

	//Common and other radio frequencies for people to freely use
/obj/machinery/telecomms/receiver/preset_right/Initialize()
	. = ..()
	for(var/i = MIN_FREQ, i <= MAX_FREQ, i += 2)
		freq_listening |= i

/obj/machinery/telecomms/receiver/preset_left/birdstation
	name = "Receiver"
	freq_listening = list()

//Code for the interceptor circuit
/obj/machinery/telecomms/receiver/Options_Menu()
	var/dat = "<br>Remote control: <a href='?src=[REF(src)];toggle_remote_control=1'>[GLOB.remote_control ? "<font color='green'><b>ENABLED</b></font>" : "<font color='red'><b>DISABLED</b></font>"]</a>"
	dat += "<br>Broadcasting signals: "
	for(var/i in GLOB.ic_speakers)
		var/obj/item/integrated_circuit/I = i
		var/obj/item/O = I.get_object()
		if(get_area(O)) //if it isn't in nullspace, can happen due to printer newing all possible circuits to fetch list data
			dat += "<br>[O.name] = [O.x], [O.y], [O.z], [get_area(O)]"
	dat += "<br><br>Circuit jammer signals: "
	for(var/i in GLOB.ic_jammers)
		var/obj/item/integrated_circuit/I = i
		var/obj/item/O = I.get_object()
		if(get_area(O)) //if it isn't in nullspace, can happen due to printer newing all possible circuits to fetch list data
			dat += "<br>[O.name] = [O.x], [O.y], [O.z], [get_area(O)]"
	return dat

/obj/machinery/telecomms/receiver/Options_Topic(href, href_list)
	if(href_list["toggle_remote_control"])
		GLOB.remote_control = !GLOB.remote_control

/obj/machinery/telecomms/receiver/receive_signal(datum/signal/signal)
	if(LAZYLEN(GLOB.ic_jammers) && GLOB.remote_control)
		for(var/i in GLOB.ic_jammers)
			var/obj/item/integrated_circuit/input/tcomm_interceptor/T = i
			var/obj/item/O = T.get_object()
			if(is_station_level(O.z)&& (!istype(get_area(O), /area/space)))
				if(!istype(signal.source, /obj/item/radio/headset/integrated))
					signal.data["reject"] = TRUE
					break
	..()

//makeshift receiver used for the circuit, so that we don't
//have to edit radio.dm and other shit
/obj/machinery/telecomms/receiver/circuit
	idle_power_usage = 0
	var/obj/item/integrated_circuit/input/tcomm_interceptor/holder

/obj/machinery/telecomms/receiver/circuit/receive_signal(datum/signal/signal)
	if(!holder.get_pin_data(IC_INPUT, 1))
		return
	if(!signal)
		return
	holder.receive_signal(signal)

// End
