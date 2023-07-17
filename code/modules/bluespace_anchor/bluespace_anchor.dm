GLOBAL_LIST_EMPTY(active_bluespace_anchors)

/obj/machinery/bluespace_anchor
	name = "deployed bluespace anchor"
	desc = "A deployed bluespace anchor, it consumes a large amount of energy in order to stablise bluespace instabilities and prevent teleporation."

	icon = 'icons/obj/bluespace_anchor.dmi'
	icon_state = "anchor_active"

	light_range = 1.8
	light_color = "#aeebe6"
	light_system = MOVABLE_LIGHT

	var/obj/item/stock_parts/cell/power_cell
	var/range = 8
	var/power_usage_per_teleport = 1500

/obj/machinery/bluespace_anchor/Initialize(mapload, obj/item/stock_parts/cell/cell)
	. = ..()
	//Move the cell
	set_cell(cell)
	GLOB.active_bluespace_anchors += src
	update_icon()

/obj/machinery/bluespace_anchor/Destroy()
	GLOB.active_bluespace_anchors -= src
	//Delete the power cell
	if(power_cell)
		QDEL_NULL(power_cell)
	. = ..()

/obj/machinery/bluespace_anchor/update_icon()
	. = ..()
	if (!power_cell || power_cell.charge < power_usage_per_teleport)
		icon_state = "anchor_depleted"
	else
		icon_state = "anchor_active"

/obj/machinery/bluespace_anchor/attack_hand(mob/living/user)
	if(src in user.do_afters)
		to_chat(user, "<span class='warning'>You're already trying to deactivate [src]!</span>")
		return
	user.visible_message("<span class='notice'>[user] starts deactivating [src].</span>", "<span class='notice'>You begin deactivating [src]...</span>")
	//Failing to deactivate it
	if(!do_after(user, 8 SECONDS, target = src))
		user.visible_message("<span class='warning'>[user] fails to deactivate [src]!</span>", "<span class='warning'>You fail to deactivate [src]!</span>")
		if(!power_cell?.use(power_usage_per_teleport))
			return
		user.electrocute_act(40)
		return
	//Deactivate it
	var/removed_power_cell = power_cell
	set_cell(null)
	var/obj/item/created = new /obj/item/bluespace_anchor(get_turf(src), removed_power_cell)
	user.put_in_active_hand(created)
	qdel(src)

/obj/machinery/bluespace_anchor/proc/try_activate(atom/teleatom)
	//Check power
	if(!power_cell?.use(power_usage_per_teleport))
		return FALSE
	//Update icon
	update_icon()
	flick("anchor_pulse", src)
	//Spark and shock people adjacent
	for (var/mob/living/L in view(1, src))
		src.Beam(L, icon_state="lightning[rand(1,12)]", time=5, maxdistance = INFINITY)
		var/shock_damage = min(round(power_usage_per_teleport/600), 90) + rand(-5, 5)
		L.electrocute_act(shock_damage, src)
	return TRUE

/obj/machinery/bluespace_anchor/proc/set_cell(cell)
	if(power_cell)
		power_cell.forceMove(get_turf(src))
		UnregisterSignal(power_cell, COMSIG_PARENT_QDELETING)
	power_cell = cell
	if(power_cell)
		power_cell.forceMove(src)
	update_icon()
