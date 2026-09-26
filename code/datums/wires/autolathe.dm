/datum/wires/autolathe
	holder_type = /obj/machinery/modular_fabricator/autolathe
	proper_name = "Autolathe"

/datum/wires/autolathe/New(atom/holder)
	wires = list(
		WIRE_HACK, WIRE_DISABLE,
		WIRE_SHOCK, WIRE_ZAP, WIRE_ACTIVATE
	)
	add_duds(5)
	..()

/datum/wires/autolathe/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/modular_fabricator/autolathe/A = holder
	if(A.panel_open)
		return TRUE

/datum/wires/autolathe/get_status()
	var/obj/machinery/modular_fabricator/autolathe/autolathe = holder
	return list(
		"The red light is [autolathe.disabled ? "on" : "off"].",
		"The blue light is [autolathe.hacked ? "on" : "off"].",
	)

/datum/wires/autolathe/on_pulse(wire)
	var/obj/machinery/modular_fabricator/autolathe/autolathe = holder
	switch(wire)
		if(WIRE_HACK)
			autolathe.hacked = !autolathe.hacked
			addtimer(CALLBACK(autolathe, TYPE_PROC_REF(/obj/machinery/modular_fabricator/autolathe, reset), wire), 6 SECONDS)
		if(WIRE_SHOCK)
			autolathe.shocked = !autolathe.shocked
			addtimer(CALLBACK(autolathe, TYPE_PROC_REF(/obj/machinery/modular_fabricator/autolathe, reset), wire), 6 SECONDS)
		if(WIRE_DISABLE)
			autolathe.disabled = !autolathe.disabled
			addtimer(CALLBACK(autolathe, TYPE_PROC_REF(/obj/machinery/modular_fabricator/autolathe, reset), wire), 6 SECONDS)
		if(WIRE_ACTIVATE)
			autolathe.begin_process()
	ui_update()

/datum/wires/autolathe/on_cut(wire, mob/user, mend)
	var/obj/machinery/modular_fabricator/autolathe/autolathe = holder
	switch(wire)
		if(WIRE_HACK)
			autolathe.hacked = !mend
		if(WIRE_SHOCK)
			autolathe.shocked = !mend
		if(WIRE_DISABLE)
			autolathe.disabled = !mend
		if(WIRE_ZAP)
			if (user)
				autolathe.shock(user, 50)
	ui_update()
