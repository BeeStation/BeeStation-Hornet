/datum/computer_file/program/crew_manifest
	filename = "crewmani"
	filedesc = "Crew Manifest"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "crew"
	extended_desc = "Program for viewing and printing the current crew manifest"
	size = 4
	tgui_id = "NtosCrewManifest"
	program_icon = "clipboard-list"
	power_consumption = 20 WATT

/datum/computer_file/program/crew_manifest/ui_static_data(mob/user)
	var/list/data = list()
	data["manifest"] = GLOB.manifest.get_manifest()
	return data

/datum/computer_file/program/crew_manifest/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	if(computer)
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	return data

/datum/computer_file/program/crew_manifest/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	switch(action)
		if("PRG_print")
			if(computer && printer) //This option should never be called if there is no printer
				var/contents = {"<h4>Crew Manifest</h4>
								<br>
								[GLOB.manifest ? GLOB.manifest.get_html(0) : ""]
								"}
				if(!printer.print_text(contents,"crew manifest ([station_time_timestamp()])"))
					to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
					return
				else
					computer.visible_message(span_notice("\The [computer] prints out a paper."))
