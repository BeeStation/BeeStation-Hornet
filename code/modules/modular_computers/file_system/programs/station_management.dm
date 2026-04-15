/// Global cooldown tracker for job slot changes (shared across all consoles)
GLOBAL_VAR_INIT(time_last_changed_position, 0)

/datum/computer_file/program/station_management
	filename = "station_mgmt"
	filedesc = "Station Management"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Comprehensive station management program for heads of staff. Manage crew access, salary, job assignments, and job slots."
	transfer_access = list(ACCESS_HEADS)
	available_on_ntnet = TRUE
	size = 12
	tgui_id = "NtosStationManagement"
	program_icon = "building"
	hardware_requirement = MC_CARD
	power_consumption = 80 WATT

	var/authenticated = FALSE
	/// Bitflag of departments the authenticated user can modify
	var/accessible_region_bitflag = NONE
	/// TRUE if user has universal access
	var/has_change_ids = FALSE
	/// The currently selected crew bank account
	var/datum/bank_account/selected_account = null
	/// Tracks positions opened by this console (for instant re-closing)
	var/list/opened_positions = list()

/// Resets all authentication state. Called on logout, card removal, and program kill.
/datum/computer_file/program/station_management/proc/reset_auth()
	authenticated = FALSE
	accessible_region_bitflag = NONE
	has_change_ids = FALSE
	selected_account = null

/datum/computer_file/program/station_management/kill_program(forced = FALSE)
	reset_auth()
	return ..()

/datum/computer_file/program/station_management/event_idremoved(background)
	reset_auth()
	return ..()

// --- Authentication ---

/// Reads the auth card and derives access from it. Returns TRUE if authenticated.
/// Called on login and before every authenticated action to ensure permissions stay current.
/datum/computer_file/program/station_management/proc/check_auth()
	reset_auth()

	if(!computer)
		return FALSE

	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	if(!card_slot?.stored_card)
		return FALSE

	var/list/card_access = card_slot.stored_card.GetAccess()

	// Captain or CentCom: full control
	if((ACCESS_CHANGE_IDS in card_access) || (ACCESS_CENT_GENERAL in card_access))
		has_change_ids = TRUE
		accessible_region_bitflag = ALL
		authenticated = TRUE
		return TRUE

	// Department heads: control their own departments
	if(ACCESS_HOP in card_access)
		accessible_region_bitflag |= (DEPT_BITFLAG_SRV | DEPT_BITFLAG_CIV | DEPT_BITFLAG_CAR)
	if(ACCESS_HOS in card_access)
		accessible_region_bitflag |= DEPT_BITFLAG_SEC
	if(ACCESS_CMO in card_access)
		accessible_region_bitflag |= DEPT_BITFLAG_MED
	if(ACCESS_RD in card_access)
		accessible_region_bitflag |= DEPT_BITFLAG_SCI
	if(ACCESS_CE in card_access)
		accessible_region_bitflag |= DEPT_BITFLAG_ENG

	if(accessible_region_bitflag != NONE)
		authenticated = TRUE
		return TRUE

	return FALSE

