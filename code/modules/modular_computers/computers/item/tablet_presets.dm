
// This is literally the worst possible cheap tablet
/obj/item/modular_computer/tablet/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."
	install_components = list(
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/hard_drive/small,
		/obj/item/computer_hardware/network_card
	)
	install_cell = /obj/item/stock_parts/cell/computer/micro

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/preset/advanced
	install_components = list(
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/hard_drive/small,
		/obj/item/computer_hardware/network_card,
		/obj/item/computer_hardware/id_slot,
		/obj/item/computer_hardware/printer/mini
	)

/obj/item/modular_computer/tablet/preset/advanced/command
	install_components = list(
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/hard_drive/small,
		/obj/item/computer_hardware/network_card,
		/obj/item/computer_hardware/id_slot,
		/obj/item/computer_hardware/printer/mini,
		/obj/item/computer_hardware/sensorpackage,
		/obj/item/computer_hardware/id_slot/secondary
	)

/obj/item/modular_computer/tablet/preset/advanced/command/install_modpc_software(obj/item/computer_hardware/hard_drive/hard_drive)
	. = ..()
	hard_drive.store_file(new /datum/computer_file/program/budgetorders)

/obj/item/modular_computer/tablet/preset/science
	install_components = list(
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/hard_drive/small,
		/obj/item/computer_hardware/id_slot,
		/obj/item/computer_hardware/network_card,
		/obj/item/computer_hardware/radio_card
	)

/obj/item/modular_computer/tablet/preset/science/install_modpc_software(obj/item/computer_hardware/hard_drive/hard_drive)
	. = ..()
	hard_drive.store_file(new /datum/computer_file/program/signaller)

/obj/item/modular_computer/tablet/preset/cargo
	install_components = list(
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/hard_drive/small,
		/obj/item/computer_hardware/id_slot,
		/obj/item/computer_hardware/network_card,
		/obj/item/computer_hardware/printer/mini
	)

/obj/item/modular_computer/tablet/preset/cargo/install_modpc_software(obj/item/computer_hardware/hard_drive/hard_drive)
	. = ..()
	hard_drive.store_file(new /datum/computer_file/program/bounty)

/obj/item/modular_computer/tablet/preset/advanced/atmos/install_modpc_hardware(obj/item/mainboard/MB)
	. = ..()
	MB.install_component(new /obj/item/computer_hardware/sensorpackage)

/obj/item/modular_computer/tablet/preset/advanced/custodial/install_modpc_software(obj/item/computer_hardware/hard_drive/hard_drive)
	. = ..()
	hard_drive.store_file(new /datum/computer_file/program/radar/custodial_locator)

/// Given by the syndicate as part of the contract uplink bundle - loads in the Contractor Uplink.
/obj/item/modular_computer/tablet/syndicate_contract_uplink/preset/uplink
	install_components = list(
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/network_card,
		/obj/item/computer_hardware/id_slot,
		/obj/item/computer_hardware/printer/mini
	)

/obj/item/modular_computer/tablet/syndicate_contract_uplink/preset/uplink/install_modpc_hardware(obj/item/mainboard/MB)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = new
	var/datum/computer_file/program/contract_uplink/uplink = new

	MB.active_program = uplink
	uplink.program_state = PROGRAM_STATE_ACTIVE
	uplink.computer = src

	hard_drive.store_file(uplink)

	MB.install_component(hard_drive)

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	install_components = list(
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/hard_drive/small/nukeops,
		/obj/item/computer_hardware/network_card
	)
