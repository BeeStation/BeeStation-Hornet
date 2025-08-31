/obj/item/computer_hardware/battery
	name = "power cell controller"
	desc = "A charge controller for standard power cells, used in all kinds of modular computers."
	icon_state = "cell_con"
	critical = 1
	malfunction_probability = 1
	var/obj/item/stock_parts/cell/computer/battery
	device_type = MC_CELL
	custom_price = PAYCHECK_EASY

/obj/item/computer_hardware/battery/get_cell()
	return battery

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/computer_hardware/battery)

/obj/item/computer_hardware/battery/on_remove(obj/item/modular_computer/remove_from, mob/user)
	if(!holder)
		return ..()
	var/obj/item/computer_hardware/recharger/recharger = holder.all_components[MC_CHARGER]
	if(!recharger)	// We need to shutdown the computer if the battery is removed and theres nothing to give it power
		remove_from.shutdown_computer()
	return ..()

/obj/item/computer_hardware/battery/Initialize(mapload, battery_type)
	. = ..()
	if(battery_type)
		battery = new battery_type(src)

/obj/item/computer_hardware/battery/Destroy()
	if(battery)
		QDEL_NULL(battery)
	return ..()

/obj/item/computer_hardware/battery/handle_atom_del(atom/A)
	if(A == battery)
		try_eject(forced = TRUE)
	. = ..()

/obj/item/computer_hardware/battery/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!istype(I, /obj/item/stock_parts/cell))
		return FALSE

	if(battery)
		to_chat(user, span_warning("You try to connect \the [I] to \the [src], but its connectors are occupied."))
		return FALSE

	if(I.w_class > holder.max_hardware_size)
		to_chat(user, span_warning("This power cell is too large for \the [holder]!"))
		return FALSE

	if(user && !user.transferItemToLoc(I, src))
		return FALSE

	battery = I
	to_chat(user, span_notice("You connect \the [I] to \the [src]."))
	playsound(src, 'sound/items/handling/tape_drop.ogg', 50, TRUE)

	return TRUE

/obj/item/computer_hardware/battery/try_eject(mob/living/user = null, forced = FALSE)
	if(!battery)
		to_chat(user, span_warning("There is no power cell connected to \the [src]."))
		return FALSE
	else
		if(user && in_range(src, user))
			user.put_in_hands(battery)
			to_chat(user, span_notice("You detach \the [battery] from \the [src]."))
		else
			battery.forceMove(drop_location())

		battery = null
		return TRUE

/obj/item/computer_hardware/battery/update_overclocking(mob/living/user, obj/item/tool)
	if(hacked)
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // <font color='#ff2600'>WARNING</font> // Battery Integrity Sensor DISENGAGED - COMPLETE BATTERY DISCHARGE ILL-ADVISED")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // <span class='cfc_red'>WARNING</span> // Battery Integrity Sensor DISENGAGED - COMPLETE BATTERY DISCHARGE ILL-ADVISED")
	else
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // Battery Integrity Sensor // <font color='#17c011'>Engaged</font>")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // Battery Integrity Sensor // <span class='cfc_green'>Engaged</span>")

/obj/item/stock_parts/cell/computer
	name = "standard battery"
	desc = "A standard power cell, commonly seen in high-end portable microcomputers or low-end laptops."
	icon = 'icons/obj/module.dmi'
	icon_state = "cell_mini"
	w_class = WEIGHT_CLASS_SMALL
	maxcharge = 1000
	/// Size affects the size of the explosion created by the detonation of the battery (trough Power Cell Controler hacking)
	rating = PART_TIER_3
	custom_price = PAYCHECK_MEDIUM

/obj/item/stock_parts/cell/computer/advanced
	name = "advanced battery"
	desc = "An advanced power cell, often used in most laptops, or high-end Tablets."
	icon_state = "cell"
	w_class = WEIGHT_CLASS_SMALL
	maxcharge = 1500
	custom_price = PAYCHECK_MEDIUM * 2
	rating = PART_TIER_4

/obj/item/stock_parts/cell/computer/super
	name = "super battery"
	desc = "An advanced power cell, often used in high-end laptops."
	icon_state = "cell"
	w_class = WEIGHT_CLASS_NORMAL	// Fits only laptops
	maxcharge = 2000
	custom_price = PAYCHECK_MEDIUM * 3
	rating = PART_TIER_5

/obj/item/stock_parts/cell/computer/micro
	name = "micro battery"
	desc = "A small power cell, commonly seen in most portable microcomputers."
	icon_state = "cell_micro"
	maxcharge = 750
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_EASY * 2
	rating = PART_TIER_2

/obj/item/stock_parts/cell/computer/nano
	name = "nano battery"
	desc = "A tiny power cell, commonly seen in low-end portable microcomputers."
	icon_state = "cell_micro"
	w_class = WEIGHT_CLASS_TINY
	maxcharge = 500
	custom_price = PAYCHECK_EASY
	rating = PART_TIER_1