/datum/computer_file/program/station_management/ui_static_data(mob/user)
	var/list/data = list()

	// Region data (department -> access list)
	var/list/regions = list()
	for(var/datum/department_group/each_dept in SSdepartment.sorted_department_for_access)
		if(!length(each_dept.access_list) || each_dept.access_filter)
			continue

		var/list/accesses = list()
		for(var/access in each_dept.access_list)
			var/desc = get_access_desc(access)
			if(desc)
				accesses += list(list(
					"desc" = replacetext(desc, "&nbsp", " "),
					"ref" = access,
				))

		regions += list(list(
			"name" = each_dept.access_group_name,
			"regid" = each_dept.dept_bitflag,
			"accesses" = accesses,
		))

	data["regions"] = regions

	// Build job list for job assignment (grouped by department)
	var/list/job_groups = list()
	for(var/datum/department_group/dept in SSdepartment.sorted_department_for_access)
		if(!dept.is_station || !length(dept.jobs))
			continue
		var/list/dept_jobs = list()
		for(var/job_name in dept.jobs)
			var/datum/job/found_job = SSjob.GetJob(job_name)
			if(!found_job)
				continue
			dept_jobs += list(list(
				"title" = found_job.title,
			))
		if(length(dept_jobs))
			job_groups += list(list(
				"department" = dept.dept_name,
				"dept_bitflag" = dept.dept_bitflag,
				"jobs" = dept_jobs,
			))

	data["job_groups"] = job_groups

	// Build card trim styles (grouped by department) for the card trim tab
	var/list/trim_styles = list()
	// Each department group gets its trims from the jobs within it, plus a "(Custom)" entry
	for(var/datum/department_group/dept in SSdepartment.sorted_department_for_access)
		if(!dept.is_station || !length(dept.jobs))
			continue
		var/list/dept_trims = list()
		for(var/job_name in dept.jobs)
			var/datum/job/found_job = SSjob.GetJob(job_name)
			if(!found_job)
				continue
			var/card_icon = get_cardstyle_by_jobname(found_job.title)
			if(!card_icon || card_icon == "noname")
				continue
			dept_trims += list(list(
				"name" = found_job.title,
				"icon_state" = card_icon,
			))
		if(length(dept_trims))
			trim_styles += list(list(
				"department" = dept.dept_name,
				"dept_bitflag" = dept.dept_bitflag,
				"trims" = dept_trims,
			))
	// Add an "Unassigned" entry outside departments
	trim_styles += list(list(
		"department" = "Misc",
		"dept_bitflag" = 0,
		"trims" = list(list("name" = "Unassigned", "icon_state" = "id")),
	))
	data["trim_styles"] = trim_styles

	// Config value that doesn't change during a round
	data["cooldown_time"] = CONFIG_GET(number/id_console_jobslot_delay)

	return data

/datum/computer_file/program/station_management/ui_data(mob/user)
	var/list/data = list()

	// Card slot info
	var/obj/item/computer_hardware/card_slot/card_slot = computer?.all_components[MC_CARD]
	var/obj/item/card/id/auth_card = card_slot?.stored_card

	data["has_card"] = !!auth_card
	data["card_name"] = auth_card ? "[auth_card.registered_name] ([auth_card.assignment || "Unassigned"])" : null
	data["authenticated"] = authenticated
	data["has_change_ids"] = has_change_ids
	data["accessible_region_bitflag"] = accessible_region_bitflag

	if(!authenticated)
		return data

	// Determine the operator's own account (from the auth card in the console)
	var/datum/bank_account/operator_account = auth_card?.registered_account

	// Build accounts list, if we've done it right we never send IDs directly :)
	var/list/accounts = list()
	for(var/datum/bank_account/account in SSeconomy.bank_accounts)
		if(account.suspended)
			continue
		// Skip department/budget accounts
		if(istype(account, /datum/bank_account/department))
			continue
		accounts += list(list(
			"name" = account.account_holder,
			"ref" = REF(account),
			"job" = account.account_job?.title || account.custom_assignment || "Unknown",
			"is_operator" = (account == operator_account),
		))
	data["accounts"] = accounts

	// Selected account data
	if(selected_account && !QDELETED(selected_account))
		var/list/selected_data = list()
		selected_data["name"] = selected_account.account_holder
		selected_data["job"] = selected_account.account_job?.title || selected_account.custom_assignment || "Unknown"
		selected_data["ref"] = REF(selected_account)
		selected_data["access"] = selected_account.access.Copy()
		selected_data["suspended"] = selected_account.suspended
		selected_data["immutable"] = selected_account.immutable

		// Payment info, only for station departments (skip nonstation budget accounts like VIP, Welfare, Golem)
		var/list/payment_data = list()
		for(var/dept_id in selected_account.payment_per_department)
			var/datum/bank_account/department/dept_account = SSeconomy.get_budget_account(dept_id)
			if(dept_account?.nonstation_account)
				continue
			payment_data += list(list(
				"dept_id" = dept_id,
				"payment" = selected_account.payment_per_department[dept_id],
				"bonus" = selected_account.bonus_per_department[dept_id],
			))
		selected_data["payment_data"] = payment_data

		// Linked cards info
		var/list/cards_info = list()
		for(var/obj/item/card/id/card in selected_account.bank_cards)
			cards_info += list(list(
				"name" = card.registered_name,
				"assignment" = card.assignment || "Unassigned",
				"icon_state" = card.icon_state,
				"ref" = REF(card),
			))
		selected_data["linked_cards"] = cards_info

		data["selected_account"] = selected_data
	else
		data["selected_account"] = null
		selected_account = null

	// Job slot data (for job management tab)
	var/list/slots = list()
	for(var/datum/job/job in SSjob.occupations)
		if(job.title in SSjob.job_manager_blacklisted)
			continue
		slots += list(list(
			"title" = job.title,
			"current_positions" = job.current_positions,
			"total_positions" = job.total_positions,
			"is_prioritized" = (job.title in SSjob.prioritized_jobs),
		))
	data["slots"] = slots

	// Cooldown stuff
	var/cooldown_time = CONFIG_GET(number/id_console_jobslot_delay)
	var/time_since_last = world.time - GLOB.time_last_changed_position
	data["cooldown_remaining"] = max(0, cooldown_time - (time_since_last / 10))

	return data

