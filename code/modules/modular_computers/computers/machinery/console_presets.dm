/obj/item/modular_computer/console/preset
	// Can be changed to give devices specific hardware
	var/spawn_card_slot = FALSE
	var/spawn_second_id_slot = FALSE
	var/spawn_printer = FALSE
	var/spawn_battery = FALSE
	var/spawn_ai_slot = FALSE
	var/spawn_network_card = TRUE	// We want this to be a little evil, a little mischevious a little rapscallion.

/obj/item/modular_computer/console/preset/Initialize(mapload)
	. = ..()

	install_component(new /obj/item/computer_hardware/recharger/APC)
	install_component(new /obj/item/computer_hardware/processor_unit)
	install_component(new /obj/item/computer_hardware/hard_drive/super) // Consoles generally have better HDDs due to lower space limitations

	if(spawn_network_card)
		var/obj/item/computer_hardware/network_card/wired/network_card = new()
		install_component(network_card)
		if(console_department)
			network_card.identification_string = ("[console_department]_console")
		else
			network_card.identification_string = "unknown_console"
	if(spawn_card_slot)
		install_component(new /obj/item/computer_hardware/card_slot)
	if(spawn_second_id_slot)
		install_component(new /obj/item/computer_hardware/card_slot/secondary)
	if(spawn_printer)
		install_component(new /obj/item/computer_hardware/printer)
	if(spawn_battery)
		install_component(new /obj/item/computer_hardware/battery(/obj/item/stock_parts/cell/computer/super))
	if(spawn_ai_slot)
		install_component(new /obj/item/computer_hardware/ai_slot)
	install_programs()
	update_appearance()

// Override in child types to install preset-specific programs.
/obj/item/modular_computer/console/preset/proc/install_programs()	//Consoles should use disk jobs, they gotta be THIEVERISH-able
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	if(!hard_drive)
		return
	hard_drive.store_file(new/datum/computer_file/program/chatclient())	// We're giving all of them this silly old thing, see if people use it or not

// ===== ENGINEERING CONSOLE =====
/obj/item/modular_computer/console/preset/engineering
	console_department = "eng"
	name = "engineering console"
	desc = "A stationary computer built to keep tabs on the station's overall integrity"
	default_disk = /obj/item/computer_hardware/hard_drive/role/engineering

// ===== RESEARCH CONSOLE =====
/obj/item/modular_computer/console/preset/research
	console_department = "sci"
	name = "research console"
	desc = "A stationary computer built for AI restauration and log viewing."
	spawn_ai_slot = TRUE
	default_disk = /obj/item/computer_hardware/hard_drive/role/sci_console

// ===== COMMAND CONSOLE =====
/obj/item/modular_computer/console/preset/command
	console_department = "com"
	name = "command console"
	desc = "A stationary computer. This one comes preloaded with command programs."
	spawn_card_slot = TRUE
	spawn_second_id_slot = TRUE
	spawn_printer = TRUE
	default_disk = /obj/item/computer_hardware/hard_drive/role/hop_console

// ===== CIVILIAN CONSOLE =====
/obj/item/modular_computer/console/preset/civilian
	console_department = "pub"
	name = "public console"
	desc = "A stationary computer for public use."
	spawn_card_slot = TRUE

// curator
/obj/item/modular_computer/console/preset/curator
	console_department = "lib"
	name = "curator console"
	desc = "A stationary library computer built to handle curator related affairs."
	spawn_printer = TRUE
	default_disk = /obj/item/computer_hardware/hard_drive/role/curator
