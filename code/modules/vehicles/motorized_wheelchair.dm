/obj/vehicle/ridden/wheelchair/motorized
	name = "motorized wheelchair"
	desc = "A chair with big wheels. It seems to have a motor in it."
	max_integrity = 150
	move_resist = MOVE_FORCE_DEFAULT
	var/speed = 2
	var/power_efficiency = 1
	var/power_usage = 25
	var/panel_open = FALSE
	var/list/required_parts = list(/obj/item/stock_parts/manipulator,
							/obj/item/stock_parts/manipulator,
							/obj/item/stock_parts/capacitor)
	var/obj/item/stock_parts/cell/power_cell
	var/low_power_alerted = FALSE

/obj/vehicle/ridden/wheelchair/motorized/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair/motorized)

/obj/vehicle/ridden/wheelchair/motorized/CheckParts(list/parts_list)
	..()
	refresh_parts()

/obj/vehicle/ridden/wheelchair/motorized/proc/refresh_parts()
	speed = 1 // Should never be under 1
	for(var/obj/item/stock_parts/manipulator/M in contents)
		speed += M.rating
	for(var/obj/item/stock_parts/capacitor/C in contents)
		power_efficiency = C.rating

/obj/vehicle/ridden/wheelchair/motorized/get_cell()
	return power_cell

/obj/vehicle/ridden/wheelchair/motorized/atom_destruction(damage_flag)
	var/turf/T = get_turf(src)
	for(var/c in contents)
		var/atom/movable/thing = c
		thing.forceMove(T)
	return ..()

/obj/vehicle/ridden/wheelchair/motorized/relaymove(mob/living/user, direction)
	if(!power_cell)
		to_chat(user, "<span class='warning'>There seems to be no cell installed in [src].</span>")
		canmove = FALSE
		addtimer(VARSET_CALLBACK(src, canmove, TRUE), 2 SECONDS)
		return FALSE
	if(power_cell.charge < power_usage / max(power_efficiency, 1))
		to_chat(user, "<span class='warning'>The display on [src] blinks 'Out of Power'.</span>")
		canmove = FALSE
		addtimer(VARSET_CALLBACK(src, canmove, TRUE), 2 SECONDS)
		return FALSE
	return ..()

/obj/vehicle/ridden/wheelchair/motorized/Moved()
	. = ..()
	power_cell.use(power_usage / max(power_efficiency, 1))
	if(!low_power_alerted && power_cell.charge <= (power_cell.maxcharge / 4))
		playsound(src, 'sound/machines/twobeep.ogg', 30, 1)
		say("Warning: Power low!")
		low_power_alerted = TRUE

/obj/vehicle/ridden/wheelchair/motorized/post_buckle_mob(mob/living/user)
	. = ..()
	set_density(TRUE)

/obj/vehicle/ridden/wheelchair/motorized/post_unbuckle_mob()
	. = ..()
	set_density(FALSE)

/obj/vehicle/ridden/wheelchair/motorized/attack_hand(mob/living/user)
	if(!power_cell || !panel_open)
		return ..()
	power_cell.update_icon()
	to_chat(user, "<span class='notice'>You remove the power cell from [src].</span>")
	user.put_in_hands(power_cell)
	power_cell = null
	low_power_alerted = FALSE

/obj/vehicle/ridden/wheelchair/motorized/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		I.play_tool_sound(src)
		panel_open = !panel_open
		user.visible_message(span_notice("[user] [panel_open ? "opens" : "closes"] the maintenance panel on [src]."), span_notice("You [panel_open ? "open" : "close"] the maintenance panel."))
		return
	if(!panel_open)
		return ..()

	if(istype(I, /obj/item/stock_parts/cell))
		if(power_cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed.</span>")
		else
			I.forceMove(src)
			power_cell = I
			to_chat(user, "<span class='notice'>You install the [I].</span>")
		refresh_parts()
		return
	if(!istype(I, /obj/item/stock_parts))
		return ..()

	var/obj/item/stock_parts/newstockpart = I
	for(var/obj/item/stock_parts/oldstockpart in contents)
		var/type_to_check
		for(var/pathtypes in required_parts)
			if(ispath(oldstockpart.type, pathtypes))
				type_to_check = oldstockpart.type
				break
		if(istype(newstockpart, type_to_check) && istype(oldstockpart, type_to_check))
			if(newstockpart.get_part_rating() > oldstockpart.get_part_rating())
				newstockpart.forceMove(src)
				user.put_in_hands(oldstockpart)
				user.visible_message("<span class='notice'>[user] replaces [oldstockpart] with [newstockpart] in [src].</span>", "<span class='notice'>You replace [oldstockpart] with [newstockpart].</span>")
				break
	refresh_parts()

/obj/vehicle/ridden/wheelchair/motorized/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You begin to detach the wheels..."))
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("You detach the wheels and deconstruct the chair."))
		new /obj/item/stack/rods(drop_location(), 8)
		new /obj/item/stack/sheet/iron(drop_location(), 10)
		var/turf/T = get_turf(src)
		for(var/c in contents)
			var/atom/movable/thing = c
			thing.forceMove(T)
		qdel(src)
	return TRUE

/obj/vehicle/ridden/wheelchair/motorized/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "There is a small screen on it, [(in_range(user, src) || isobserver(user)) ? "[power_cell ? "it reads:" : "but it is dark."]" : "but you can't see it from here."]"
	if(!power_cell || (!in_range(user, src) && !isobserver(user)))
		return
	. += "Speed: [speed]"
	. += "Energy efficiency: [power_efficiency]"
	. += "Power: [power_cell.charge] out of [power_cell.maxcharge]"

/obj/vehicle/ridden/wheelchair/motorized/Bump(atom/movable/M)
	. = ..()
	// If the speed is higher than delay_multiplier throw the person on the wheelchair away
	if(M.density && speed > delay_multiplier && has_buckled_mobs())
		var/mob/living/H = buckled_mobs[1]
		var/atom/throw_target = get_edge_target_turf(H, pick(GLOB.cardinals))
		unbuckle_mob(H)
		H.throw_at(throw_target, 2, 3)
		var/multiplier = 1
		if(HAS_TRAIT(H, TRAIT_PROSKATER))
			multiplier = 0.7 //30% reduction
		H.Knockdown(100 * multiplier)
		H.adjustStaminaLoss(40 * multiplier)
		if(isliving(M))
			var/mob/living/D = M
			throw_target = get_edge_target_turf(D, pick(GLOB.cardinals))
			D.throw_at(throw_target, 2, 3)
			D.Knockdown(80)
			D.adjustStaminaLoss(35)
			visible_message(span_danger("[src] crashes into [M], sending [H] and [D] flying!"))
		else
			visible_message(span_danger("[src] crashes into [M], sending [H] flying!"))
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
