GLOBAL_LIST_EMPTY(active_bluespace_anchors)

/obj/machinery/bluespace_anchor
	name = "deployed bluespace anchor"
	desc = "A deployed bluespace anchor, it consumes a large amount of energy in order to stablise nearby bluespace anomalies."

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"

	var/obj/item/stock_parts/cell/power_cell
	var/range = 8
	var/power_usage_per_teleport = 8000

/obj/machinery/bluespace_anchor/Initialize(mapload, obj/item/stock_parts/cell/cell)
	. = ..()
	//Move the cell
	insert_cell(cell)

/obj/machinery/bluespace_anchor/Destroy()
	. = ..()
	//Delete the power cell
	if(power_cell)
		QDEL_NULL(power_cell)

/obj/machinery/bluespace_anchor/attack_hand(mob/living/user)
	to_chat(usr, "<span class='notice'>You begin deactivating [src]...</span>")
	//Failing to deactivate it
	if(!do_after(user, 8 SECONDS, target = src))
		to_chat(usr, "<span class='userdanger'>You fail to deactivate [src]!</span>")
		if(!power_cell.use(power_usage_per_teleport))
			return
		user.electrocute_act(40)
		return
	//Deactivate it
	var/obj/item/created = new /obj/item/bluespace_anchor(get_turf(src), power_cell)
	user.put_in_active_hand(created)
	qdel(src)

/obj/machinery/bluespace_anchor/proc/try_activate(atom/teleatom)
	//Check power
	if (!power_cell)
		return FALSE
	if(!power_cell.use(power_usage_per_teleport))
		return FALSE
	//Spark and shock people adjacent
	tesla_zap(src, 1, 8000, TESLA_MOB_STUN | TESLA_MOB_DAMAGE)
	return TRUE

/obj/machinery/bluespace_anchor/proc/insert_cell(cell)
	if(power_cell)
		power_cell.forceMove(get_turf(src))
		UnregisterSignal(power_cell, COMSIG_PARENT_QDELETING)
		power_cell = null
	power_cell = cell
	if(power_cell)
		power_cell.forceMove(src)