/datum/computer_file/program/station_management/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/mob/user = usr

	switch(action)
		// Authentication
		if("PRG_login")
			if(check_auth())
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, TRUE)
				log_id("[key_name(user)] logged into Station Management at [AREACOORD(computer)].") // Is this the right log to use?
			else
				playsound(computer, 'sound/machines/terminal_error.ogg', 50, TRUE)
			return TRUE

		if("PRG_logout")
			playsound(computer, 'sound/machines/terminal_off.ogg', 50, TRUE)
			reset_auth()
			return TRUE

		if("PRG_eject_card")
			var/obj/item/computer_hardware/card_slot/card_slot = computer?.all_components[MC_CARD]
			if(card_slot)
				playsound(computer, 'sound/machines/terminal_eject.ogg', 50, TRUE)
				card_slot.try_eject(user)
				reset_auth()
			return TRUE

	// Everything below requires verified authentication
	if(!check_auth())
		return TRUE

	switch(action)
		// Account Selection from list thingy
		if("PRG_select_account")
			var/ref = params["ref"]
			if(!ref)
				selected_account = null
				return TRUE
			var/datum/bank_account/account = locate(ref) in SSeconomy.bank_accounts
			if(!account || istype(account, /datum/bank_account/department))
				return TRUE
			var/obj/item/computer_hardware/card_slot/auth_slot = computer?.all_components[MC_CARD]
			if(auth_slot?.stored_card?.registered_account == account) // Sike, no embezzling allowed
				deny(user, "You cannot modify your own account.")
				return TRUE
			selected_account = account
			playsound(computer, 'sound/machines/terminal_select.ogg', 30, TRUE)
			return TRUE

		// Access Modification
		if("PRG_toggle_access")
			if(!require_mutable_account(user))
				return TRUE

			var/access_type = text2num(params["access_target"])
			if(!access_type)
				return TRUE

			if(!can_modify_access(access_type))
				deny(user, "You do not have authority to modify that access.")
				return TRUE

			if(access_type in selected_account.access)
				selected_account.access -= access_type
			else
				selected_account.access += access_type

			selected_account.sync_access_to_cards()
			playsound(computer, pick('sound/machines/terminal_button01.ogg', 'sound/machines/terminal_button02.ogg', 'sound/machines/terminal_button03.ogg', 'sound/machines/terminal_button04.ogg'), 30, TRUE)
			selected_account.bank_card_talk("Access updated: [get_access_desc(access_type)].")
			log_id("[key_name(user)] toggled access [get_access_desc(access_type)] ([access_type]) on [selected_account.account_holder]'s account via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_grant_dept")
			if(!require_mutable_account(user))
				return TRUE

			var/dept_bitflag = text2num(params["dept_bitflag"])
			if(!dept_bitflag)
				return TRUE

			if(!has_dept_authority(dept_bitflag))
				deny(user, "You do not have authority over that department.")
				return TRUE

			for(var/datum/department_group/dept in SSdepartment.get_department_by_bitflag(dept_bitflag))
				for(var/access in dept.access_list)
					selected_account.access |= access

			selected_account.sync_access_to_cards()
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, TRUE)
			selected_account.bank_card_talk("Department access granted.")
			log_id("[key_name(user)] granted department access (bitflag [dept_bitflag]) to [selected_account.account_holder] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_revoke_dept")
			if(!require_mutable_account(user))
				return TRUE

			var/dept_bitflag = text2num(params["dept_bitflag"])
			if(!dept_bitflag)
				return TRUE

			if(!has_dept_authority(dept_bitflag))
				deny(user, "You do not have authority over that department.")
				return TRUE

			for(var/datum/department_group/dept in SSdepartment.get_department_by_bitflag(dept_bitflag))
				for(var/access in dept.access_list)
					selected_account.access -= access

			selected_account.sync_access_to_cards()
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, TRUE)
			selected_account.bank_card_talk("Department access revoked.")
			log_id("[key_name(user)] revoked department access (bitflag [dept_bitflag]) from [selected_account.account_holder] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_grant_all")
			if(!has_change_ids || !require_mutable_account(user))
				return TRUE

			selected_account.access = get_all_accesses()
			selected_account.sync_access_to_cards()
			playsound(computer, 'sound/machines/terminal_success.ogg', 50, TRUE)
			selected_account.bank_card_talk("All station access granted.")
			log_id("[key_name(user)] granted ALL access to [selected_account.account_holder] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_revoke_all")
			if(!has_change_ids || !require_mutable_account(user))
				return TRUE

			selected_account.access = list()
			selected_account.sync_access_to_cards()
			playsound(computer, 'sound/machines/terminal_alert.ogg', 50, TRUE)
			selected_account.bank_card_talk("All access revoked.")
			log_id("[key_name(user)] revoked ALL access from [selected_account.account_holder] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_sync")
			if(!selected_account)
				return TRUE

			selected_account.sync_access_to_cards()
			playsound(computer, 'sound/machines/twobeep.ogg', 50, TRUE)
			return TRUE

		// Salary / Payment
		if("PRG_set_salary")
			if(!require_mutable_account(user))
				return TRUE

			var/dept_id = params["dept_id"]
			var/new_salary = text2num(params["value"])

			if(isnull(new_salary) || !dept_id)
				return TRUE

			if(new_salary < 0)
				deny(user, "Salary cannot be negative.")
				return TRUE

			if(!can_modify_payment_dept(dept_id))
				deny(user, "You do not have authority over that department's payroll.")
				return TRUE

			selected_account.payment_per_department[dept_id] = new_salary
			playsound(computer, pick('sound/machines/terminal_button05.ogg', 'sound/machines/terminal_button06.ogg', 'sound/machines/terminal_button07.ogg', 'sound/machines/terminal_button08.ogg'), 30, TRUE)
			selected_account.bank_card_talk("Salary updated in [dept_id]: $[new_salary].")
			log_econ("[key_name(user)] set salary for [selected_account.account_holder] in [dept_id] to [new_salary] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_set_bonus")
			if(!require_mutable_account(user))
				return TRUE

			var/dept_id = params["dept_id"]
			var/new_bonus = text2num(params["value"])

			if(isnull(new_bonus) || !dept_id)
				return TRUE

			if(!can_modify_payment_dept(dept_id))
				deny(user, "You do not have authority over that department's payroll.")
				return TRUE

			selected_account.bonus_per_department[dept_id] = new_bonus
			playsound(computer, pick('sound/machines/terminal_button05.ogg', 'sound/machines/terminal_button06.ogg', 'sound/machines/terminal_button07.ogg', 'sound/machines/terminal_button08.ogg'), 30, TRUE)
			selected_account.bank_card_talk("Bonus updated in [dept_id]: $[new_bonus].")
			log_econ("[key_name(user)] set bonus for [selected_account.account_holder] in [dept_id] to [new_bonus] via Station Management at [AREACOORD(computer)].")
			return TRUE

		// Job Assignment
		if("PRG_set_job")
			if(!require_mutable_account(user))
				return TRUE

			var/new_job_title = params["job_title"]
			if(!new_job_title)
				return TRUE

			var/datum/job/target_job = SSjob.GetJob(new_job_title)
			if(!target_job)
				playsound(computer, 'sound/machines/terminal_error.ogg', 50, TRUE)
				return TRUE

			if(!can_modify_job(target_job))
				deny(user, "You do not have authority to assign that job.")
				return TRUE

			// Apply job defaults: access, payments, departments, job ref
			selected_account.access = target_job.get_access()
			for(var/dept_key in selected_account.payment_per_department)
				selected_account.payment_per_department[dept_key] = 0

			for(var/dept_key in target_job.payment_per_department)
				selected_account.payment_per_department[dept_key] = target_job.payment_per_department[dept_key]

			selected_account.active_departments = target_job.bank_account_department
			selected_account.account_job = target_job
			selected_account.custom_assignment = null

			// Sync everything to cards, manifest, and HUD
			selected_account.sync_access_to_cards()
			update_all_card_trims(selected_account, get_cardstyle_by_jobname(target_job.title), get_hud_by_jobname(target_job.title))
			GLOB.manifest.modify(selected_account.account_holder, target_job.title, get_hud_by_jobname(target_job.title))

			playsound(computer, 'sound/machines/terminal_success.ogg', 50, TRUE)
			selected_account.bank_card_talk("Job assignment updated: [target_job.title].", TRUE)
			log_id("[key_name(user)] assigned [selected_account.account_holder] to [target_job.title] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_set_custom_assignment")
			if(!require_mutable_account(user))
				return TRUE

			var/custom_title = sanitize(params["custom_title"])
			if(!custom_title || length(custom_title) > 42)
				return TRUE

			selected_account.custom_assignment = custom_title
			selected_account.sync_access_to_cards()
			GLOB.manifest.modify(selected_account.account_holder, custom_title, JOB_HUD_UNKNOWN)

			playsound(computer, 'sound/machines/terminal_success.ogg', 50, TRUE)
			selected_account.bank_card_talk("Assignment updated: [custom_title].", TRUE)
			log_id("[key_name(user)] set custom assignment '[custom_title]' on [selected_account.account_holder] via Station Management at [AREACOORD(computer)].")
			return TRUE

		// --- Card Trim (visual only) ---
		if("PRG_set_card_trim")
			if(!require_mutable_account(user))
				return TRUE

			var/card_ref = params["card_ref"]
			var/trim_name = params["trim_name"]
			if(!card_ref || !trim_name)
				return TRUE

			var/obj/item/card/id/target_card = locate(card_ref) in selected_account.bank_cards
			if(!target_card)
				return TRUE

			var/new_icon_state = get_cardstyle_by_jobname(trim_name)
			if(!new_icon_state || new_icon_state == "noname")
				return TRUE

			var/new_hud_state = get_hud_by_jobname(trim_name)

			// "Unassigned" is always allowed; otherwise check department authority
			if(trim_name != "Unassigned" && !has_change_ids)
				var/datum/job/trim_job = SSjob.GetJob(trim_name)
				if(!trim_job || !can_modify_job(trim_job))
					deny(user, "You do not have authority to apply that card trim.")
					return TRUE

			update_card_trim(target_card, new_icon_state, new_hud_state)
			GLOB.manifest.modify(selected_account.account_holder, target_card.assignment, new_hud_state)

			playsound(computer, 'sound/machines/ping.ogg', 50, TRUE)
			selected_account.bank_card_talk("Card appearance updated: [trim_name].")
			log_id("[key_name(user)] changed card trim for [selected_account.account_holder] to [trim_name] via Station Management at [AREACOORD(computer)].")
			return TRUE

		// --- Card Decommission ---
		if("PRG_decommission_card")
			if(!require_mutable_account(user))
				return TRUE

			var/card_ref = params["card_ref"]
			if(!card_ref)
				return TRUE

			var/obj/item/card/id/target_card = locate(card_ref) in selected_account.bank_cards
			if(!target_card)
				return TRUE

			selected_account.bank_card_talk("A linked card has been decommissioned.", TRUE)
			selected_account.decommission_card(target_card)

			playsound(computer, 'sound/machines/synth_no.ogg', 50, TRUE)
			log_id("[key_name(user)] decommissioned a card from [selected_account.account_holder] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_fire")
			if(!require_mutable_account(user))
				return TRUE

			if(!has_change_ids && selected_account.account_job && !can_modify_job(selected_account.account_job))
				deny(user, "You do not have authority to fire this person.")
				return TRUE

			selected_account.bank_card_talk("You have been terminated from your position.", TRUE)
			selected_account.access = list()

			for(var/dept_key in selected_account.payment_per_department)
				selected_account.payment_per_department[dept_key] = 0
				selected_account.bonus_per_department[dept_key] = 0

			selected_account.active_departments = NONE
			selected_account.account_job = null
			selected_account.custom_assignment = null

			selected_account.sync_access_to_cards()
			update_all_card_trims(selected_account, "id", JOB_HUD_UNKNOWN)

			GLOB.manifest.modify(selected_account.account_holder, "Unassigned", JOB_HUD_UNKNOWN)
			playsound(computer, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			log_id("[key_name(user)] fired [selected_account.account_holder] via Station Management at [AREACOORD(computer)].")
			return TRUE

		// --- Job Slot Management ---
		if("PRG_open_job")
			if(!has_change_ids)
				deny(user, "Only the Captain can modify job slots.")
				return TRUE

			var/job_title = params["job_title"]
			if(!can_modify_job_slot(job_title))
				return TRUE

			var/datum/job/target_job = SSjob.GetJob(job_title)
			if(!target_job || !can_open_job(target_job))
				return TRUE

			target_job.total_position_delta++
			GLOB.time_last_changed_position = world.time
			LAZYSET(opened_positions, job_title, LAZYACCESS(opened_positions, job_title) + 1)
			playsound(computer, 'sound/machines/twobeep_high.ogg', 50, TRUE)
			log_game("[key_name(user)] opened a position for [job_title] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_close_job")
			if(!has_change_ids)
				deny(user, "Only the Captain can modify job slots.")
				return TRUE

			var/job_title = params["job_title"]
			if(!can_modify_job_slot(job_title))
				return TRUE

			var/datum/job/target_job = SSjob.GetJob(job_title)
			if(!target_job || !can_close_job(target_job, job_title))
				return TRUE

			target_job.total_position_delta--
			GLOB.time_last_changed_position = world.time
			if(LAZYACCESS(opened_positions, job_title) > 0)
				opened_positions[job_title]--

			playsound(computer, 'sound/machines/twobeep_high.ogg', 50, TRUE)
			log_game("[key_name(user)] closed a position for [job_title] via Station Management at [AREACOORD(computer)].")
			return TRUE

		if("PRG_prioritize_job")
			if(!has_change_ids)
				deny(user, "Only the Captain can prioritize jobs.")
				return TRUE

			var/job_title = params["job_title"]
			if(!can_modify_job_slot(job_title))
				return TRUE

			var/datum/job/target_job = SSjob.GetJob(job_title)
			if(!target_job)
				return TRUE

			if(target_job.title in SSjob.prioritized_jobs)
				SSjob.prioritized_jobs -= target_job.title
			else
				if(length(SSjob.prioritized_jobs) >= 5)
					deny(user, "Cannot prioritize more than 5 jobs at once.")
					return TRUE
				SSjob.prioritized_jobs += target_job.title

			playsound(computer, 'sound/machines/twobeep_high.ogg', 50, TRUE)
			log_game("[key_name(user)] toggled priority on [job_title] via Station Management at [AREACOORD(computer)].")
			return TRUE

		// Account Creation
		if("PRG_create_account")
			if(!has_change_ids)
				deny(user, "Only the Captain can create new accounts.")
				return TRUE

			var/obj/item/computer_hardware/printer/printer = computer?.all_components[MC_PRINT]
			if(!printer || !printer.can_print())
				deny(user, "A working printer is required to create accounts.")
				return TRUE

			var/new_name = tgui_input_text(user, "Enter name for new account", "New Account", max_length = 42)
			new_name = sanitize(new_name)
			if(!new_name || length(new_name) < 2)
				return TRUE

			if(!check_auth())
				return TRUE

			if(!printer.can_print())
				deny(user, "Printer is no longer available. Account creation aborted.")
				return TRUE

			var/datum/bank_account/department/budget = SSeconomy.get_budget_account(ACCOUNT_CIV_ID)
			if(!budget || !budget.has_money(1000))
				deny(user, "Insufficient civilian budget (requires 1000cr).")
				return TRUE

			budget.adjust_money(-1000)

			var/datum/bank_account/new_account = new(new_name, SSjob.GetJob(JOB_NAME_ASSISTANT))
			selected_account = new_account

			var/receipt_contents = {"<center><b>NANOTRASEN ACCOUNT RECEIPT</b></center>
				<hr>
				<b>Account Holder:</b> [new_account.account_holder]<br>
				<b>Account Number:</b> [new_account.account_id]<br>
				<b>Created:</b> [station_time_timestamp()]<br>
				<hr>
				<i>Keep this document safe. Your account number is required for financial transactions.</i>
				"}

			if(!printer.print_text(receipt_contents, "Account Receipt - [new_account.account_holder]"))
				to_chat(user, span_warning("Account created, but the receipt failed to print. Account number: [new_account.account_id]."))
			else
				computer.visible_message(span_notice("\The [computer] prints out an account receipt."))

			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, TRUE)
			log_id("[key_name(user)] created account for '[new_name]' (ID: [new_account.account_id]) via Station Management at [AREACOORD(computer)].")
			to_chat(user, span_notice("Account created for [new_name]. 1000cr deducted from civilian budget."))
			return TRUE

		//Account Rename
		if("PRG_rename_account")
			if(!has_change_ids || !require_mutable_account(user))
				return TRUE

			var/old_name = selected_account.account_holder
			var/new_name = tgui_input_text(user, "Enter new name for this account", "Rename Account", old_name, max_length = 42)
			new_name = sanitize(new_name)

			if(!new_name || length(new_name) < 2)
				return TRUE

			if(!check_auth())
				return TRUE

			selected_account.account_holder = new_name
			selected_account.sync_access_to_cards()

			var/datum/record/crew/manifest_record = find_record(old_name, GLOB.manifest.general)
			if(manifest_record)
				manifest_record.name = new_name
				SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREW_MANIFEST_UPDATE)

			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, TRUE)
			selected_account.bank_card_talk("Account name updated to: [new_name].", TRUE)
			log_id("[key_name(user)] renamed account '[old_name]' to '[new_name]' via Station Management at [AREACOORD(computer)].")
			return TRUE

		// Account Deletion
		if("PRG_delete_account")
			if(!has_change_ids || !require_mutable_account(user))
				return TRUE

			var/confirm_name = selected_account.account_holder
			selected_account.bank_card_talk("Your account has been deleted.", TRUE)

			for(var/obj/item/card/id/card in selected_account.bank_cards.Copy())
				selected_account.decommission_card(card)

			qdel(selected_account)
			selected_account = null

			playsound(computer, 'sound/machines/terminal_alert.ogg', 50, TRUE)
			log_id("[key_name(user)] deleted account for '[confirm_name]' via Station Management at [AREACOORD(computer)].")
			return TRUE

