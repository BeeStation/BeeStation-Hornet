/obj/item/modular_computer/laptop/preset

/obj/item/modular_computer/laptop/preset/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive)
	install_component(new /obj/item/computer_hardware/network_card)

/obj/item/modular_computer/laptop/preset/civillian
	desc = "A low-end laptop often used for personal recreation."

/obj/item/modular_computer/laptop/preset/civillian/install_programs(obj/item/computer_hardware/hard_drive/hard_drive)
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
