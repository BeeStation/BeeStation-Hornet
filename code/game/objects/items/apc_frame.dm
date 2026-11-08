// APC HULL
/obj/item/wallframe/apc
	name = "\improper APC frame"
	desc = "Used for repairing or building APCs."
	icon_state = "apc"
	result_path = /obj/machinery/power/apc

/obj/item/wallframe/apc/try_build(turf/on_wall, user)
	if(!..())
		return
	var/turf/T = get_turf(on_wall) //the user is not where it needs to be.
	var/area/A = get_area(user)
	if(A.apc)
		to_chat(user, span_warning("This area already has an APC!"))
		return //only one APC per area
	if(!A.requires_power)
		to_chat(user, span_warning("You cannot place [src] in this area!"))
		return //can't place apcs in areas with no power requirement
	for(var/obj/machinery/power/terminal/E in T)
		if(E.master)
			to_chat(user, span_warning("There is another network terminal here!"))
			return
		else
			new /obj/item/stack/cable_coil(T, 10)
			to_chat(user, span_notice("You cut the cables and disassemble the unused power terminal."))
			qdel(E)
	return TRUE

/obj/item/wallframe/apc/add_context_self(datum/screentip_context/context, mob/user)
	if(!iswallturf(get_step(get_turf(user), user.dir)))
		return
	var/obj/machinery/power/apc/mounted_apc = locate() in get_turf(user)
	context.add_left_click_tool_action(mounted_apc?.dir == user.dir ? "Apply Frame to APC" : "Mount Frame on Wall", TOOL_SCREWDRIVER)

/obj/item/wallframe/apc/screwdriver_act(mob/living/user, obj/item/tool) // Weird snowflake, specifically made so borgs can replace broken covers, they can still make new apcs
	var/turf/user_turf = get_turf(user)
	if(iswallturf(get_step(user_turf, user.dir)))
		var/obj/machinery/power/apc/mounted_apc = locate() in user_turf
		if(mounted_apc?.dir == user.dir)
			mounted_apc.attackby(src, user)
			return ITEM_INTERACT_SUCCESS
	return ..()
