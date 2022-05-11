/datum/wires/advanced_airlock_controller
	holder_type = /obj/machinery/advanced_airlock_controller
	proper_name = "Air Alarm"

/datum/wires/advanced_airlock_controller/New(atom/holder)
	wires = list(
		WIRE_POWER,
		WIRE_IDSCAN, WIRE_AI
	)
	add_duds(3)
	..()

/datum/wires/advanced_airlock_controller/interactable(mob/user)
	var/obj/machinery/advanced_airlock_controller/A = holder
	if(A.panel_open && A.buildstage == 2)
		return TRUE

/datum/wires/advanced_airlock_controller/get_status()
	var/obj/machinery/advanced_airlock_controller/A = holder
	var/list/status = list()
	status += "The interface light is [A.locked ? "red" : "green"]."
	status += "The short indicator is [A.shorted ? "lit" : "off"]."
	status += "The AI connection light is [!A.aidisabled ? "on" : "off"]."
	return status

/datum/wires/advanced_airlock_controller/on_pulse(wire)
	var/obj/machinery/advanced_airlock_controller/A = holder
	switch(wire)
		if(WIRE_POWER) // Short out for a long time.
			if(!A.shorted)
				A.shorted = TRUE
				A.update_appearance()
			addtimer(CALLBACK(A, /obj/machinery/advanced_airlock_controller.proc/reset, wire), 1200)
		if(WIRE_IDSCAN) // Toggle lock.
			A.locked = !A.locked
		if(WIRE_AI) // Disable AI control for a while.
			if(!A.aidisabled)
				A.aidisabled = TRUE
			addtimer(CALLBACK(A, /obj/machinery/advanced_airlock_controller.proc/reset, wire), 100)

/datum/wires/advanced_airlock_controller/on_cut(wire, mend)
	var/obj/machinery/advanced_airlock_controller/A = holder
	switch(wire)
		if(WIRE_POWER) // Short out forever.
			A.shock(usr, 50)
			A.shorted = !mend
			A.update_appearance()
		if(WIRE_IDSCAN)
			if(!mend)
				A.locked = TRUE
		if(WIRE_AI)
			A.aidisabled = mend // Enable/disable AI control.
