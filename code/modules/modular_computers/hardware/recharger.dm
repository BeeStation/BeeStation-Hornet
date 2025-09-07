/obj/item/computer_hardware/recharger
	critical = 1
	enabled = 1
	var/charge_rate = 100
	device_type = MC_CHARGER

/obj/item/computer_hardware/recharger/proc/use_power(amount, charging = 0)
	if(charging)
		return 1
	return 0

/obj/item/computer_hardware/recharger/process()
	..()
	var/obj/item/computer_hardware/battery/battery_module = holder.all_components[MC_CELL]
	if(!holder || !battery_module || !battery_module.battery)
		return

	var/obj/item/stock_parts/cell/computer/cell = battery_module.battery
	if(cell.charge >= cell.maxcharge && !hacked) // If hacked, will continue to absorb power regardless of cell charge
		return
	if(hacked)
		charge_rate = cell.chargerate
		playsound(src, 'sound/items/timer.ogg', 50, FALSE, ignore_walls = TRUE)
	if(use_power(charge_rate, charging = 1))
		holder.give_power(charge_rate)

/obj/item/computer_hardware/recharger/APC
	name = "area power connector"
	desc = "A device that wirelessly recharges connected device from nearby APC."
	icon_state = "charger_APC"
	w_class = WEIGHT_CLASS_SMALL // Can't be installed into PDAs. Tablets are good to go
	custom_price = PAYCHECK_HARD * 4

/obj/item/computer_hardware/recharger/APC/use_power(amount, charging = 0)
	if(ismachinery(holder.physical))
		var/obj/machinery/M = holder.physical
		if(hacked)
			M.directly_use_power(amount)
			return 1
		if(M.powered())
			M.use_power(amount)
			return 1
	else
		var/area/A = get_area(src)
		if(!istype(A))
			return 0
		if(A.powered(AREA_USAGE_EQUIP))
			A.use_power(amount, AREA_USAGE_EQUIP)
			return 1
	return 0

/obj/item/computer_hardware/recharger/APC/update_overclocking(mob/living/user, obj/item/tool)
	if(hacked)
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // Rate Limiter // <font color='#ff2600'>Disengaged</font>")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // Rate Limiter // <span class='cfc_red'>Disengaged</span>")
	else
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // Rate Limiter // <font color='#17c011'>Engaged</font>")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // Rate Limiter // <span class='cfc_green'>Engaged</span>")

/obj/item/computer_hardware/recharger/APC/pda
	name = "micro area recharger"
	desc = "A device that wirelessly recharges connected device from nearby APC. Standard issue for Engineers."
	w_class = WEIGHT_CLASS_TINY // This premium little item can be fit into PDAs

/obj/item/computer_hardware/recharger/wired
	name = "wired power connector"
	desc = "A power connector that recharges connected device from nearby power wire. Incompatible with portable computers."
	icon_state = "charger_wire"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/computer_hardware/recharger/wired/can_install(obj/item/modular_computer/install_into, mob/living/user = null)
	if(ismachinery(install_into.physical) && install_into.physical.anchored)
		return ..()
	to_chat(user, span_warning("\The [src] is incompatible with portable computers!"))
	return 0

/obj/item/computer_hardware/recharger/wired/use_power(amount, charging = 0)
	if(ismachinery(holder.physical) && holder.physical.anchored)
		var/obj/machinery/M = holder.physical
		var/turf/T = M.loc
		if(!T || !istype(T))
			return 0

		var/obj/structure/cable/C = T.get_cable_node()
		if(!C || !C.powernet)
			return 0

		var/power_in_net = C.powernet.avail-C.powernet.load

		if(power_in_net && power_in_net > amount)
			C.powernet.load += amount
			return 1

	return 0

/// This recharger exists only in borg built-in tablets. I would have tied it to the borg's cell but
/// the program that displays laws should always be usable, and the exceptions were starting to pile.
/obj/item/computer_hardware/recharger/cyborg
	name = "modular interface power harness"
	desc = "A standard connection to power a small computer device from a cyborg's chassis."

/obj/item/computer_hardware/recharger/cyborg/use_power(amount, charging = 0)
	return TRUE


// This is not intended to be obtainable in-game. Intended for adminbus and debugging purposes.
/obj/item/computer_hardware/recharger/lambda
	name = "lambda coil"
	desc = "A very complex device that draws power from its own bluespace dimension."
	icon_state = "charger_lambda"
	w_class = WEIGHT_CLASS_TINY
	charge_rate = 100000

/obj/item/computer_hardware/recharger/lambda/use_power(amount, charging = 0)
	return 1

