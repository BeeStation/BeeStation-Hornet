//File with the circuitboard and circuitboard/machine class definitions and procs


// Circuitboard

/obj/item/circuitboard
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	materials = list(/datum/material/glass=1000)
	w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/silicon = 20)
	var/build_path = null

/obj/item/circuitboard/proc/apply_default_parts(obj/machinery/machine)
	if(LAZYLEN(machine.component_parts))
		// This really shouldn't happen. If it somehow does, print out a stack trace and gracefully handle it.
		stack_trace("apply_default_parts called on machine that already had component_parts: [machine]")

		// Move to nullspace so you don't trigger handle_atom_del logic and remove existing parts.
		for(var/obj/item/part as anything in machine.component_parts)
			part.moveToNullspace(loc)
			qdel(part)

	// List of components always contains the circuit board used to build it.
	machine.component_parts = list(src)
	forceMove(machine)

	if(machine.circuit != src)
		// This really shouldn't happen. If it somehow does, print out a stack trace and gracefully handle it.
		stack_trace("apply_default_parts called from a circuit board that does not belong to machine: [machine]")

		// Move to nullspace so you don't trigger handle_atom_del logic, remove old circuit, add new circuit.
		machine.circuit.moveToNullspace()
		qdel(machine.circuit)
		machine.circuit = src

	return

/**
 * Used to allow the circuitboard to configure a machine in some way, shape or form.
 *
 * Arguments:
 * * machine - The machine to attempt to configure.
 */
/obj/item/circuitboard/proc/configure_machine(obj/machinery/machine)
	return

// Circuitboard/machine
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
*/

/obj/item/circuitboard/machine
	var/needs_anchored = TRUE // Whether this machine must be anchored to be constructed.
	var/list/req_components // Components required by the machine.
							// Example: list(/obj/item/stock_parts/matter_bin = 5)

	var/list/def_components // Default replacements for req_components, to be used in apply_default_parts instead of req_components types
							// Example: list(/obj/item/stock_parts/matter_bin = /obj/item/stock_parts/matter_bin/super)

// Applies the default parts defined by the circuit board when the machine is created
/obj/item/circuitboard/machine/apply_default_parts(obj/machinery/machine)
	if(!req_components)
		return

	. = ..()

	for(var/comp_path in req_components)
		var/comp_amt = req_components[comp_path]
		if(!comp_amt)
			continue

		if(def_components && def_components[comp_path])
			comp_path = def_components[comp_path]

		if(ispath(comp_path, /obj/item/stack))
			machine.component_parts += new comp_path(machine, comp_amt)
		else
			for(var/component in 1 to comp_amt)
				machine.component_parts += new comp_path(machine)

	machine.RefreshParts()

/obj/item/circuitboard/machine/examine(mob/user)
	. = ..()
	if(LAZYLEN(req_components))
		var/list/nice_list = list()
		for(var/B in req_components)
			var/atom/A = B
			if(!ispath(A))
				continue
			nice_list += list("[req_components[A]] [initial(A.name)]")
		. += "<span class='notice'>Required components: [english_list(nice_list)].</span>"
