/obj/item/modular_computer/laptop/preset/Initialize(mapload)
	. = ..()
	mainboard.install_component(new /obj/item/computer_hardware/processor_unit/small)
	mainboard.install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	mainboard.install_component(new /obj/item/computer_hardware/hard_drive)
	mainboard.install_component(new /obj/item/computer_hardware/network_card)
	install_programs(mainboard.all_components[MC_HDD])

/obj/item/modular_computer/laptop/preset/proc/install_programs(obj/item/computer_hardware/hard_drive/hard_drive)
	return

/obj/item/modular_computer/laptop/preset/civillian
	desc = "A low-end laptop often used for personal recreation."

/obj/item/modular_computer/laptop/preset/civillian/install_programs(obj/item/computer_hardware/hard_drive/hard_drive)
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
