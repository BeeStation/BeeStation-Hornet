///////////////////////////////////
/////Subspace Telecomms////////////
///////////////////////////////////

/datum/design/board/subspace_receiver
	name = "Machine Design (Subspace Receiver)"
	desc = "Allows for the construction of Subspace Receiver equipment."
	id = "s-receiver"
	build_path = /obj/item/circuitboard/machine/telecomms/receiver
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/telecomms_bus
	name = "Machine Design (Bus Mainframe)"
	desc = "Allows for the construction of Telecommunications Bus Mainframes."
	id = "s-bus"
	build_path = /obj/item/circuitboard/machine/telecomms/bus
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/telecomms_hub
	name = "Machine Design (Hub Mainframe)"
	desc = "Allows for the construction of Telecommunications Hub Mainframes."
	id = "s-hub"
	build_path = /obj/item/circuitboard/machine/telecomms/hub
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/telecomms_relay
	name = "Machine Design (Relay Mainframe)"
	desc = "Allows for the construction of Telecommunications Relay Mainframes."
	id = "s-relay"
	build_path = /obj/item/circuitboard/machine/telecomms/relay
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/telecomms_processor
	name = "Machine Design (Processor Unit)"
	desc = "Allows for the construction of Telecommunications Processor equipment."
	id = "s-processor"
	build_path = /obj/item/circuitboard/machine/telecomms/processor
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/telecomms_server
	name = "Machine Design (Server Mainframe)"
	desc = "Allows for the construction of Telecommunications Servers."
	id = "s-server"
	build_path = /obj/item/circuitboard/machine/telecomms/server
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/telecomms_messaging
	name = "Machine Design (Messaging Server)"
	desc = "Allows for the construction of Telecommunications Messaging Servers."
	id = "s-messaging"
	build_path = /obj/item/circuitboard/machine/telecomms/message_server
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/subspace_broadcaster
	name = "Machine Design (Subspace Broadcaster)"
	desc = "Allows for the construction of Subspace Broadcasting equipment."
	id = "s-broadcaster"
	build_path = /obj/item/circuitboard/machine/telecomms/broadcaster
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/exploration_key
	name = "Exploration Encryption Key"
	desc = "A highly sensitive encryption key, capable of recieving and decrypting signals from different bluespace planes."
	id = "exploration_key"
	build_path = /obj/item/encryptionkey/headset_exp
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/copper = 1000, /datum/material/bluespace = 250)
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