/// Plays deny sound and shows a warning message to the user.
/datum/computer_file/program/station_management/proc/deny(mob/user, message)
	playsound(computer, 'sound/machines/deniedbeep.ogg', 50, TRUE)
	to_chat(user, span_warning(message))

/// Returns TRUE if selected_account is valid and mutable. Shows error and returns FALSE otherwise.
/datum/computer_file/program/station_management/proc/require_mutable_account(mob/user)
	if(!selected_account)
		return FALSE
	if(selected_account.immutable)
		deny(user, "This account cannot be modified.")
		return FALSE
	return TRUE

/// Returns TRUE if we have authority over the given department bitflag.
/datum/computer_file/program/station_management/proc/has_dept_authority(dept_bitflag)
	return has_change_ids || !!(dept_bitflag & accessible_region_bitflag)

/// Updates a single card's visual trim (icon_state, hud_state) and refreshes the security HUD for its wearer.
/datum/computer_file/program/station_management/proc/update_card_trim(obj/item/card/id/card, new_icon_state, new_hud_state)
	card.icon_state = new_icon_state
	card.hud_state = new_hud_state
	card.update_label()
	card.update_icon()
	card.update_in_pda()
	refresh_sec_hud_for_card(card)

/// Updates the visual trim on ALL linked cards for a given bank account.
/datum/computer_file/program/station_management/proc/update_all_card_trims(datum/bank_account/account, new_icon_state, new_hud_state)
	for(var/obj/item/card/id/card in account.bank_cards)
		update_card_trim(card, new_icon_state, new_hud_state)

