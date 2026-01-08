/obj/item/computer_hardware/battery
	name = "coder battery"
	desc = "You're not supposed to see this!"
	icon = 'icons/obj/module.dmi'
	icon_state = "cell_micro"
	critical = 1
	malfunction_probability = 1
	var/obj/item/stock_parts/cell/computer/battery
	var/battery_type
	device_type = MC_CELL

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

/obj/item/computer_hardware/battery/Initialize(mapload)
	. = ..()
	if(battery_type)
		battery = new battery_type(src)

/obj/item/computer_hardware/battery/Destroy()
	if(battery)
		QDEL_NULL(battery)
	return ..()

/obj/item/computer_hardware/battery/update_overclocking(mob/living/user, obj/item/tool)
	if(hacked)
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // <font color='#ff2600'>WARNING</font> // Battery Integrity Sensor DISENGAGED - COMPLETE BATTERY DISCHARGE ILL-ADVISED")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // <span class='cfc_red'>WARNING</span> // Battery Integrity Sensor DISENGAGED - COMPLETE BATTERY DISCHARGE ILL-ADVISED")
	else
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // Battery Integrity Sensor // <font color='#17c011'>Engaged</font>")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // Battery Integrity Sensor // <span class='cfc_green'>Engaged</span>")

// =================================
// Battery Hardware
// =================================

/obj/item/computer_hardware/battery/tiny	//I just wanted to create a subtype to facilitate coding since seeing battery alone isn't very helpful at a glance
	name = "tiny battery"
	desc = "The smallest battery available. Commonly seen in low-end portable microcomputers"
	battery_type = /obj/item/stock_parts/cell/computer/nano
	/// Rating affects the size of the explosion created by the detonation of the battery through hacking
	rating = PART_TIER_1
	custom_price = PAYCHECK_EASY

/obj/item/computer_hardware/battery/small
	name = "small battery"
	desc = "A small battery. Commonly seen in most portable microcomputers."
	icon_state = "cell_micro"
	battery_type = /obj/item/stock_parts/cell/computer/micro
	rating = PART_TIER_2
	custom_price = PAYCHECK_EASY * 2

/obj/item/computer_hardware/battery/standard
	name = "standard battery"
	desc = "A standard battery, commonly seen in high-end portable microcomputers or low-end laptops."
	icon_state = "cell_mini"
	battery_type = /obj/item/stock_parts/cell/computer
	w_class = WEIGHT_CLASS_SMALL	// Fits tablets and up
	rating = PART_TIER_3
	custom_price = PAYCHECK_MEDIUM

/obj/item/computer_hardware/battery/large
	name = "large battery"
	desc = "An advanced battery, often used in most laptops, or high-end Tablets."
	icon_state = "cell"
	battery_type = /obj/item/stock_parts/cell/computer/advanced
	w_class = WEIGHT_CLASS_SMALL	// Fits tablets and up
	rating = PART_TIER_4
	custom_price = PAYCHECK_MEDIUM * 2

/obj/item/computer_hardware/battery/huge
	name = "extra large battery"
	desc = "An advanced battery, often used in high-end laptops."
	icon_state = "cell"
	battery_type = /obj/item/stock_parts/cell/computer/super
	w_class = WEIGHT_CLASS_NORMAL	// Fits only laptops
	rating = PART_TIER_5
	custom_price = PAYCHECK_MEDIUM * 3

// =================================
// Battery Cells: Each tier increases by 50%
// =================================

/obj/item/stock_parts/cell/computer/nano
	name = "nano battery"
	desc = "A tiny power cell, commonly seen in low-end portable microcomputers."
	icon_state = "cell_micro"
	w_class = WEIGHT_CLASS_TINY
	maxcharge = 75 KILOWATT
	chargerate_divide = 4
	custom_price = PAYCHECK_EASY
	rating = PART_TIER_1

/obj/item/stock_parts/cell/computer/micro
	name = "micro battery"
	desc = "A small power cell, commonly seen in most portable microcomputers."
	icon_state = "cell_micro"
	maxcharge = 90 KILOWATT
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_EASY * 2
	rating = PART_TIER_2
	chargerate_divide = 2

/obj/item/stock_parts/cell/computer
	name = "standard battery"
	desc = "A standard power cell, commonly seen in high-end portable microcomputers or low-end laptops."
	icon = 'icons/obj/module.dmi'
	icon_state = "cell_mini"
	w_class = WEIGHT_CLASS_SMALL
	maxcharge = 110 KILOWATT
	/// rating affects the size of the explosion created by the detonation of the battery (trough Power Cell Controler hacking)
	rating = PART_TIER_3
	custom_price = PAYCHECK_MEDIUM

/obj/item/stock_parts/cell/computer/advanced
	name = "advanced battery"
	desc = "An advanced power cell, often used in most laptops, or high-end Tablets."
	icon_state = "cell"
	w_class = WEIGHT_CLASS_SMALL
	maxcharge = 140 KILOWATT
	custom_price = PAYCHECK_MEDIUM * 2
	rating = PART_TIER_4

/obj/item/stock_parts/cell/computer/super
	name = "super battery"
	desc = "An advanced power cell, often used in high-end laptops."
	icon_state = "cell"
	w_class = WEIGHT_CLASS_NORMAL	// Fits only laptops
	maxcharge = 220 KILOWATT
	chargerate_divide = 10
	custom_price = PAYCHECK_MEDIUM * 3
	rating = PART_TIER_5
