
/datum/wires/tesla_coil
	randomize = 1	//Only one wire don't need blueprints
	holder_type = /obj/machinery/power/energy_accumulator/tesla_coil

/datum/wires/tesla_coil/New(atom/holder)
	wires = list(WIRE_ZAP)
	..()

/datum/wires/tesla_coil/on_pulse(wire)
	var/obj/machinery/power/energy_accumulator/tesla_coil/coil = holder
	coil.zap()
	return ..()
