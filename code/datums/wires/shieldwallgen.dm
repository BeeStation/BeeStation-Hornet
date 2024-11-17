/datum/wires/shieldwallgen
	holder_type = /obj/machinery/power/shieldwallgen
	proper_name = "Shield Wall Generator"

/datum/wires/shieldwallgen/New(atom/holder)
	wires = list(
		WIRE_ACTIVATE,
		WIRE_DISABLE,
		WIRE_SHOCK
	)
	add_duds(2)
	..()

/datum/wires/shieldwallgen/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/power/shieldwallgen/generator = holder
	if(generator.panel_open)
		return TRUE

/datum/wires/shieldwallgen/get_status()
	var/obj/machinery/power/shieldwallgen/generator = holder
	var/list/status = list()
	status += "The interface light is [generator.locked ? "red" : "green"]."
	status += "The activity light is [generator.shieldstate ? "blinking steadily" : "off"]."
	return status

/datum/wires/shieldwallgen/on_pulse(wire)
	var/obj/machinery/power/shieldwallgen/generator = holder
	switch(wire)
		if(WIRE_SHOCK)
			generator.shocked = !generator.shocked
			addtimer(CALLBACK(generator, TYPE_PROC_REF(/obj/machinery/modular_fabricator/autolathe, reset), wire), 60)
		if(WIRE_ACTIVATE)
			generator.toggle()
		if(WIRE_DISABLE)
			generator.locked = !generator.locked

/datum/wires/shieldwallgen/on_cut(wire, mend)
	var/obj/machinery/power/shieldwallgen/generator = holder
	switch(wire)
		if(WIRE_SHOCK)
			generator.shocked = !mend
		if(WIRE_ACTIVATE)
			if(!mend)
				generator.shieldstate = FALSE
		if(WIRE_DISABLE)
			generator.locked = !mend
