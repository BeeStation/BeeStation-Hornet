
// This is literally the worst possible cheap tablet
/obj/item/modular_computer/tablet/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."

/obj/item/modular_computer/tablet/preset/cheap/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery/small)
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/preset/advanced/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery/standard)
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/preset/advanced/command/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	hard_drive.store_file(new /datum/computer_file/program/budgetorders)
	install_component(new /obj/item/computer_hardware/sensorpackage)
	install_component(new /obj/item/computer_hardware/card_slot/secondary)

/obj/item/modular_computer/tablet/preset/science/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = new
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery/standard)
	install_component(hard_drive)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/radio_card)
	hard_drive.store_file(new /datum/computer_file/program/signaller)

/obj/item/modular_computer/tablet/preset/cargo/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = new
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery/standard)
	install_component(hard_drive)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/printer/mini)
	hard_drive.store_file(new /datum/computer_file/program/bounty)

/obj/item/modular_computer/tablet/preset/advanced/atmos/Initialize(mapload) //This will be defunct and will be replaced when NtOS PDAs are done
	. = ..()
	install_component(new /obj/item/computer_hardware/sensorpackage)

/obj/item/modular_computer/tablet/preset/advanced/custodial/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	hard_drive.store_file(new /datum/computer_file/program/radar/custodial_locator)

/// Given by the syndicate as part of the contract uplink bundle - loads in the Contractor Uplink.
/obj/item/modular_computer/tablet/syndicate_contract_uplink/preset/uplink/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = new
	var/datum/computer_file/program/contract_uplink/uplink = new

	active_program = uplink
	uplink.program_state = PROGRAM_STATE_ACTIVE
	uplink.computer = src

	hard_drive.store_file(uplink)

	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery/standard)
	install_component(hard_drive)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/printer/mini)

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery/standard)
	install_component(new /obj/item/computer_hardware/hard_drive/small/nukeops)
	install_component(new /obj/item/computer_hardware/network_card)

//Borg Built-in tablet
/obj/item/modular_computer/tablet/integrated/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/recharger/cyborg)
	install_component(new /obj/item/computer_hardware/network_card/integrated)
