// CPU that allows the computer to run programs.
// Better CPUs are obtainable via research and can run more programs on background.

/obj/item/computer_hardware/processor_unit
	name = "processor board"
	desc = "A standard CPU board used in most computers. It can run up to three programs simultaneously."
	icon_state = "cpuboard"
	w_class = WEIGHT_CLASS_SMALL
	power_usage = 5 // Watts per second
	critical = 1
	malfunction_probability = 1
	var/max_idle_programs = 2 // 2 idle, + 1 active = 3 as said in description.
	device_type = MC_CPU
	custom_price = PAYCHECK_MEDIUM * 2

/obj/item/computer_hardware/processor_unit/update_overclocking(mob/living/user, obj/item/tool)
	if(hacked)
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // Processing Power Overload // <font color='#ffffff'>Spatial Stability Compromized</font>")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // Processing Power Overload // <span class='cfc_negative'>Spatial Stability Compromized</span>")
	else
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // Values Nominal // <font color='#00d41c'>Stability Regained</font>")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // Values Nominal // <span class='cfc_green'>Stability Regained</span>")

/obj/item/computer_hardware/processor_unit/on_remove(obj/item/modular_computer/remove_from, mob/user)
	remove_from.shutdown_computer()

/obj/item/computer_hardware/processor_unit/small
	name = "microprocessor"
	desc = "A miniaturised CPU used in portable devices. It can run up to two programs simultaneously."
	icon_state = "cpu"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 3 // Watts per second
	max_idle_programs = 1
	custom_price = PAYCHECK_EASY * 2

/obj/item/computer_hardware/processor_unit/photonic
	name = "photonic processor board"
	desc = "An advanced experimental CPU board that uses photonic core instead of regular circuitry. It can run up to five programs simultaneously, but uses a lot of power."
	icon_state = "cpuboard_super"
	w_class = WEIGHT_CLASS_SMALL
	power_usage = 10 // Watts per second
	max_idle_programs = 4
	custom_price = PAYCHECK_MEDIUM * 4

/obj/item/computer_hardware/processor_unit/photonic/small
	name = "photonic microprocessor"
	desc = "An advanced miniaturised CPU for use in portable devices. It uses photonic core instead of regular circuitry. It can run up to three programs simultaneously."
	icon_state = "cpu_super"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 7.5 // Watts per second
	max_idle_programs = 2
	custom_price = PAYCHECK_MEDIUM * 3
