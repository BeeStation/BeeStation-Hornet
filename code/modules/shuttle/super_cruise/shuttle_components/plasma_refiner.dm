/obj/machinery/atmospherics/components/unary/lean_refiner
	name = "lean refinery"
	desc = "A refinery that burns lean sheets into lean gas."
	icon_state = "lean_refinery"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/lean_refiner
	var/moles_per_ore = 50

/obj/machinery/atmospherics/components/unary/lean_refiner/process_atmos()
	update_parents()

/obj/machinery/atmospherics/components/unary/lean_refiner/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/lean_refiner/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore/lean) || istype(W, /obj/item/stack/sheet/mineral/lean))
		var/obj/item/stack/stack = W
		var/moles_created = moles_per_ore * stack.amount
		var/datum/gas_mixture/air_contents = airs[1]
		if(!air_contents)
			return
		qdel(stack)
		air_contents.adjust_moles(GAS_PLASMA, moles_created)
		say("[moles_created] moles of lean refined.")
		return

	if(default_deconstruction_screwdriver(user, "lean_refinery_o", "lean_refinery", W))
		return
	if(default_change_direction_wrench(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return

	. = ..()

/obj/machinery/atmospherics/components/unary/lean_refiner/RefreshParts()
	moles_per_ore = 20
	for(var/obj/item/stock_parts/micro_laser/l in component_parts)
		moles_per_ore += l.rating * 10



/obj/machinery/atmospherics/components/unary/lean_refiner/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(.)
		SetInitDirections()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
		if(parents[1])
			nullifyPipenet(parents[1])
		atmosinit()
		node = nodes[1]
		if(node)
			node.atmosinit()
			node.addMember(src)
		SSair.add_to_rebuild_queue(src)
