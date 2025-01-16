/obj/machinery/atmospherics/components/unary/plasma_refiner
	name = "plasma refinery"
	desc = "A refinery that burns plasma sheets into plasma gas. Can also create plasma sheets, albeit inefficiently."
	icon_state = "plasma_refinery"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/plasma_refiner
	var/moles_per_ore = 50

/obj/machinery/atmospherics/components/unary/plasma_refiner/process_atmos()
	update_parents()

/obj/machinery/atmospherics/components/unary/plasma_refiner/on_construction(mob/user)
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/plasma_refiner/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore/plasma) || istype(W, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/stack = W
		var/moles_created = moles_per_ore * stack.amount
		var/datum/gas_mixture/air_contents = airs[1]
		if(!air_contents)
			return
		qdel(stack)
		air_contents.gases[/datum/gas/plasma][MOLES] += moles_created
		say("[moles_created] moles of plasma refined.")
		return

	if(default_deconstruction_screwdriver(user, "plasma_refinery_o", "plasma_refinery", W))
		return
	if(default_change_direction_wrench(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return

	. = ..()

/obj/machinery/atmospherics/components/unary/plasma_refiner/AltClick(mob/living/user)
	var/datum/gas_mixture/air_contents = airs[1]
	var/plasmoles = GET_MOLES(/datum/gas/plasma, air_contents)
	if(!air_contents)
		return
	if(plasmoles >= 100)
		var/obj/item/stack/sheet/mineral/plasma/P = new(src.loc, 1)
		air_contents.gases[/datum/gas/plasma][MOLES] += -100
		say("100 moles of plasma consumed. A sheet of [P.name] has been created.")
	else
		say("Insufficient plasma. At least 100 moles of plasma are required. There are currently [plasmoles] moles of plasma.")
	. = ..()

/obj/machinery/atmospherics/components/unary/plasma_refiner/RefreshParts()
	moles_per_ore = 20
	for(var/obj/item/stock_parts/micro_laser/l in component_parts)
		moles_per_ore += l.rating * 10



/obj/machinery/atmospherics/components/unary/plasma_refiner/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(.)
		set_init_directions()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
		if(parents[1])
			nullify_pipenet(parents[1])
		atmos_init()
		node = nodes[1]
		if(node)
			node.atmos_init()
			node.add_member(src)
		SSair.add_to_rebuild_queue(src)
