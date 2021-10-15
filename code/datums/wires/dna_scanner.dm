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
	var/obj/machinery/dna_scannernew/S = holder
	if(S.panel_open)
		return TRUE

/datum/wires/dna_scanner/get_status()
	var/obj/machinery/dna_scannernew/S = holder
	var/list/status = list()
	status += "A [S.ignore_id ? "yellow" : "purple"] light is on."
	status += "The bolt lights are [S.locked ? "on" : "off"]."
	return status

/datum/wires/dna_scanner/on_pulse(wire)
	var/obj/machinery/dna_scannernew/S = holder
	switch(wire)
		if(WIRE_IDSCAN)
			S.ignore_id = !S.ignore_id
			addtimer(CALLBACK(S, /obj/machinery/dna_scannernew.proc/reset, wire), 1200)
		if(WIRE_BOLTS)
			if(!S.state_open)
				S.locked = !S.locked
		if(WIRE_LIMIT)
			if(iscarbon(usr))
				S.irradiate(usr)
		if(WIRE_OPEN)
			if(S.state_open)
				S.close_machine()
			else if(!S.locked)
				S.open_machine()
		if(WIRE_ZAP1, WIRE_ZAP2)
			if(isliving(usr))
				S.shock(usr, 50)
	ui_update()

/datum/wires/dna_scanner/on_cut(wire, mend)
	var/obj/machinery/dna_scannernew/S = holder
	switch(wire)
		if(WIRE_IDSCAN)
			if(!mend)
				S.ignore_id = TRUE
		if(WIRE_LIMIT)
			if(iscarbon(usr))
				S.irradiate(usr)
		if(WIRE_OPEN)
			if(!mend && !S.state_open)
				S.locked = TRUE
		if(WIRE_ZAP1, WIRE_ZAP2)
			if(isliving(usr))
				S.shock(usr, 90)
	ui_update()
