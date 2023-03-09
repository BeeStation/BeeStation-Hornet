/**
 * # NTNet Receiver Component
 *
 * Receives data through NTNet.
 */
/obj/item/circuit_component/ntnet_receive
	display_name = "NTNet Receiver"
	desc = "Receives data packages through NTNet. If Encryption Key is set then only signals with the same Encryption Key will be received."

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL //trigger_output

	/// The list type
	var/datum/port/input/option/list_options

	/// Data being received
	var/datum/port/output/data_package

	/// Encryption key
	var/datum/port/input/enc_key

	network_id = __NETWORK_CIRCUITS

/obj/item/circuit_component/ntnet_receive/Initialize(mapload)
	. = ..()

/obj/item/circuit_component/ntnet_receive/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/ntnet_receive/populate_ports()
	data_package = add_output_port("Data Package", PORT_TYPE_LIST(PORT_TYPE_ANY))
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, PROC_REF(ntnet_receive))

/obj/item/circuit_component/ntnet_receive/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		data_package.set_datatype(PORT_TYPE_LIST(new_datatype))


/obj/item/circuit_component/ntnet_receive/proc/ntnet_receive(datum/source, datum/netdata/data)
	SIGNAL_HANDLER

	if(data.data["enc_key"] != enc_key.value)
		return

	var/datum/weakref/ref = data.data["port"]
	var/datum/port/input/port = ref?.resolve()
	if(!port)
		return

	var/datum/circuit_datatype/datatype_handler = data_package.datatype_handler
	if(!datatype_handler?.can_receive_from_datatype(port.datatype))
		return

	data_package.set_output(data.data["data"])
	trigger_output.set_output(COMPONENT_SIGNAL)
