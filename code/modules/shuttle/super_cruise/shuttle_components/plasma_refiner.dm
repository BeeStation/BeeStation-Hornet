/obj/machinery/atmospherics/components/unary/plasma_refiner
	name = "plasma refinery"
	desc = "A refinery that burns plasma sheets into plasma gas."
	icon_state = "plasma_refinery"
	density = TRUE
	var/moles_per_ore = 50

/obj/machinery/atmospherics/components/unary/plasma_refiner/process_atmos()
	update_parents()

/obj/machinery/atmospherics/components/unary/plasma_refiner/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore/plasma) || istype(W, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/stack = W
		var/moles_created = moles_per_ore * stack.amount
		var/datum/gas_mixture/air_contents = airs[1]
		if(!air_contents)
			return
		qdel(stack)
		air_contents.adjust_moles(GAS_PLASMA, moles_created)
		say("[moles_created] moles of plasma refined.")
		return
	. = ..()
