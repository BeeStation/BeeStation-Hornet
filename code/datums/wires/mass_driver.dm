/datum/wires/mass_driver
	holder_type = /obj/machinery/mass_driver
	proper_name = "Mass Driver"

/datum/wires/mass_driver/New(atom/holder)
	wires = list(WIRE_LAUNCH)
	..()

/datum/wires/mass_driver/on_pulse(wire)
	var/obj/machinery/mass_driver/M = holder
	M.drive()


