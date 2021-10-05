/obj/machinery/mass_driver
	name = "mass driver"
	desc = "The finest in spring-loaded piston toy technology, now on a space station near you."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 50
	circuit = /obj/item/circuitboard/machine/mass_driver
	var/power = 1
	var/code = 1
	var/id = 1
	var/drive_range = 10	//this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.
	var/power_per_obj = 1000


/obj/machinery/mass_driver/Initialize()
	. = ..()
	wires = new /datum/wires/mass_driver(src)

/obj/machinery/mass_driver/Destroy()
	QDEL_NULL(wires)
	. = ..()

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER) || !panel_open)
		return
	use_power(power_per_obj)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored || istype(O, /obj/machinery/power/supermatter_crystal) || ismecha(O))	//Mechs need their launch platforms. Oh, and SM cannon SM cannon.
			if(ismob(O) && !isliving(O))
				continue
			O_limit++
			if(O_limit >= 20)
				audible_message("<span class='notice'>[src] lets out a screech, it doesn't seem to be able to handle the load.</span>")
				break
			use_power(power_per_obj)
			O.throw_at(target, drive_range * power, power)
	flick("mass_driver1", src)

/obj/machinery/mass_driver/attackby(obj/item/I, mob/living/user, params)

	if(is_wire_tool(I) && panel_open)
		wires.interact(user)
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I)) //There's no off icon_state and I don't know how to sprite. I guess that's a problem...
		return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/mass_driver/RefreshParts()
	drive_range = 0
	power_per_obj = 1250
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		drive_range += M.rating * 5
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		power_per_obj -= C.rating * 250


/obj/machinery/mass_driver/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	drive()
