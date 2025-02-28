
/datum/wires/emitter
	proper_name = "Emitter"
	holder_type = /obj/machinery/power/emitter

/datum/wires/emitter/New(atom/holder)
	wires = list(WIRE_ACTIVATE,WIRE_INTERFACE)
	..()

/datum/wires/emitter/on_pulse(wire)
	var/obj/machinery/power/emitter/E = holder
	switch(wire)
		if(WIRE_ACTIVATE)
			E.fire_beam_pulse()
		if(WIRE_INTERFACE)
			E.mode = !E.mode
			E.set_projectile()
