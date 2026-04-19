/datum/computer_file/program/card_mod
	filename = "cardmod"
	filedesc = "ID Card Modification"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program for programming employee ID cards to access parts of the station."
	transfer_access = list(ACCESS_HEADS)
	size = 8
	tgui_id = "NtosCard"
	program_icon = "id-card"
	hardware_requirement = MC_CARD2
	power_consumption = 80 WATT



	var/is_centcom = FALSE
	var/minor = FALSE
	var/authenticated = FALSE
	var/accessible_region_bitflag = NONE
	///Which departments this computer has access to. Defined as access regions. null = all departments
	var/department_bitflag

/datum/computer_file/program/card_mod/New(obj/item/modular_computer/comp)
	. = ..()

/datum/computer_file/program/card_mod/proc/authenticate(mob/user, obj/item/card/id/manager_card)
	if(!manager_card)
		return

	accessible_region_bitflag = NONE
	authenticated = FALSE
	if(ACCESS_CHANGE_IDS in manager_card.access)
		if(department_bitflag)
			minor = TRUE
			accessible_region_bitflag |= department_bitflag
		else
			minor = FALSE
			accessible_region_bitflag |= ALL
	else
		minor = TRUE
		if((ACCESS_HOP in manager_card.access) && ((department_bitflag & DEPT_BITFLAG_SRV) || !department_bitflag))
			accessible_region_bitflag |= DEPT_BITFLAG_SRV | DEPT_BITFLAG_CIV | DEPT_BITFLAG_CAR
		if((ACCESS_HOS in manager_card.access) && ((department_bitflag & DEPT_BITFLAG_SEC) || !department_bitflag))
			accessible_region_bitflag |= DEPT_BITFLAG_SEC
		if((ACCESS_CMO in manager_card.access) && ((department_bitflag & DEPT_BITFLAG_MED) || !department_bitflag))
			accessible_region_bitflag |= DEPT_BITFLAG_MED
		if((ACCESS_RD in manager_card.access) && ((department_bitflag & DEPT_BITFLAG_SCI) || !department_bitflag))
			accessible_region_bitflag |= DEPT_BITFLAG_SCI
		if((ACCESS_CE in manager_card.access) && ((department_bitflag & DEPT_BITFLAG_ENG) || !department_bitflag))
			accessible_region_bitflag |= DEPT_BITFLAG_ENG

	if(accessible_region_bitflag)
		authenticated = TRUE
		update_static_data(user)
		return TRUE

	return FALSE

