/*
	Vending machine refills can be found at /code/modules/vending/ within each vending machine's respective file
*/
/obj/item/vending_refill
	name = "small resupply canister"
	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_small"
	item_state = "restock_unit"
	desc = "Used to restock vending machines! The bigger it is, the faster it restocks!"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_MEDIUM
	armor_type = /datum/armor/item_vending_refill
	/// Amount used to restock vending machines, gets decressed by restocking action
	var/stock = 5
	/// Restocking speed of the cannister. Some are faster than others!
	var/restock_speed = 1 SECONDS

/datum/armor/item_vending_refill
	fire = 70
	acid = 30

/obj/item/vending_refill/examine(mob/user)
	. = ..()
	if(stock == initial(stock))
		. += "It's sealed tight, completely full of supplies."
	else if(stock <= 0)
		. += "It's empty!"
	else
		. += "It can restock [stock] item\s."

/obj/item/vending_refill/medium
	name = "medium resuply canister"
	icon_state = "refill_medium"
	item_state = "restock_unit"
	w_class = WEIGHT_CLASS_LARGE
	stock = 10
	restock_speed = 0.5 SECONDS

/obj/item/vending_refill/large
	name = "large resuply canister"
	icon_state = "refill_large"
	item_state = "restock_unit"
	w_class = WEIGHT_CLASS_BULKY
	stock = 20
	restock_speed = 0.25 SECONDS
