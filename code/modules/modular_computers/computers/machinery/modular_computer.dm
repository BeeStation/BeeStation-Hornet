// Modular Computer - device that runs various programs and operates with hardware
// DO NOT SPAWN THIS TYPE. Use /laptop/ or /console/ instead.
/obj/machinery/modular_computer
	name = "modular computer"
	desc = "An advanced computer."

	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	var/hardware_flag = 0								// A flag that describes this device type
	var/last_power_usage = 0							// Power usage during last tick

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	icon = null
	icon_state = null
	var/icon_state_unpowered = null						// Icon state when the computer is turned off.
	var/icon_state_powered = null						// Icon state when the computer is turned on.
	var/screen_icon_state_menu = "menu"					// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/screen_icon_screensaver = "standby"				// Icon state overlay when the computer is powered, but not 'switched on'.
	var/max_hardware_size = 0							// Maximal hardware size. Currently, tablets have 1, laptops 2 and consoles 3. Limits what hardware types can be installed.
	var/max_bays = 8									// Maximum
	var/steel_sheet_cost = 10							// Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/light_strength = 0								// Light luminosity when turned on
	var/base_active_power_usage = 100					// Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_idle_power_usage = 10						// Power usage when the computer is idle and screen is off (currently only applies to laptops)

	/// The main backbone that handles most ModPC logic while this type only handles power and other specific things.
	var/obj/item/mainboard/mainboard = null
	/// A list of hardware components we want to add by ComponentInitialize()
	var/list/obj/item/computer_hardware/install_components = null

// /obj/machinery/modular_computer/Initialize(mapload)
// 	mainboard = new(src)
// 	mainboard.physical_holder = src
// 	mainboard.max_hardware_w_class = max_hardware_size
// 	mainboard.max_bays = max_bays
// 	. = ..()

/obj/machinery/modular_computer/ComponentInitialize()
	SHOULD_CALL_PARENT(TRUE)

	. = ..()
	AddComponent(/datum/component/modular_computer_integration, null, TRUE, CALLBACK(src, PROC_REF(install_modpc_hardware)), CALLBACK(src, PROC_REF(install_modpc_software)), max_hardware_size, max_bays)

/obj/machinery/modular_computer/proc/install_modpc_hardware(obj/item/mainboard/MB)
	SHOULD_CALL_PARENT(TRUE) // should always prevent forgetting hardware unless we explicity require it

	for(var/T in install_components)
		MB.install_component(new T)

/obj/machinery/modular_computer/proc/install_modpc_software(obj/item/computer_hardware/hard_drive/hard_drive)
	SHOULD_CALL_PARENT(TRUE) // should always prevent missing software
	return

// /obj/machinery/modular_computer/Destroy()
// 	. = ..()

// /obj/machinery/modular_computer/examine(mob/user)
// 	. = ..()
// 	if(istype(mainboard))
// 		. += mainboard.internal_parts_examine()

// /obj/machinery/modular_computer/attack_ghost(mob/dead/observer/user)
// 	. = ..()
// 	if(.)
// 		return
// 	if(mainboard)
// 		mainboard.attack_ghost(user)

// /obj/machinery/modular_computer/should_emag(mob/user)
// 	if(isnull(mainboard))
// 		to_chat(user, "<span class='warning'>You swipe your card, but nothing seems to happen.</span>")
// 		return FALSE
// 	return mainboard.should_emag(user)

// /obj/machinery/modular_computer/on_emag(mob/user)
// 	..()
// 	return mainboard.on_emag(user)

/obj/machinery/modular_computer/update_icon_state()
	. = ..()
	if(!istype(mainboard) || !mainboard.enabled || !mainboard.use_power())
		icon_state = icon_state_unpowered
		return

	icon_state = icon_state_powered

/obj/machinery/modular_computer/update_overlays()
	. = ..()

	if(!istype(mainboard) || !mainboard.enabled)
		return

	if (!(machine_stat & NOPOWER) && (mainboard && mainboard.use_power()))
		. += screen_icon_screensaver

	if(isnull(mainboard.active_program) || isnull(mainboard.active_program.program_icon_state))
		. += screen_icon_state_menu
		return

	. += mainboard.active_program.program_icon_state

// Used in following function to reduce copypaste
/obj/machinery/modular_computer/proc/power_failure(malfunction = 0)
	var/obj/item/computer_hardware/battery/battery_module = mainboard?.all_components[MC_CELL]
	if(mainboard?.enabled) // Shut down the computer
		visible_message("<span class='danger'>\The [src]'s screen flickers [battery_module ? "\"BATTERY [malfunction ? "MALFUNCTION" : "CRITICAL"]\"" : "\"EXTERNAL POWER LOSS\""] warning as it shuts down unexpectedly.</span>")
		if(istype(mainboard))
			mainboard.turn_off()
	set_machine_stat(machine_stat | NOPOWER)
	update_icon()

// Modular computers can have battery in them, we handle power in previous proc, so prevent this from messing it up for us.
/obj/machinery/modular_computer/power_change()
	if(istype(mainboard) && mainboard.use_power()) // If MC_CPU still has a power source, PC wouldn't go offline.
		set_machine_stat(machine_stat & ~NOPOWER)
		update_icon()
		return
	. = ..()



// Stronger explosions cause serious damage to internal components
// Minor explosions are mostly mitigitated by casing.
// /obj/machinery/modular_computer/ex_act(severity)
// 	if(istype(mainboard))
// 		switch(severity)
// 			if(EXPLODE_DEVASTATE)
// 				SSexplosions.high_mov_atom += mainboard
// 			if(EXPLODE_HEAVY)
// 				SSexplosions.med_mov_atom += mainboard
// 			if(EXPLODE_LIGHT)
// 				SSexplosions.low_mov_atom += mainboard
// 	..()

// EMPs are similar to explosions, but don't cause physical damage to the casing. Instead they screw up the components
// /obj/machinery/modular_computer/emp_act(severity)
// 	. = ..()
// 	if(. & EMP_PROTECT_CONTENTS)
// 		return
// 	if(istype(mainboard))
// 		mainboard.emp_act(severity)

// "Stun" weapons can cause minor damage to components (short-circuits?)
// "Burn" damage is equally strong against internal components and exterior casing
// "Brute" damage mostly damages the casing.
// /obj/machinery/modular_computer/bullet_act(obj/projectile/Proj)
// 	if(istype(mainboard))
// 		mainboard.bullet_act(Proj)
