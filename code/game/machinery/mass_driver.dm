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
	var/drive_range = 10
	var/power_per_obj = 1000

/obj/machinery/mass_driver/notspace
	drive_range = 50

/obj/machinery/mass_driver/supermatter
	name = "emergency supermatter ejection pad"
	id = "smeject"
	armor_type = /datum/armor/massdriver_supermatter
	critical_machine = 1

/datum/armor/massdriver_supermatter
	melee = 10
	bullet = 10
	laser = 10
	fire = 100
	acid = 70

/obj/machinery/mass_driver/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/mass_driver(src)

/obj/machinery/mass_driver/Destroy()
	QDEL_NULL(wires)
	. = ..()

/obj/machinery/mass_driver/proc/drive(amount)
	if(machine_stat & (BROKEN|NOPOWER) || panel_open)
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
				audible_message(span_notice("[src] lets out a screech, it doesn't seem to be able to handle the load."))
				break
			use_power(power_per_obj)
			O.throw_at(target, drive_range * power, power)
	flick("mass_driver1", src)

/obj/machinery/mass_driver/attackby(obj/item/I, mob/living/user, params)

	if(is_wire_tool(I) && panel_open)
		wires.interact(user)
		return
	if(default_deconstruction_screwdriver(user, "mass_driver_o", "mass_driver", I))
		return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/mass_driver/RefreshParts()
	drive_range = initial(drive_range)
	power_per_obj = initial(power_per_obj)
	for(var/obj/item/stock_parts/P in component_parts)
		switch(P.type)
			if(/obj/item/stock_parts/manipulator)
				drive_range += (P.rating - 1) * 5 //Subtract by 1, so initial values represent T1 parts
			if(/obj/item/stock_parts/capacitor)
				power_per_obj -= (P.rating - 1) * 250

/obj/machinery/mass_driver/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		return
	drive()