/datum/computer_file/program/card_mod/ui_act(action, params)
	if(..())
		return TRUE

	if(!computer)
		return

	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = computer.all_components[MC_CARD2]
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	if(!card_slot || !card_slot2)
		return

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = card_slot.stored_card
	var/obj/item/card/id/target_id_card = card_slot2.stored_card

	switch(action)
		if("PRG_authenticate")
			if(!user_id_card)
				playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
				return
			if(authenticate(user, user_id_card))
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				return TRUE
		if("PRG_logout")
			authenticated = FALSE
			playsound(computer, 'sound/machines/terminal_off.ogg', 50, FALSE)
			return TRUE
		if("PRG_print")
			if(!printer)
				return
			if(!authenticated)
				return
			var/contents = {"<h4>Access Report</h4>
						<u>Prepared By:</u> [user_id_card && user_id_card.registered_name ? user_id_card.registered_name : "Unknown"]<br>
						<u>For:</u> [target_id_card.registered_name ? target_id_card.registered_name : "Unregistered"]<br>
						<hr>
						<u>Assignment:</u> [target_id_card.assignment]<br>
						<u>Access:</u><br>
						"}

			var/known_access_rights = get_all_accesses()
			for(var/A in target_id_card.access)
				if(A in known_access_rights)
					contents += "  [get_access_desc(A)]"

			if(!printer.print_text(contents,"access report"))
				to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
				return
			else
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				computer.visible_message(span_notice("\The [computer] prints out a paper."))
			return TRUE
		if("PRG_eject")
			if(!card_slot2)
				return
			if(target_id_card)
				GLOB.manifest.modify(target_id_card.registered_name, target_id_card.assignment, target_id_card.hud_state)
				return card_slot2.try_eject(user)
			else
				var/obj/item/I = user.get_active_held_item()
				if(istype(I, /obj/item/card/id))
					return card_slot2.try_insert(I, user)
			return FALSE
		if("PRG_terminate")
			if(!authenticated)
				return

			target_id_card.access -= get_all_centcom_access() + get_all_accesses()
			target_id_card.assignment = "Unassigned"
			target_id_card.update_label()
			log_id("[key_name(usr)] unassigned and stripped all access from [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		if("PRG_edit")
			if(!authenticated || !target_id_card)
				return

			// Sanitize the name first. We're not using the full sanitize_name proc as ID cards can have a wider variety of things on them that
			// would not pass as a formal character name, but would still be valid on an ID card created by a player.
			var/new_name = sanitize(params["name"])
			// However, we are going to reject bad names overall including names with invalid characters in them, while allowing numbers.
			new_name = reject_bad_name(new_name, allow_numbers = TRUE)

			if(!new_name)
				to_chat(usr, span_notice("Software error: The ID card rejected the new name as it contains prohibited characters."))
				return
			log_id("[key_name(usr)] changed [target_id_card] name to '[new_name]', using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			target_id_card.registered_name = new_name
			target_id_card.update_label()
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		if("PRG_assign")
			if(!authenticated || !target_id_card)
				return
			var/target = params["assign_target"]
			if(!target)
				return

			if(target == "Custom")
				// Sanitize the custom assignment name first.
				var/custom_name = sanitize(params["custom_name"])
				// However, we are going to assignments containing bad text overall.
				custom_name = reject_bad_text(custom_name)
				if(!custom_name)
					to_chat(usr, span_notice("Software error: The ID card rejected the new custom assignment as it contains prohibited characters."))
				else
					log_id("[key_name(usr)] assigned a custom assignment '[custom_name]' to [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
					target_id_card.assignment = custom_name
					target_id_card.update_label()
			else
				if(minor)
					return
				var/datum/job/jobdatum
				jobdatum = SSjob.GetJob(target)
				if(!jobdatum)
					to_chat(usr, span_warning("No log exists for this job."))
					stack_trace("bad job string '[target]' is given through a portable ID console program by '[ckey(usr)]'")
					playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
					return

				target_id_card.access -= get_all_accesses()
				target_id_card.access |= jobdatum.get_access()

				// tablet program doesn't change bank/manifest status. check 'card.dm' for the detail

				log_id("[key_name(usr)] changed [target_id_card] assignment to '[target]', manipulating it to the default access of the job using [user_id_card] via a portable ID console at [AREACOORD(usr)].")

				target_id_card.assignment = target
				target_id_card.update_label()

			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_access")
			if(!authenticated)
				return
			var/access_type = text2num(params["access_target"])
			if(!is_centcom && (access_type in get_all_centcom_admin_access()))
				log_id("[key_name(usr)] somehow attempted to manipulate [get_access_desc(access_type)](CentCom access) of [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)]. This shouldn't happen, and investigate what's going on... This seems to be href exploit.")
				return
			if(access_type in target_id_card.access)
				target_id_card.access -= access_type
				log_id("[key_name(usr)] removed [get_access_desc(access_type)] from [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			else
				target_id_card.access |= access_type
				log_id("[key_name(usr)] added [get_access_desc(access_type)] to [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		if("PRG_grantall")
			if(!authenticated || minor)
				return
			target_id_card.access |= (is_centcom ? get_all_centcom_access()+get_all_accesses() : get_all_accesses())
			log_id("[key_name(usr)] granted All Access to [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_denyall")
			if(!authenticated || minor)
				return
			target_id_card.access -= (is_centcom ? get_all_centcom_access()+get_all_accesses() : get_all_accesses())
			log_id("[key_name(usr)] removed All Access from [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		if("PRG_grantregion")
			if(!authenticated)
				return
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			var/datum/department_group/dept_datum = SSdepartment.get_department_by_bitflag(accessible_region_bitflag)[1]
			target_id_card.access |= dept_datum.access_list
			log_id("[key_name(usr)] granted [dept_datum.access_group_name] regional access to [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_denyregion")
			if(!authenticated)
				return
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			var/datum/department_group/dept_datum = SSdepartment.get_department_by_bitflag(accessible_region_bitflag)[1]
			target_id_card.access -= dept_datum.access_list
			log_id("[key_name(usr)] removed [dept_datum.access_group_name] regional access from [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE



/datum/computer_file/program/card_mod/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = station_name()
	data["centcom_access"] = is_centcom
	data["minor"] = department_bitflag || minor ? TRUE : FALSE

	data["jobs"] = list()
	for(var/datum/department_group/each_dept in SSdepartment.sorted_department_for_access)
		if(!length(each_dept.jobs) || each_dept.access_filter) // no centcom jobs in this code for now
			continue
		var/list/department_jobs = list()
		for(var/each_job in each_dept.jobs)
			if(each_job in SSjob.all_job_exceptions)
				continue
			department_jobs += list(list(
				"display_name" = each_job,
				"job" = each_job
			))
		if(length(department_jobs))
			data["jobs"][each_dept.dept_name] = department_jobs


	var/list/regions = list()
	for(var/datum/department_group/each_dept in SSdepartment.sorted_department_for_access)
		if((minor || department_bitflag) && !(each_dept.dept_bitflag & accessible_region_bitflag))
			continue
		if(!length(each_dept.access_list) || (each_dept.access_filter && !is_centcom))
			continue

		var/list/accesses = list()
		for(var/access in each_dept.access_list)
			if (get_access_desc(access))
				accesses += list(list(
					"desc" = replacetext(get_access_desc(access), "&nbsp", " "),
					"ref" = access,
				))

		regions += list(list(
			"name" = each_dept.access_group_name,
			"regid" = each_dept.dept_bitflag,
			"accesses" = accesses
		))

	data["regions"] = regions

	return data

/datum/computer_file/program/card_mod/ui_data(mob/user)
	var/list/data = list()

	data["station_name"] = station_name()

	var/obj/item/computer_hardware/card_slot/card_slot2
	var/obj/item/computer_hardware/printer/printer

	if(computer)
		card_slot2 = computer.all_components[MC_CARD2]
		printer = computer.all_components[MC_PRINT]
		data["have_id_slot"] = !!(card_slot2)
		data["have_printer"] = !!(printer)
	else
		data["have_id_slot"] = FALSE
		data["have_printer"] = FALSE

	data["authenticated"] = authenticated
	if(!card_slot2)
		return data //We're just gonna error out on the js side at this point anyway

	var/obj/item/card/id/id_card = card_slot2.stored_card
	data["has_id"] = !!id_card
	data["id_name"] = id_card ? id_card.name : "-----"
	if(id_card)
		data["id_rank"] = id_card.assignment ? id_card.assignment : "Unassigned"
		data["id_owner"] = id_card.registered_name ? id_card.registered_name : "-----"
		data["access_on_card"] = id_card.access

	return data
