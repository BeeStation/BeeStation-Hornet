/datum/wires/dna_scanner
	holder_type = /obj/machinery/dna_scannernew
	proper_name = "DNA scanner"

/datum/wires/dna_scanner/New(atom/holder)
	wires = list(
		WIRE_IDSCAN, WIRE_BOLTS, WIRE_OPEN, WIRE_LIMIT, WIRE_ZAP1, WIRE_ZAP2
	)
	add_duds(2)
	..()

/datum/wires/dna_scanner/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/dna_scannernew/S = holder
	if(S.panel_open)
		return TRUE

/datum/wires/dna_scanner/get_status()
	var/obj/machinery/dna_scannernew/S = holder
	var/list/status = list()
	status += "A [S.ignore_id ? "yellow" : "purple"] light is on."
	status += "The bolt lights are [S.locked ? "on" : "off"]."
	return status

/datum/wires/dna_scanner/on_pulse(wire, user)
	var/obj/machinery/dna_scannernew/S = holder
	switch(wire)
		if(WIRE_IDSCAN)
			S.ignore_id = !S.ignore_id
			addtimer(CALLBACK(S, TYPE_PROC_REF(/obj/machinery/dna_scannernew, reset), wire), 1200)
		if(WIRE_BOLTS)
			S.locked = !S.locked
			S.update_icon()
		if(WIRE_OPEN)
			if(!S.locked)
				if(S.state_open)
					S.close_machine()
				else
					S.open_machine()
		if(WIRE_ZAP1, WIRE_ZAP2)
			if(isliving(user))
				S.shock(user, 50)
	ui_update()

/datum/wires/dna_scanner/on_cut(wire, mob/user, mend)
	var/obj/machinery/dna_scannernew/S = holder
	switch(wire)
		if(WIRE_IDSCAN)
			if(!mend)
				S.ignore_id = TRUE
		if(WIRE_OPEN)
			if(!mend)
				S.open_machine()
				if(!is_cut(WIRE_BOLTS))
					S.locked = TRUE
					S.update_icon()
		if(WIRE_ZAP1, WIRE_ZAP2)
			if(isliving(user))
				S.shock(user, 90)
	ui_update()
