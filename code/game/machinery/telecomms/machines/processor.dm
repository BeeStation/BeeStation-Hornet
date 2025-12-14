/*
	The processor is a very simple machine that decompresses subspace signals and
	transfers them back to the original bus. It is essential in producing audible
	data.

	Link to servers if bus is not present
*/

/obj/machinery/telecomms/processor
	name = "processor unit"
	icon_state = "processor"
	desc = "This machine is used to process large quantities of information."
	telecomms_type = /obj/machinery/telecomms/processor
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 30
	circuit = /obj/item/circuitboard/machine/telecomms/processor
	var/process_mode = 1 // 1 = Uncompress Signals, 0 = Compress Signals

/obj/machinery/telecomms/processor/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	if(!is_freq_listening(signal))
		return

	if (!process_mode)
		signal.data["compression"] = 100 // even more compressed signal
	else if (signal.data["compression"])
		signal.data["compression"] = 0 // uncompress subspace signal

	if(istype(machine_from, /obj/machinery/telecomms/bus))
		relay_direct_information(signal, machine_from) // send the signal back to the machine
	else // no bus detected - send the signal to servers instead
		signal.data["slow"] += rand(5, 10) // slow the signal down
		relay_information(signal, signal.server_type)

//Preset Processors

/obj/machinery/telecomms/processor/leadership
	id = "Leadership Processor"
	network = "tcommsat"
	autolinkers = list("processor_leadership")

/obj/machinery/telecomms/processor/discovery
	id = "Discovery Processor"
	network = "tcommsat"
	autolinkers = list("processor_discovery")

/obj/machinery/telecomms/processor/support
	id = "Support Processor"
	network = "tcommsat"
	autolinkers = list("processor_support")

/obj/machinery/telecomms/processor/logistics
	id = "Logistics Processor"
	network = "tcommsat"
	autolinkers = list("processor_logstics")
