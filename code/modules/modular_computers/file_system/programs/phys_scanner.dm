/datum/computer_file/program/phys_scanner
	filename = "phys_scanner"
	filedesc = "Physical Scanner"
	program_icon_state = "comm_monitor"
	category = PROGRAM_CATEGORY_MISC
	extended_desc = "This program allows the tablet to scan physical objects and display a data output."
	size = 4
	available_on_ntnet = FALSE
	tgui_id = "NtosPhysScanner"
	program_icon = "barcode"
	hardware_requirement = MC_SENSORS
	power_consumption = 100 WATT
	/// Information from the last scanned person, to display on the app.
	var/last_record = ""

/datum/computer_file/program/phys_scanner/tap(atom/tapped_atom, mob/living/user, params)
	. = ..()

	if(!iscarbon(tapped_atom))
		return
	var/mob/living/carbon/carbon = tapped_atom
	carbon.visible_message(span_notice("[user] analyzes [tapped_atom]'s vitals."))
	last_record = healthscan(user, carbon, 1, tochat = FALSE)
	var/datum/tgui/active_ui = SStgui.get_open_ui(user, computer)
	if(active_ui)
		active_ui.send_full_update(force = TRUE)

/datum/computer_file/program/phys_scanner/ui_static_data(mob/user)
	var/list/data = list()
	data["last_record"] = last_record
	return data