/// Refreshes the security HUD overlay for the mob currently wearing the given card (if any).
/// Call this after modifying hud_state on an ID card to make the change visible immediately.
/datum/computer_file/program/station_management/proc/refresh_sec_hud_for_card(obj/item/card/id/card)
	// Walk up the loc chain: card may be held directly, inside a wallet/PDA, or inside a card_slot inside a PDA
	var/mob/living/carbon/human/wearer
	var/atom/current = card.loc
	// Walk up at most 3 levels (card_slot -> modular_computer -> human, or wallet -> human, etc.)
	for(var/depth in 1 to 3)
		if(!current)
			break
		if(ishuman(current))
			wearer = current
			break
		current = current.loc
	if(wearer?.wear_id)
		wearer.sec_hud_set_ID()

/// Checks whether we can modify a specific access type
/datum/computer_file/program/station_management/proc/can_modify_access(access_type)
	if(has_change_ids)
		return TRUE
	for(var/datum/department_group/dept in SSdepartment.sorted_department_for_access)
		if(dept.access_filter)
			continue
		if(access_type in dept.access_list)
			return !!(dept.dept_bitflag & accessible_region_bitflag)
	return FALSE

/// Checks whether we can modify payment for a given department
/datum/computer_file/program/station_management/proc/can_modify_payment_dept(dept_id)
	var/datum/bank_account/department/dept_account = SSeconomy.get_budget_account(dept_id)
	if(dept_account?.nonstation_account)
		return FALSE
	if(has_change_ids)
		return TRUE
	for(var/datum/department_group/dept in SSdepartment.sorted_department_for_access)
		if(dept.dept_id == dept_id)
			return !!(dept.dept_bitflag & accessible_region_bitflag)
	return FALSE

