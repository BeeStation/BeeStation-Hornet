
/obj/item/storage/belt/recharging_belt
	name = "recharging vest"
	desc = "Taps into nearby APCs to recharge anything placed inside of it. Inefficient compared to standard rechargers and very wasteful."
	icon_state = "rechargingvest"
	slot_flags = ITEM_SLOT_BELT

/obj/item/storage/belt/recharging_belt/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_items = 1
	var/static/list/can_hold = typecacheof(list(
		/obj/item/gun/energy,
		/obj/item/melee/baton,
		/obj/item/ammo_box/magazine/recharge))
	STR.can_hold = can_hold

/obj/item/storage/belt/recharging_belt/process()
	var/obj/item/stored_item
	if(!LAZYLEN(contents))
		return
	stored_item = contents[1]
	var/area/A = get_area(src)
	if(!A)
		return
	var/obj/machinery/power/apc/APC = A.get_apc()
	if(APC.cell?.charge >= 500)
		APC.use_power(500)
		var/obj/item/stock_parts/cell/C = stored_item.get_cell()
		if(C)
			if(C.charge < C.maxcharge)
				C.give(150)

	if(APC.cell?.charge >= 800)
		APC.use_power(800)
		if(istype(stored_item, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/R = stored_item
			if(R.stored_ammo.len < R.max_ammo)
				R.stored_ammo += new R.ammo_type(R)

/obj/item/storage/belt/recharging_belt/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_BELT)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/storage/belt/recharging_belt/dropped(mob/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)
