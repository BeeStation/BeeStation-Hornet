/obj/item/computer_hardware/recharger
	critical = 1
	enabled = 1
	var/charge_rate = 100
	device_type = MC_CHARGE

/obj/item/computer_hardware/recharger/proc/use_power(amount, charging=0)
	if(charging)
		return 1
	return 0

/obj/item/computer_hardware/recharger/process()
	..()
	var/obj/item/computer_hardware/battery/battery_module = holder.all_components[MC_CELL]
	if(!holder || !battery_module || !battery_module.battery)
		return

	var/obj/item/stock_parts/cell/cell = battery_module.battery
	if(cell.charge >= cell.maxcharge)
		return

	if(use_power(charge_rate, charging=1))
		holder.give_power(charge_rate * GLOB.CELLRATE)


/obj/item/computer_hardware/recharger/APC
	name = "area power connector"
	desc = "A device that wirelessly recharges connected device from nearby APC."
	icon_state = "charger_APC"
	w_class = WEIGHT_CLASS_SMALL // Can't be installed into tablets/PDAs

/obj/item/computer_hardware/recharger/APC/use_power(amount, charging=0)
	var/obj/machinery/modular_computer/physical_holder = holder.physical_holder
	if(istype(physical_holder))
		if(physical_holder.powered())
			physical_holder.use_power(amount)
			return 1
	else if (istype(holder.physical_holder))
		var/atom/movable/AM = holder.physical_holder
		var/area/A = get_area(AM)
		if(!istype(A))
			return 0

		if(A.powered(AREA_USAGE_EQUIP))
			A.use_power(amount, AREA_USAGE_EQUIP)
			return 1
	return 0

/obj/item/computer_hardware/recharger/wired
	name = "wired power connector"
	desc = "A power connector that recharges connected device from nearby power wire. Incompatible with portable computers."
	icon_state = "charger_wire"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/computer_hardware/recharger/wired/can_install_component(atom/movable/install_into, mob/living/user = null)
	var/obj/machinery/modular_computer/physical_holder = install_into
	if(istype(physical_holder) && physical_holder.anchored)
		return ..()
	if(user)
		to_chat(user, "<span class='warning'>\The [src] can only be installed in modular computers!</span>")
	return FALSE

/obj/item/computer_hardware/recharger/wired/use_power(amount, charging=0)
	var/obj/machinery/modular_computer/physical_holder = holder.physical_holder
	if(!istype(physical_holder) || !physical_holder.anchored)
		return FALSE

	var/turf/T = physical_holder.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node()
	if(!C || !C.powernet)
		return FALSE

	var/power_in_net = C.powernet.avail - C.powernet.load

	if(power_in_net && power_in_net > amount)
		C.powernet.load += amount
		return TRUE

	return FALSE

/// This recharger exists only in borg built-in tablets. I would have tied it to the borg's cell but
/// the program that displays laws should always be usable, and the exceptions were starting to pile.
/obj/item/computer_hardware/recharger/silicon
	name = "modular interface power harness"

/obj/item/computer_hardware/recharger/silicon/use_power(amount, charging=0)
	return TRUE

/obj/item/computer_hardware/recharger/silicon/ai
	desc = "A standard connection to power a small computer device from an AI's chassis."

/obj/item/computer_hardware/recharger/silicon/cyborg
	desc = "A standard connection to power a small computer device from a cyborg's chassis."

/obj/item/computer_hardware/recharger/silicon/pai
	desc = "A standard connection to power a small computer device from a personal AI's chassis."

// This is not intended to be obtainable in-game. Intended for adminbus and debugging purposes.
/obj/item/computer_hardware/recharger/lambda
	name = "lambda coil"
	desc = "A very complex device that draws power from its own bluespace dimension."
	icon_state = "charger_lambda"
	w_class = WEIGHT_CLASS_TINY
	charge_rate = 100000

/obj/item/computer_hardware/recharger/lambda/use_power(amount, charging=0)
	return 1