/// Checks whether we can assign/modify a job
/datum/computer_file/program/station_management/proc/can_modify_job(datum/job/target_job)
	if(has_change_ids)
		return TRUE
	return !!(target_job.bank_account_department & accessible_region_bitflag)

/// Checks whether a job slot can be modified (not blacklisted, cooldown OK)
/datum/computer_file/program/station_management/proc/can_modify_job_slot(job_title)
	if(job_title in SSjob.job_manager_blacklisted)
		to_chat(usr, span_warning("[job_title] cannot be modified."))
		return FALSE
	var/cooldown_time = CONFIG_GET(number/id_console_jobslot_delay)
	if((world.time - GLOB.time_last_changed_position) < cooldown_time SECONDS)
		to_chat(usr, span_warning("Job slot changes are on cooldown. Please wait."))
		return FALSE
	return TRUE

/// Can we open another position for this job?
/datum/computer_file/program/station_management/proc/can_open_job(datum/job/checked_job)
	if(checked_job.total_positions < 0) // Unlimited
		return FALSE
	// Max relative positions = 30% of current player count, minimum 2
	var/max_positions = max(2, round(GLOB.clients.len * 0.3))
	if(checked_job.total_positions >= (checked_job.current_positions + max_positions))
		return FALSE
	return TRUE

/// Can we close a position for this job?
/datum/computer_file/program/station_management/proc/can_close_job(datum/job/checked_job, job_title)
	if(checked_job.total_positions < 0) // Unlimited, can't close
		return FALSE
	if(checked_job.total_positions <= 0) // Already at 0
		return FALSE
	// Can always instantly re-close positions we opened
	if(LAZYACCESS(opened_positions, job_title) > 0)
		return TRUE
	// Otherwise can't close below current occupants
	if(checked_job.total_positions <= checked_job.current_positions)
		return FALSE
	return TRUE
