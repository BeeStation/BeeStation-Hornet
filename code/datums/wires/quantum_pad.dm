/datum/wires/quantum_pad
	holder_type = /obj/machinery/quantumpad

/datum/wires/quantum_pad/New(atom/holder)
	wires = list(WIRE_ACTIVATE)
	..()

/datum/wires/quantum_pad/on_pulse(wire)
	var/obj/machinery/quantumpad/Q = holder
	switch(wire)
		if(WIRE_ACTIVATE)
			if(Q.panel_open)
				holder.visible_message("<span class='notice'>[icon2html(Q, viewers(holder))] The activation light flickers.</span>")
				return
			else
				Q.interact()
	..()
