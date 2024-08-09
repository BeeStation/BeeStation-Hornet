/obj/item/modular_computer/laptop/preset
	install_components = list(
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/hard_drive,
		/obj/item/computer_hardware/network_card
	)
	install_cell = /obj/item/stock_parts/cell/computer

/obj/item/modular_computer/laptop/preset/civillian
	desc = "A low-end laptop often used for personal recreation."

/obj/item/modular_computer/laptop/preset/civillian/install_software(obj/item/computer_hardware/hard_drive/hard_drive)
	. = ..()
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
