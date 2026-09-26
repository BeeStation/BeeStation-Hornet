/obj/item/modular_computer/laptop/preset/Initialize(mapload)
	. = ..()
	force_install_component(new /obj/item/computer_hardware/processor_unit/small)
	force_install_component(new /obj/item/computer_hardware/battery/standard)
	force_install_component(new /obj/item/computer_hardware/hard_drive)
	force_install_component(new /obj/item/computer_hardware/network_card)

/obj/item/modular_computer/laptop/preset/civillian
	desc = "A low-end laptop often used for personal recreation."

/obj/item/modular_computer/laptop/preset/civillian/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
