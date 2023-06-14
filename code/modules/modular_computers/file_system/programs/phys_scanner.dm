/datum/computer_file/program/phys_scanner
	filename = "phys_scanner"
	filedesc = "Physical Scanner"
	program_icon_state = "generic"
	category = PROGRAM_CATEGORY_MISC
	extended_desc = "This program allows the tablet to scan physical objects and display a data output."
	size = 8
	usage_flags = PROGRAM_TABLET
	available_on_ntnet = FALSE
	tgui_id = "NtosPhysScanner"
	program_icon = "barcode"
	// Process attack calls from the computer
	use_attack = TRUE
	use_attack_obj = TRUE

	var/current_mode = 0
	var/available_modes = 0

	var/last_record = ""

/datum/computer_file/program/phys_scanner/proc/mode_to_names(mode_holder, use_list = FALSE)
	var/reads = list()
	if(mode_holder & DISK_CHEM)
		reads += "Reagent"
	if(mode_holder & DISK_MED)
		reads += "Health"
	if(mode_holder & DISK_POWER)
		reads += "Radiation"
	if(mode_holder & DISK_ATMOS)
		reads += "Gas"
	if(!length(reads))
		return
	return use_list ? reads : reads[1]

/datum/computer_file/program/phys_scanner/proc/ReadModes()
	return mode_to_names(available_modes, use_list = TRUE)

/datum/computer_file/program/phys_scanner/proc/ReadCurrent()
	return mode_to_names(current_mode)

/datum/computer_file/program/phys_scanner/attack(atom/target, mob/living/user, params)
	switch(current_mode)
		if(DISK_CHEM)
			var/mob/living/carbon/carbon = target
			if(istype(carbon))
				user.visible_message("<span class='notice'>[user] analyzes [carbon]'s vitals.</span>", "<span class='notice'>You analyze [carbon]'s vitals.</span>")
				last_record = chemscan(user, carbon, to_chat = FALSE)
				return FALSE
			else if(!istype(target, /obj/item/reagent_containers/pill/floorpill) && !istype(target, /obj/item/reagent_containers/glass/chem_heirloom))
				if(!isnull(target.reagents))
					if(target.reagents.reagent_list.len > 0)
						var/reagents_length = target.reagents.reagent_list.len
						last_record = "[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.\n"
						for (var/re in target.reagents.reagent_list)
							last_record += "\t [re]\n"
					else
						last_record = "No active chemical agents found in [target]."
				else
					last_record = "No significant chemical agents found in [target]."
				return FALSE
		if(DISK_MED)
			var/mob/living/carbon/carbon = target
			if(istype(carbon))
				user.visible_message("<span class='notice'>[user] analyzes [carbon]'s vitals.</span>", "<span class='notice'>You analyze [carbon]'s vitals.</span>")
				last_record = healthscan(user, carbon, 1, to_chat = FALSE)
				return FALSE
		if(DISK_POWER)
			var/mob/living/carbon/carbon = target
			if(istype(carbon))
				user.visible_message("<span class='notice'>[user] analyzes [carbon]'s radiation levels.</span>", "<span class='notice'>You analyze [carbon]'s radiation levels.</span>")
				last_record = "Analyzing Results for [carbon]:\n"
				if(carbon.radiation)
					last_record += "Radiation Level: [carbon.radiation]%"
				else
					last_record += "No radiation detected."
				return FALSE
	return ..()

/datum/computer_file/program/phys_scanner/attack_obj(obj/target, mob/living/user)
	switch(current_mode)
		if(DISK_ATMOS)
			var/scan_result = atmosanalyzer_scan(user, target, silent = TRUE, to_chat = FALSE)
			if(scan_result)
				user.visible_message("[user] analyzes [icon2html(target, viewers(user))] [target]'s gas contents.", "<span class='notice'>You analyze [icon2html(target, user)] [target]'s gas contents.</span>")
				last_record = scan_result
				return FALSE
	return ..()

/datum/computer_file/program/phys_scanner/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("selectMode")
			switch(params["newMode"])
				if("Reagent")
					current_mode = DISK_CHEM
				if("Health")
					current_mode = DISK_MED
				if("Radiation")
					current_mode = DISK_POWER
				if("Gas")
					current_mode = DISK_ATMOS

	return UI_UPDATE


/datum/computer_file/program/phys_scanner/ui_data(mob/user)
	var/list/data = list()

	data["set_mode"] = ReadCurrent()
	data["last_record"] = last_record
	data["available_modes"] = ReadModes()

	return data
