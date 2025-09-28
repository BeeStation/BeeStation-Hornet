/obj/machinery/modular_computer/console
	name = "console"
	desc = "A stationary computer."

	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console-0"
	base_icon_state = "console"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIRECTIONAL | SMOOTH_BITMASK_SKIP_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_COMPUTERS)
	canSmoothWith = list(SMOOTH_GROUP_COMPUTERS)
	screen_icon_state_menu = "menu"
	density = TRUE
	base_power_usage = 500
	max_hardware_size = 4
	steel_sheet_cost = 10
	light_strength = 2
	max_integrity = 300
	integrity_failure = 0.5
	var/console_department = "" // Used in New() to set network tag according to our area.

/obj/machinery/modular_computer/console/buildable/Initialize(mapload)
	. = ..()
	// User-built consoles start as empty frames.
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	var/obj/item/computer_hardware/hard_drive/network_card = cpu.all_components[MC_NET]
	var/obj/item/computer_hardware/hard_drive/recharger = cpu.all_components[MC_CHARGER]
	qdel(recharger)
	qdel(network_card)
	qdel(hard_drive)

/obj/machinery/modular_computer/console/Initialize(mapload)
	. = ..()
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	var/obj/item/computer_hardware/battery/battery_module = cpu.all_components[MC_CELL]
	if(battery_module)
		qdel(battery_module)

	var/obj/item/computer_hardware/network_card/wired/network_card = new()

	cpu.install_component(network_card)
	cpu.install_component(new /obj/item/computer_hardware/recharger/APC)
	cpu.install_component(new /obj/item/computer_hardware/hard_drive/super) // Consoles generally have better HDDs due to lower space limitations

	var/area/A = get_area(src)
	// Attempts to set this console's tag according to our area. Since some areas have stuff like "XX - YY" in their names we try to remove that too.
	if(A && console_department)
		network_card.identification_string = replacetext(replacetext(replacetext("[A.name] [console_department] Console", " ", "_"), "-", ""), "__", "_") // Replace spaces with "_"
	else if(A)
		network_card.identification_string = replacetext(replacetext(replacetext("[A.name] Console", " ", "_"), "-", ""), "__", "_")
	else if(console_department)
		network_card.identification_string = replacetext(replacetext(replacetext("[console_department] Console", " ", "_"), "-", ""), "__", "_")
	else
		network_card.identification_string = "Unknown Console"
	if(cpu)
		cpu.screen_on = 1
	update_icon()

/obj/machinery/modular_computer/console/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	. = ..()

/obj/machinery/modular_computer/console/update_icon()
	. = ..()

	var/keyboard = "keyboard"
	if ((machine_stat & NOPOWER) || !(cpu?.use_power()))
		keyboard = "keyboard_off"
	add_overlay(keyboard)

	if(machine_stat & BROKEN)
		add_overlay("broken-[smoothing_junction]")
