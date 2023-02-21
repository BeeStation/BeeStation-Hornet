// Held by /obj/machinery/modular_computer to reduce amount of copy-pasted code.
//TODO: REFACTOR THIS SPAGHETTI CODE, MAKE IT A COMPUTER_HARDWARE COMPONENT OR REMOVE IT
/obj/item/modular_computer/processor
	name = "processing unit"
	desc = "You shouldn't see this. If you do, report it."
	icon = null
	icon_state = null
	icon_state_unpowered = null
	icon_state_menu = null
	hardware_flag = 0
	max_bays = 4

	var/obj/machinery/modular_computer/machinery_computer = null

/obj/item/modular_computer/processor/Destroy()
	. = ..()
	if(machinery_computer && (machinery_computer.cpu == src))
		machinery_computer.cpu = null
	machinery_computer = null

/obj/item/modular_computer/processor/New(comp)
	..()
	STOP_PROCESSING(SSobj, src) // Processed by its machine

	if(!comp || !istype(comp, /obj/machinery/modular_computer))
		CRASH("Inapropriate type passed to obj/item/modular_computer/processor/New()! Aborting.")
	// Obtain reference to machinery computer
	all_components = list()
	idle_threads = list()
	machinery_computer = comp
	machinery_computer.cpu = src
	hardware_flag = machinery_computer.hardware_flag
	max_hardware_size = machinery_computer.max_hardware_size
	steel_sheet_cost = machinery_computer.steel_sheet_cost
	obj_integrity = machinery_computer.obj_integrity
	max_integrity = machinery_computer.max_integrity
	integrity_failure = machinery_computer.integrity_failure
	base_active_power_usage = machinery_computer.base_active_power_usage
	base_idle_power_usage = machinery_computer.base_idle_power_usage

/obj/item/modular_computer/processor/relay_qdel()
	qdel(machinery_computer)

/obj/item/modular_computer/processor/update_icon()
	if(machinery_computer)
		return machinery_computer.update_icon()

// This thing is not meant to be used on it's own, get topic data from our machinery owner.
//obj/item/modular_computer/processor/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
//	if(!machinery_computer)
//		return 0

//	return machinery_computer.canUseTopic(user, state)

/obj/item/modular_computer/processor/shutdown_computer()
	if(!machinery_computer)
		return
	..()
	machinery_computer.update_icon()
	return

/obj/item/modular_computer/processor/attack_ghost(mob/user)
	ui_interact(user)

/obj/item/modular_computer/processor/alert_call(datum/computer_file/program/caller, alerttext)
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext)
		return
	var/sound = 'sound/machines/twobeep_high.ogg'
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		sound = pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg')
	playsound(src, sound, 50, TRUE)
	machinery_computer.visible_message("<span class='notice'>The [src] displays a [caller.filedesc] notification: [alerttext]</span>")
