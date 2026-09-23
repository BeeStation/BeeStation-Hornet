#define NEW_BANK_ACCOUNT_COST 1000

//Keeps track of the time for the ID console. Having it as a global variable prevents people from dismantling/reassembling it to
//increase the slots of many jobs.
GLOBAL_VAR_INIT(time_last_changed_position, 0)

/obj/machinery/computer/card
	name = "identification console"
	desc = "You can use this to manage jobs and ID access."
	icon_screen = "id"
	icon_keyboard = "generic_key"
	req_one_access = list(ACCESS_HEADS, ACCESS_CHANGE_IDS)
	circuit = /obj/item/circuitboard/computer/card
	var/mode = 0
	var/printing = null
	var/department_bitflag = NONE // NONE = All department, or department bitflag. Only access for that department will be shown
	var/available_paycheck_departments = list()
	var/target_paycheck = ACCOUNT_SRV_ID

	//Cooldown for closing positions in seconds
	//if set to -1: No cooldown... probably a bad idea
	//if set to 0: Not able to close "original" positions. You can only close positions that you have opened before
	var/change_position_cooldown = 30

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list()
	var/obj/item/card/id/inserted_scan_id
	var/obj/item/card/id/inserted_modify_id
	var/accessible_region_bitflag = NONE
	var/accessible_dept_payment_bitflag = NONE
	var/list/head_subordinates = null
	var/is_centcom = FALSE

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/card/Initialize(mapload)
	. = ..()
	change_position_cooldown = CONFIG_GET(number/id_console_jobslot_delay)

	// This determines which department payment list the console will show to you.
	if((department_bitflag & DEPARTMENT_BITFLAG_COMMAND) || !department_bitflag)
		available_paycheck_departments |= list(ACCOUNT_COM_ID)
	if((department_bitflag & DEPARTMENT_BITFLAG_SERVICE) || !department_bitflag)
		available_paycheck_departments |= list(ACCOUNT_CIV_ID, ACCOUNT_SRV_ID, ACCOUNT_CAR_ID)
	if((department_bitflag & DEPARTMENT_BITFLAG_ENGINEERING) || !department_bitflag)
		available_paycheck_departments |= list(ACCOUNT_ENG_ID)
	if((department_bitflag & DEPARTMENT_BITFLAG_SCIENCE) || !department_bitflag)
		available_paycheck_departments |= list(ACCOUNT_SCI_ID)
	if((department_bitflag & DEPARTMENT_BITFLAG_MEDICAL) || !department_bitflag)
		available_paycheck_departments |= list(ACCOUNT_MED_ID)
	if((department_bitflag & DEPARTMENT_BITFLAG_SECURITY) || !department_bitflag)
		available_paycheck_departments |= list(ACCOUNT_SEC_ID)


/obj/machinery/computer/card/examine(mob/user)
	. = ..()
	if(inserted_scan_id || inserted_modify_id)
		. += span_notice("Alt-click to eject the ID card.")

/obj/machinery/computer/card/attackby(obj/I, mob/user, params)
	if(isidcard(I))
		if(check_access(I) && !inserted_scan_id)
			if(id_insert(user, I, inserted_scan_id))
				inserted_scan_id = I
			updateUsrDialog()
		else if(id_insert(user, I, inserted_modify_id))
			inserted_modify_id = I
			updateUsrDialog()
	else
		return ..()

/obj/machinery/computer/card/Destroy()
	if(inserted_scan_id)
		qdel(inserted_scan_id)
		inserted_scan_id = null
	if(inserted_modify_id)
		update_modify_manifest()
		qdel(inserted_modify_id)
		inserted_modify_id = null
	return ..()

/obj/machinery/computer/card/handle_atom_del(atom/A)
	..()
	if(A == inserted_scan_id)
		inserted_scan_id = null
		updateUsrDialog()
	if(A == inserted_modify_id)
		update_modify_manifest()
		inserted_modify_id = null
		updateUsrDialog()

/obj/machinery/computer/card/on_deconstruction()
	if(inserted_scan_id)
		inserted_scan_id.forceMove(drop_location())
		inserted_scan_id = null
	if(inserted_modify_id)
		update_modify_manifest()
		inserted_modify_id.forceMove(drop_location())
		inserted_modify_id = null

//Check if a job's slots can be edited from this console
/obj/machinery/computer/card/proc/can_edit_job(datum/job/job)
	if(!istype(job))
		return FALSE
	if(!(job.job_flags & JOB_CREW_MEMBER))
		return FALSE
	if(job.job_flags & JOB_CANNOT_OPEN_SLOTS)
		return FALSE
	return TRUE

// CentCom is powerful - can edit any crew job except the overflow role
/obj/machinery/computer/card/centcom/can_edit_job(datum/job/job)
	if(!istype(job))
		return FALSE
	return job.type != SSjob.overflow_role

//Logic check for Topic() if you can open the job
/obj/machinery/computer/card/proc/can_open_job(datum/job/job)
	if(!can_edit_job(job))
		return 0
	// Always allow reopening positions that were previously closed from this console
	if(opened_positions[job.title] < 0)
		return 1
	if((job.get_spawn_position_count() <= GLOB.player_list.len * (max_relative_positions / 100)))
		var/delta = (world.time / 10) - GLOB.time_last_changed_position
		if(change_position_cooldown < delta)
			return 1
		return -2
	return -1

//Logic check for Topic() if you can close the job
/obj/machinery/computer/card/proc/can_close_job(datum/job/job)
	if(!can_edit_job(job))
		return 0
	// Always allow reclosing positions that were previously opened from this console
	if(opened_positions[job.title] > 0)
		return 1
	if(job.get_spawn_position_count() > job.current_positions)
		var/delta = (world.time / 10) - GLOB.time_last_changed_position
		if(change_position_cooldown < delta)
			return 1
		return -2
	return -1

/obj/machinery/computer/card/proc/id_insert(mob/user, obj/item/inserting_item, obj/item/target)
	var/obj/item/card/id/card_to_insert = inserting_item
	var/holder_item = FALSE

	if(!isidcard(card_to_insert))
		card_to_insert = inserting_item.RemoveID()
		holder_item = TRUE

	if(!card_to_insert || !user.transferItemToLoc(card_to_insert, src))
		return FALSE

	if(target)
		if(holder_item && inserting_item.InsertID(target))
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		else
			id_eject(user, target)

	user.visible_message(
		span_notice("[user] inserts \the [card_to_insert] into \the [src]."),
		span_notice("You insert \the [card_to_insert] into \the [src]."),
	)
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	updateUsrDialog()
	return TRUE

/obj/machinery/computer/card/proc/id_eject(mob/user, obj/target)
	if(!target)
		to_chat(user, span_warning("That slot is empty!"))
		return FALSE
	else
		if(target == inserted_modify_id)
			update_modify_manifest()
		target.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(target)
		user.visible_message(
			span_notice("[user] gets \the [target] from \the [src]."),
			span_notice("You get \the [target] from \the [src].")
		)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()
		return TRUE

/obj/machinery/computer/card/proc/update_modify_manifest()
	GLOB.manifest.modify(inserted_modify_id.registered_name, inserted_modify_id.assignment, inserted_modify_id.hud_state)

/obj/machinery/computer/card/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)) || !is_operational)
		return
	if(inserted_modify_id)
		if(id_eject(user, inserted_modify_id))
			inserted_modify_id = null
			updateUsrDialog()
			return
	if(inserted_scan_id)
		if(id_eject(user, inserted_scan_id))
			inserted_scan_id = null
			updateUsrDialog()
			return

/obj/machinery/computer/card/ui_interact(mob/user)
	. = ..()

	var/dat
	if(!SSticker)
		return
	if (mode == 1) // accessing crew manifest
		var/crew = ""
		for(var/datum/record/crew/record in sort_record(GLOB.manifest.general))
			crew += record.name + " - " + record.rank + "<br>"
		dat = "<div class='idc-mono'><div class='idc-section'><h4>Crew Manifest</h4><div class='idc-section-body'>Please use security record computer to modify entries.<br><br>[crew]<br><a class='idc-btn' href='byond://?src=[REF(src)];choice=print'>Print</a> <a class='idc-btn' href='byond://?src=[REF(src)];choice=mode;mode_target=0'>Return</a></div></div></div>"

	else if(mode == 2)
		// JOB MANAGEMENT
		dat = "<div class='idc-mono'><a class='idc-btn' href='byond://?src=[REF(src)];choice=return'>Return</a>"
		dat += " Confirm Identity: "
		var/S
		if(inserted_scan_id)
			S = html_encode(inserted_scan_id.name)
		else
			S = "--------"
		dat += "<a href='byond://?src=[REF(src)];choice=inserted_scan_id'>[S]</a>"
		dat += "<div class='idc-section'><h4>Job Management</h4><div class='idc-section-body'>"
		dat += "<table class='idc-deptgrid'>"
		dat += "<colgroup><col class='idc-w25'><col class='idc-w5'><col class='idc-w20'><col class='idc-w20'><col class='idc-w20'></colgroup>"
		dat += "<tr><td><b>Job</b></td><td><b>Slots</b></td><td><b>Open job</b></td><td><b>Close job</b></td><td><b>Prioritize</b></td></tr>"
		var/ID
		if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !department_bitflag)
			ID = 1
		else
			ID = 0
		for(var/datum/job/job in SSjob.all_occupations)
			if(!can_edit_job(job))
				continue
			dat += "<tr>"
			dat += "<td>[job.title]</td>"
			dat += "<td>[job.current_positions]/[job.get_spawn_position_count()]</td>"
			dat += "<td>"
			switch(can_open_job(job))
				if(1)
					if(ID)
						dat += "<a href='byond://?src=[REF(src)];choice=make_job_available;job=[job.title]'>Open Position</a><br>"
					else
						dat += "<span class='idc-disabled'>Open Position</span>"
				if(-1)
					dat += "<span class='idc-disabled'>Denied</span>"
				if(-2)
					var/time_to_wait = round(change_position_cooldown - ((world.time / 10) - GLOB.time_last_changed_position), 1)
					var/mins = round(time_to_wait / 60)
					var/seconds = time_to_wait - (60*mins)
					dat += "<span class='idc-disabled'>Cooldown ongoing: [mins]:[(seconds < 10) ? "0[seconds]" : "[seconds]"]</span>"
				if(0)
					dat += "<span class='idc-disabled'>Denied</span>"
			dat += "</td><td>"
			switch(can_close_job(job))
				if(1)
					if(ID)
						dat += "<a href='byond://?src=[REF(src)];choice=make_job_unavailable;job=[job.title]'>Close Position</a>"
					else
						dat += "<span class='idc-disabled'>Close Position</span>"
				if(-1)
					dat += "<span class='idc-disabled'>Denied</span>"
				if(-2)
					var/time_to_wait = round(change_position_cooldown - ((world.time / 10) - GLOB.time_last_changed_position), 1)
					var/mins = round(time_to_wait / 60)
					var/seconds = time_to_wait - (60*mins)
					dat += "<span class='idc-disabled'>Cooldown ongoing: [mins]:[(seconds < 10) ? "0[seconds]" : "[seconds]"]</span>"
				if(0)
					dat += "<span class='idc-disabled'>Denied</span>"
			dat += "</td><td>"
			switch(job.get_spawn_position_count())
				if(0)
					dat += "<span class='idc-disabled'>Denied</span>"
				else
					if(ID)
						if(job in SSjob.prioritized_jobs)
							dat += "<a href='byond://?src=[REF(src)];choice=prioritize_job;job=[job.title]'>Deprioritize</a>"
						else
							if(SSjob.prioritized_jobs.len < 5)
								dat += "<a href='byond://?src=[REF(src)];choice=prioritize_job;job=[job.title]'>Prioritize</a>"
							else
								dat += "<span class='idc-disabled'>Denied</span>"
					else
						dat += "<span class='idc-disabled'>Prioritize</span>"


			dat += "</td></tr>"
		dat += "</table>"
		dat += "</div></div></div>"
	else if(mode == 3)
		//PAYCHECK MANAGEMENT
		dat = "<div class='idc-mono'><a class='idc-btn' href='byond://?src=[REF(src)];choice=return'>Return</a>"
		dat += " Confirm Identity: "
		var/S
		var/list/paycheck_departments = list()
		if(inserted_scan_id)
			S = html_encode(inserted_scan_id.name)
			//Checking all the accesses and their corresponding departments
			if((ACCESS_HOP in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_SERVICE) || !department_bitflag))
				paycheck_departments |= ACCOUNT_SRV_ID
				paycheck_departments |= ACCOUNT_CIV_ID
				paycheck_departments |= ACCOUNT_CAR_ID //Currently no seperation between service/civillian and supply
			if((ACCESS_HOS in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_SECURITY) || !department_bitflag))
				paycheck_departments |= ACCOUNT_SEC_ID
			if((ACCESS_CMO in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_MEDICAL) || !department_bitflag))
				paycheck_departments |= ACCOUNT_MED_ID
			if((ACCESS_RD in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_SCIENCE) || !department_bitflag))
				paycheck_departments |= ACCOUNT_SCI_ID
			if((ACCESS_CE in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_ENGINEERING) || !department_bitflag))
				paycheck_departments |= ACCOUNT_ENG_ID
		else
			S = "--------"
		dat += "<a href='byond://?src=[REF(src)];choice=inserted_scan_id'>[S]</a><br>"
		dat += "<div class='idc-center'>target department: "
		if(length(paycheck_departments))
			for(var/P in available_paycheck_departments)
				if(SSeconomy.is_nonstation_account(P))
					continue
				dat += "<a href='byond://?src=[REF(src)];choice=set_paycheck_department;paytype=[P]' class='idc-btn[P == target_paycheck ? " active" : ""]'>[P]</a> "
		dat += "</div>"
		dat += "<div class='idc-section'><h4>Paycheck Management</h4><div class='idc-section-body'>"
		dat += "<table class='idc-deptgrid'>"
		dat += "<colgroup><col class='idc-w30'><col class='idc-w20'><col class='idc-w20'><col class='idc-w15'><col class='idc-w15'></colgroup>"
		dat += "<tr><td><b>Name</b></td><td><b>Job</b></td><td><b>Department</b></td><td><b>Paycheck</b></td><td><b>Pay Bonus</b></td></tr>"

		if(length(paycheck_departments))
			for(var/datum/bank_account/B in flatten_list(SSeconomy.bank_accounts_by_id))
				var/datum/record/crew/record = find_record(B.account_holder, GLOB.manifest.general)
				dat += "<tr>"
				dat += "<td>[B.account_holder] [B.suspended ? "(Account closed)" : ""]</td>"
				dat += "<td>[record ? record.rank : "(No data)"]</td>"
				if(!(target_paycheck in paycheck_departments))
					dat += "<td>(Auth-denied)</td>"
				else
					if(B.active_departments & SSeconomy.get_budget_acc_bitflag(target_paycheck))
						dat += "<td><a href='byond://?src=[REF(src)];choice=turn_on_off_department_bank;bank_account=[B.account_id];check_card=1'>[span_good("Free Vendor Access")]</a></td>"
					else
						dat += "<td><a href='byond://?src=[REF(src)];choice=turn_on_off_department_bank;bank_account=[B.account_id];check_card=1;paycheck_t=[target_paycheck]'>No Free Vendor Access</a></td>"
				if(B.suspended)
					dat += "<td>Closed</td>"
					dat += "<td>$0</td>"
				else if(!(target_paycheck in paycheck_departments))
					dat += "<td>[B.payment_per_department[target_paycheck]] cr (Auth-denied)</td>"
					dat += "<td>[B.bonus_per_department[target_paycheck]] cr</td>"
				else
					dat += "<td><a href='byond://?src=[REF(src)];choice=adjust_pay;paycheck_t=[target_paycheck];bank_account=[B.account_id]'>[B.payment_per_department[target_paycheck]] cr</a></td>"
					dat += "<td><a href='byond://?src=[REF(src)];choice=adjust_bonus;paycheck_t=[target_paycheck];bank_account=[B.account_id]'>[B.bonus_per_department[target_paycheck]] cr</a></td>"
				dat += "</tr>"
		dat += "</table>"
		dat += "</div></div></div>"
	else
		var/header = ""

		var/scan_name = inserted_scan_id ? html_encode(inserted_scan_id.name) : "--------"
		var/target_name = inserted_modify_id ? html_encode(inserted_modify_id.name) : "--------"
		var/target_owner = (inserted_modify_id && inserted_modify_id.registered_name) ? html_encode(inserted_modify_id.registered_name) : "--------"
		var/target_rank = (inserted_modify_id && inserted_modify_id.assignment) ? html_encode(inserted_modify_id.assignment) : "Unassigned"

		header += "<div class='idc-section'><h4>Console Status</h4><div class='idc-section-body'>"
		if(!authenticated)
			header += "<i>Please insert the cards into the slots</i><br>"
			header += "Target: <a href='byond://?src=[REF(src)];choice=inserted_modify_id'>[target_name]</a><br>"
			header += "Confirm Identity: <a href='byond://?src=[REF(src)];choice=inserted_scan_id'>[scan_name]</a><br>"
		else
			header += "<div class='idc-center'>"
			header += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=inserted_modify_id'>Remove [target_name]</a> "
			header += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=inserted_scan_id'>Remove [scan_name]</a> <br> "
			header += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=mode;mode_target=1'>Access Crew Manifest</a> "
			header += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=logout'>Log Out</a></div>"
		header += "</div></div>"

		var/list/job_cards = list()
		for(var/datum/department_group/each_dept in SSdepartment.sorted_department_for_access)
			if(!length(each_dept.department_jobs) || each_dept.access_filter) // no centcom jobs for now
				continue
			var/job_items = ""
			var/job_count = 0
			for(var/datum/job/each_job in each_dept.department_jobs)
				if(each_job.title in SSjob.all_job_exceptions)
					continue
				job_count++
				var/is_current_job = (each_job.title == target_rank)
				var/job_style = is_current_job ? "" : " style='border-left-color:[each_dept.dept_colour]'"
				job_items += "<a class='idc-jobitem[is_current_job ? " current" : ""]'[job_style] href='byond://?src=[REF(src)];choice=assign;assign_target=[each_job.title]'>[each_job.title]</a>" //make sure there isn't a line break in the middle of a job
			if(!job_count) // skip empty card
				continue
			var/card_html = "<div class='idc-dept' style='border-top-color:[each_dept.dept_colour]'>"
			card_html += "<div class='idc-dept-head'>[each_dept.department_name]<span class='idc-dept-count'>[job_count]</span></div>"
			card_html += job_items
			card_html += "</div>"
			job_cards += list(list("html" = card_html, "weight" = job_count + 2))
		var/jobs_all = render_department_columns(job_cards)
		jobs_all += "<div class='idc-job-extras'>"
		jobs_all += "<a class='idc-jobitem idc-job-extra[target_rank == "Unassigned" ? " current" : ""]' href='byond://?src=[REF(src)];choice=assign;assign_target=Unassigned'>Unassigned</a> <a class='idc-jobitem idc-job-extra' href='byond://?src=[REF(src)];choice=assign;assign_target=Custom'>Custom</a>"
		jobs_all += "</div>"


		var/body

		if (authenticated && inserted_modify_id)

			var/carddesc = ""
			var/jobs = ""
			if( authenticated == 2)
				carddesc += {"<script type="text/javascript">
									function markRed(){
										var nameField = document.getElementById('namefield');
										nameField.style.backgroundColor = "#5a2a2a";
									}
									function showAll(){
										var allJobsSlot = document.getElementById('alljobsslot');
										allJobsSlot.innerHTML = "<a class='idc-badge idc-badge-toggle' href='#' onclick='hideAll()'>hide</a>"+ "[jobs_all]";
									}
									function hideAll(){
										var allJobsSlot = document.getElementById('alljobsslot');
										allJobsSlot.innerHTML = "<a class='idc-badge idc-badge-toggle' href='#' onclick='showAll()'>show</a>";
									}
								</script>"}
				carddesc += "<form name='cardcomp' action='byond://?src=[REF(src)]' method='get'>"
				carddesc += "<input type='hidden' name='src' value='[REF(src)]'>"
				carddesc += "<input type='hidden' name='choice' value='reg'>"
				carddesc += "<b>registered name:</b> <input class='idc-input' type='text' id='namefield' name='reg' value='[target_owner]' style='width:250px;' onchange='markRed()'>"
				carddesc += "<input class='idc-btn' type='submit' value='Rename'>"
				carddesc += "</form>"
				carddesc += "<b>Assignment:</b> "

				jobs += "<span id='alljobsslot'><a class='idc-badge idc-badge-toggle' href='#' onclick='showAll()'>[target_rank]</a></span>" //CHECK THIS

			else
				carddesc += "<b>registered name:</b> [target_owner]"
				jobs += "<b>Assignment:</b> <span class='idc-badge'>[target_rank]</span> (<a href='byond://?src=[REF(src)];choice=demote'>Demote</a>)"

			// Each bank attribute is its own department card, bin-packed into columns.
			var/list/bank_cards = list()
			var/dept_weight = length(available_paycheck_departments) + 2

			// Department manifest membership toggles.
			var/datum/record/crew/record = find_record(inserted_modify_id.registered_name, GLOB.manifest.general)
			var/manifest_body = ""
			if(record)
				for(var/each in available_paycheck_departments)
					if(!(SSeconomy.get_budget_acc_bitflag(each) & accessible_dept_payment_bitflag))
						continue
					var/granted = (record.active_department & SSeconomy.get_budget_acc_bitflag(each))
					manifest_body += "<a class='idc-access-item[granted ? " granted" : ""]' href='byond://?src=[REF(src)];choice=turn_on_off_department_manifest;target_bitflag=[SSeconomy.get_budget_acc_bitflag(each)]'>[each]</a>"
			else
				manifest_body += span_bad("<b>Error: Cannot locate user entry in data core</b>")
			bank_cards += list(list("html" = idc_bank_card("Active Department Manifest", manifest_body), "weight" = dept_weight))

			//adjustable only when they have bank account in their card
			var/datum/bank_account/B = inserted_modify_id?.registered_account
			if(B)
				// Bank vendor free status - lets you buy department stuff for free.
				var/vendor_body = ""
				for(var/each in available_paycheck_departments)
					if(!(SSeconomy.get_budget_acc_bitflag(each) & accessible_dept_payment_bitflag))
						continue
					var/granted = (B.active_departments & SSeconomy.get_budget_acc_bitflag(each))
					vendor_body += "<a class='idc-access-item[granted ? " granted" : ""]' href='byond://?src=[REF(src)];choice=turn_on_off_department_bank;paycheck_t=[each]'>[each]</a>"
				bank_cards += list(list("html" = idc_bank_card("Free Vendor Access", vendor_body), "weight" = dept_weight))

				// Payment per department - not a toggle, so plain bars.
				var/pay_body = ""
				for(var/each in available_paycheck_departments)
					if(!(SSeconomy.get_budget_acc_bitflag(each) & accessible_dept_payment_bitflag))
						continue
					if(SSeconomy.is_nonstation_account(each))
						pay_body += "<span class='idc-jobitem'>[each]: [B.payment_per_department[each]] cr</span>"
						continue
					pay_body += "<a class='idc-jobitem' href='byond://?src=[REF(src)];choice=adjust_pay;paycheck_t=[each]'>[each]: [B.payment_per_department[each]] cr</a>"
				bank_cards += list(list("html" = idc_bank_card("Payment per department", pay_body), "weight" = dept_weight))
			else
				bank_cards += list(list("html" = idc_bank_card("Banking information", span_bad("<b>Error: No linked bank account detected</b>")), "weight" = 3))

			var/banking = "<div class='idc-section'><h4>Department & Bank Status</h4><div class='idc-section-body'>"
			banking += render_department_columns(bank_cards, length(bank_cards))
			banking += "</div></div>"

			// Refresh these with byjax to prevent arbitrary page refreshes
			var/accesses = "<div id='idc_accesses'>[get_accesses_html()]</div>"
			body = "<div class='idc-section'><h4>Identity & Assignment</h4><div class='idc-section-body'>[carddesc]<br>[jobs]</div></div>[banking][accesses]" //CHECK THIS

		else
			body = "<div class='idc-section'><h4>Console Menu</h4><div class='idc-section-body'>"
			body += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=auth'>Log in</a><hr>"
			body += "<div class='idc-menu'>"
			body += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=mode;mode_target=1'>Access Crew Manifest</a>"
			if(!department_bitflag)
				body += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=mode;mode_target=2'>Job Management</a>"
			body += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=mode;mode_target=3'>Paycheck Management</a>"
			if(!department_bitflag) // currently locked in HoP console only. other console can make bank account with their own budget if this lock is removed
				body += "<a class='idc-btn' href='byond://?src=[REF(src)];choice=open_new_account'>Open a new bank account</a>"
			body += "</div></div></div>"

		dat = "<div class='idc-mono'>[header][body]<hr><br></div>"
	var/datum/browser/popup = new(user, "id_com", src.name, 1050, 700)
	// byjax pushes in-place access grid updates from Topic (see "access").
	popup.add_head_content({"<script type="text/javascript">[js_byjax]</script>"})
	popup.add_stylesheet("idcard", 'html/browser/idcard.css')
	popup.set_content(dat)
	popup.open()

/// Builds the access grid, split so byjax can refesgh
/obj/machinery/computer/card/proc/get_accesses_html()
	if(!(authenticated && inserted_modify_id))
		return ""
	var/list/access_cards = list()
	for(var/datum/department_group/each_dept in SSdepartment.sorted_department_for_access)
		if(authenticated == 1 && !(each_dept.department_bitflags & accessible_region_bitflag))
			continue
		if(!length(each_dept.access_list) || (!is_centcom && each_dept.access_filter))
			continue
		var/card_html = "<div class='idc-dept' style='border-top-color:[each_dept.dept_colour]'>"
		card_html += "<div class='idc-dept-head'>[each_dept.access_group_name]<span class='idc-dept-count'>[length(each_dept.access_list)]</span></div>"
		for(var/each_access in each_dept.access_list)
			if(each_access in inserted_modify_id.access)
				card_html += "<a class='idc-access-item granted' href='byond://?src=[REF(src)];choice=access;access_target=[each_access];allowed=0'>[get_access_desc(each_access)]</a>"
			else
				card_html += "<a class='idc-access-item' style='border-left-color:[each_dept.dept_colour]' href='byond://?src=[REF(src)];choice=access;access_target=[each_access];allowed=1'>[get_access_desc(each_access)]</a>"
		card_html += "</div>"
		access_cards += list(list("html" = card_html, "weight" = length(each_dept.access_list) + 2))

	var/accesses = ""
	accesses += "<div class='idc-section'><h4>Access</h4><div class='idc-section-body'>"
	accesses += render_department_columns(access_cards)
	accesses += "</div></div>"
	return accesses

/obj/machinery/computer/card/proc/render_department_columns(list/cards, column_count = 4)
	if(!length(cards))
		return ""
	var/list/column_html = new(column_count)
	var/list/column_weight = new(column_count)
	for(var/i in 1 to column_count)
		column_html[i] = ""
		column_weight[i] = 0
	var/list/remaining = cards.Copy()
	while(length(remaining))
		// Heaviest card first.
		var/list/pick = remaining[1]
		for(var/list/candidate in remaining)
			if(candidate["weight"] > pick["weight"])
				pick = candidate
		remaining -= list(pick)
		// Drop it into whichever column is currently shortest.
		var/target = 1
		for(var/i in 2 to column_count)
			if(column_weight[i] < column_weight[target])
				target = i
		column_html[target] += pick["html"]
		column_weight[target] += pick["weight"]
	var/width = round(100 / column_count, 1)
	var/out = "<table class='idc-colgrid'><tr>"
	for(var/i in 1 to column_count)
		out += "<td class='idc-col' style='width:[width]%'>[column_html[i]]</td>"
	out += "</tr></table>"
	return out

/// Wraps a bank attribute's bars in the standard department-card shell.
/obj/machinery/computer/card/proc/idc_bank_card(title, body_html)
	return "<div class='idc-dept'><div class='idc-dept-head'>[title]</div>[body_html]</div>"

/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return

	if(!usr.canUseTopic(src, !issilicon(usr)) || !is_operational)
		usr.unset_machine()
		usr << browse(null, "window=id_com")
		return

	usr.set_machine(src)
	switch(href_list["choice"])
		if ("inserted_modify_id")
			if(inserted_modify_id && !usr.get_active_held_item())
				if(id_eject(usr, inserted_modify_id))
					inserted_modify_id = null
					updateUsrDialog()
					return
			if(usr.get_id_in_hand())
				var/obj/item/held_item = usr.get_active_held_item()
				var/obj/item/card/id/id_to_insert = held_item.GetID()
				if(id_insert(usr, held_item, inserted_modify_id))
					inserted_modify_id = id_to_insert
					updateUsrDialog()
		if ("inserted_scan_id")
			if(inserted_scan_id && !usr.get_active_held_item())
				if(id_eject(usr, inserted_scan_id))
					inserted_scan_id = null
					updateUsrDialog()
					return
			if(usr.get_id_in_hand())
				var/obj/item/held_item = usr.get_active_held_item()
				var/obj/item/card/id/id_to_insert = held_item.GetID()
				if(id_insert(usr, held_item, inserted_scan_id))
					inserted_scan_id = id_to_insert
					updateUsrDialog()
		if ("auth")
			if ((!( authenticated ) && (inserted_scan_id || issilicon(usr)) && (inserted_modify_id || mode)))
				if (check_access(inserted_scan_id))
					accessible_region_bitflag = NONE
					accessible_dept_payment_bitflag = NONE
					if(ACCESS_CHANGE_IDS in inserted_scan_id.access)
						if(department_bitflag)
							accessible_region_bitflag |= department_bitflag
							accessible_dept_payment_bitflag = ALL
							authenticated = 1
						else
							accessible_dept_payment_bitflag = ALL
							authenticated = 2
						playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)

					else
						if((ACCESS_HOP in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_SERVICE) || !department_bitflag))
							accessible_region_bitflag |= DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_CIVILIAN | DEPARTMENT_BITFLAG_CARGO
							accessible_dept_payment_bitflag |= ACCOUNT_COM_BITFLAG | ACCOUNT_CIV_BITFLAG | ACCOUNT_SRV_BITFLAG | ACCOUNT_CAR_BITFLAG
						if((ACCESS_HOS in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_SECURITY) || !department_bitflag))
							accessible_region_bitflag |= DEPARTMENT_BITFLAG_SECURITY
							accessible_dept_payment_bitflag |= ACCOUNT_SEC_BITFLAG
						if((ACCESS_CMO in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_MEDICAL) || !department_bitflag))
							accessible_region_bitflag |= DEPARTMENT_BITFLAG_MEDICAL
							accessible_dept_payment_bitflag |= ACCOUNT_MED_BITFLAG
						if((ACCESS_RD in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_SCIENCE) || !department_bitflag))
							accessible_region_bitflag |= DEPARTMENT_BITFLAG_SCIENCE
							accessible_dept_payment_bitflag |= ACCOUNT_SCI_BITFLAG
						if((ACCESS_CE in inserted_scan_id.access) && ((department_bitflag & DEPARTMENT_BITFLAG_ENGINEERING) || !department_bitflag))
							accessible_region_bitflag |= DEPARTMENT_BITFLAG_ENGINEERING
							accessible_dept_payment_bitflag |= ACCOUNT_ENG_BITFLAG
						if(accessible_region_bitflag)
							authenticated = 1
			else if ((!( authenticated ) && issilicon(usr)) && (!inserted_modify_id))
				to_chat(usr, span_warning("You can't modify an ID without an ID inserted to modify! Once one is in the modify slot on the computer, you can log in."))
		if ("logout")
			accessible_region_bitflag = NONE
			authenticated = 0
			playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)

		if("access")
			if(href_list["allowed"])
				if(authenticated)
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(!is_centcom && (access_type in get_all_centcom_admin_access()))
						log_id("[key_name(usr)] somehow attempted to manipulate [get_access_desc(access_type)](CentCom access) of [inserted_modify_id] using [inserted_scan_id] via a portable ID console at [AREACOORD(usr)]. This shouldn't happen, and investigate what's going on...")
						return
					if(access_allowed == 1)
						inserted_modify_id.access |= access_type
						log_id("[key_name(usr)] added [get_access_desc(access_type)] to [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")
					else
						inserted_modify_id.access -= access_type
						log_id("[key_name(usr)] removed [get_access_desc(access_type)] from [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")
					playsound(src, "terminal_type", 50, FALSE)
					inserted_modify_id.update_label()
					// Refresh only the access grid :)
					send_byjax(usr, "id_com.browser", "idc_accesses", get_accesses_html())
					return
		if ("assign")
			if (authenticated == 2)
				var/datum/bank_account/B = inserted_modify_id?.registered_account
				var/datum/record/crew/record = find_record(inserted_modify_id.registered_name, GLOB.manifest.general)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/newJob = reject_bad_text(stripped_input("Enter a custom job assignment.", "Assignment", inserted_modify_id ? inserted_modify_id.assignment : "Unassigned"), MAX_NAME_LEN)
					if(newJob)
						t1 = newJob
						log_id("[key_name(usr)] changed [inserted_modify_id] assignment to [newJob] using [inserted_scan_id] at [AREACOORD(usr)].")

				else if(t1 == "Unassigned")
					inserted_modify_id.access -= get_all_accesses()

					// These lines are to make an individual to an assistant
					if(B)
						for(var/each in inserted_modify_id.registered_account.payment_per_department)
							if(SSeconomy.is_nonstation_account(each)) // do not touch VIP/Command flag
								continue
							B.active_departments &= ~SSeconomy.get_budget_acc_bitflag(each) // turn off all bitflag for each department except for VIP/Command
							B.payment_per_department[each] = 0 // your payment for each department is 0
							B.bonus_per_department[each] = 0   // your bonus for each department is 0
						B.active_departments &= ~SSeconomy.get_budget_acc_bitflag(ACCOUNT_COM_ID) // micromanagement. Command bitflag should be removed manually, because 'for/each' didn't remove it.
						B.payment_per_department[ACCOUNT_CIV_ID] = PAYCHECK_MINIMAL // for the love of god, let them have minimal payment from Civ budget... to be a real assistant.
					if(record)
						for(var/each in B.payment_per_department)
							if(SSeconomy.is_nonstation_account(each)) // do not touch VIP/Command flag
								continue
							record.active_department &= ~SSeconomy.get_budget_acc_bitflag(each) // turn off all bitflag for each department except for VIP/Command. *note: this actually shouldn't use `get_budget_acc_bitflag()` proc, because bitflags are the same but these have a different purpose.
						record.active_department &= ~DEPARTMENT_BITFLAG_COMMAND  // micromanagement2. the reason is the same. Command should be removed manually.


					log_id("[key_name(usr)] unassigned and stripped all access from [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")

				else
					var/datum/job/jobdatum = SSjob.get_job(t1)
					if(!jobdatum)
						to_chat(usr, span_warning("No log exists for this job."))
						stack_trace("bad job string '[t1]' is given through HoP console by '[ckey(usr)]'")
						updateUsrDialog()
						return
					inserted_modify_id.access -= get_all_accesses()
					inserted_modify_id.access |= jobdatum.get_access()

					// Step 1: reseting theirs first
					if(B && jobdatum) // 1-A: reseting bank payment
						for(var/each in inserted_modify_id.registered_account.payment_per_department)
							if(SSeconomy.is_nonstation_account(each))
								continue
							B.active_departments &= ~SSeconomy.get_budget_acc_bitflag(each)
							B.payment_per_department[each] = 0
							B.bonus_per_department[each] = 0
						B.active_departments &= ~SSeconomy.get_budget_acc_bitflag(ACCOUNT_COM_ID) // micromanagement
					if(record && jobdatum) // 1-B: reseting crew manifest
						for(var/each in available_paycheck_departments)
							if(SSeconomy.is_nonstation_account(each))
								continue
							record.active_department &= ~SSeconomy.get_budget_acc_bitflag(each)
						record.active_department &= ~DEPARTMENT_BITFLAG_COMMAND  // micromanagement2
						// Note: `active_department = NONE` is a bad idea because you should keep VIP_BITFLAG.
					// Step 2: giving the job info into their bank and record
					if(B && jobdatum) // 2-A: setting bank payment
						for(var/each in jobdatum.payment_per_department)
							if(SSeconomy.is_nonstation_account(each))
								continue
							B.payment_per_department[each] = jobdatum.payment_per_department[each]
						B.active_departments |= jobdatum.bank_account_department
					if(record && jobdatum) // 2-B: setting crew manifest
						record.active_department |= jobdatum.departments_bitflags

					log_id("[key_name(usr)] assigned [jobdatum || t1] job to [inserted_modify_id], manipulating it to the default access of the job using [inserted_scan_id] at [AREACOORD(usr)].")

				if (inserted_modify_id)
					inserted_modify_id.assignment = t1
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
				update_modify_manifest()

		if ("demote") // for now, every head can demote anyone... it's better than shitcode
			inserted_modify_id.assignment = "Demoted"
			log_id("[key_name(usr)] demoted [inserted_modify_id], unassigning the card without affecting access, using [inserted_scan_id] at [AREACOORD(usr)].")
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			update_modify_manifest()

		if ("reg")
			if (authenticated)
				var/t2 = inserted_modify_id
				if ((authenticated && inserted_modify_id == t2 && (in_range(src, usr) || issilicon(usr)) && isturf(loc)))
					// Sanitize the name first. We're not using the full sanitize_name proc as ID cards can have a wider variety of things on them that
					// would not pass as a formal character name, but would still be valid on an ID card created by a player.
					var/new_name = sanitize(href_list["reg"])
					// However, we are going to reject bad names overall including names with invalid characters in them, while allowing numbers.
					new_name = reject_bad_name(new_name, allow_numbers = TRUE)

					if(new_name)
						log_id("[key_name(usr)] changed [inserted_modify_id] name to '[new_name]', using [inserted_scan_id] at [AREACOORD(usr)].")
						inserted_modify_id.registered_name = new_name
						playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
					else
						to_chat(usr, span_error("Invalid name entered."))
						updateUsrDialog()
						return
		if ("mode")
			mode = text2num(href_list["mode_target"])

		if("return")
			//DISPLAY MAIN MENU
			mode = 0
			playsound(src, "terminal_type", 25, FALSE)

		if("make_job_available")
			// MAKE ANOTHER JOB POSITION AVAILABLE FOR LATE JOINERS
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !department_bitflag)
				var/edit_job_target = href_list["job"]
				var/datum/job/j = SSjob.get_job(edit_job_target)
				if(!j)
					updateUsrDialog()
					return 0
				if(can_open_job(j) != 1)
					updateUsrDialog()
					return 0
				if(opened_positions[edit_job_target] >= 0)
					GLOB.time_last_changed_position = world.time / 10
				j.total_position_delta++
				opened_positions[edit_job_target]++
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

		if("make_job_unavailable")
			// MAKE JOB POSITION UNAVAILABLE FOR LATE JOINERS
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !department_bitflag)
				var/edit_job_target = href_list["job"]
				var/datum/job/j = SSjob.get_job(edit_job_target)
				if(!j)
					updateUsrDialog()
					return 0
				if(can_close_job(j) != 1)
					updateUsrDialog()
					return 0
				//Allow instant closing without cooldown if a position has been opened before
				if(opened_positions[edit_job_target] <= 0)
					GLOB.time_last_changed_position = world.time / 10
				j.total_position_delta--
				opened_positions[edit_job_target]--
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)

		if ("prioritize_job")
			// TOGGLE WHETHER JOB APPEARS AS PRIORITIZED IN THE LOBBY
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !department_bitflag)
				var/priority_target = href_list["job"]
				var/datum/job/j = SSjob.get_job(priority_target)
				if(!j)
					updateUsrDialog()
					return 0
				var/priority = TRUE
				if(j in SSjob.prioritized_jobs)
					SSjob.prioritized_jobs -= j
					priority = FALSE
				else if(j.get_spawn_position_count() <= j.current_positions)
					to_chat(usr, span_notice("[j.title] has had all positions filled. Open up more slots before prioritizing it."))
					updateUsrDialog()
					return
				else
					SSjob.prioritized_jobs += j
				to_chat(usr, span_notice("[j.title] has been successfully [priority ?  "prioritized" : "unprioritized"]. Potential employees will notice your request."))
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

		if ("set_paycheck_department")
			if(!inserted_scan_id)
				updateUsrDialog()
				return
			var/href_paytype = href_list["paytype"]
			if(!SSeconomy.get_budget_account(href_paytype))
				updateUsrDialog()
				return
			if(SSeconomy.is_nonstation_account(href_paytype))
				updateUsrDialog()
				return
			target_paycheck = href_paytype

		if ("adjust_pay")
			//Adjust the paycheck of a crew member. Can't be less than zero.
			if(!(authenticated || check_auth_payment()))
				updateUsrDialog()
				return
			var/paycheck_t = href_list["paycheck_t"]
			var/datum/bank_account/B = SSeconomy.get_bank_account_by_id(href_list["bank_account"]) || inserted_modify_id?.registered_account
			if(isnull(B))
				updateUsrDialog()
				return
			if(SSeconomy.is_nonstation_account(paycheck_t))
				message_admins("[ADMIN_LOOKUPFLW(usr)] tried to adjust [B.account_id] payment. It must be they're hacking the game.")
				CRASH("[key_name(usr)] tried to adjust [B.account_id] payment. It must be they're hacking the game.")
			var/new_pay = floor(input(usr, "Input the new paycheck amount.", "Set new paycheck amount.", B.payment_per_department[target_paycheck]) as num|null)
			if(isnull(new_pay))
				updateUsrDialog()
				return
			if(new_pay < 0)
				to_chat(usr, span_warning("Paychecks cannot be negative."))
				updateUsrDialog()
				return
			B.payment_per_department[paycheck_t] = new_pay

		if ("adjust_bonus")
			//Adjust the bonus pay of a crew member. Negative amounts dock pay.
			if(!(authenticated || check_auth_payment()))
				updateUsrDialog()
				return
			var/paycheck_t = href_list["paycheck_t"]
			var/datum/bank_account/B = SSeconomy.get_bank_account_by_id(href_list["bank_account"]) || inserted_modify_id?.registered_account
			if(isnull(B))
				updateUsrDialog()
				return
			if(SSeconomy.is_nonstation_account(paycheck_t))
				message_admins("[ADMIN_LOOKUPFLW(usr)] tried to adjust [inserted_modify_id.registered_name]'s [B.account_holder] pay bonus. It must be they're hacking the game.")
				CRASH("[key_name(usr)] tried to adjust [inserted_modify_id.registered_name]'s [B.account_holder] pay bonus. It must be they're hacking the game.")
			var/new_bonus = floor(input(usr, "Input the bonus amount. Negative values will dock paychecks.", "Set paycheck bonus", B.bonus_per_department[target_paycheck]) as num|null)
			if(isnull(new_bonus))
				updateUsrDialog()
				return
			B.bonus_per_department[paycheck_t] = new_bonus

		if ("turn_on_off_department_bank")
			var/check_card = href_list["check_card"]
			if(!inserted_scan_id && check_card)
				updateUsrDialog()
				return
			var/paycheck_t = href_list["paycheck_t"]
			var/datum/bank_account/B = SSeconomy.get_bank_account_by_id(href_list["bank_account"]) || inserted_modify_id?.registered_account
			if(!B)
				updateUsrDialog()
				return
			if(SSeconomy.is_nonstation_account(paycheck_t) && !(paycheck_t == ACCOUNT_COM_ID)) // command is fine to turn on/off
				message_admins("[ADMIN_LOOKUPFLW(usr)] tried to adjust [inserted_modify_id.registered_name]'s vendor free status of [B.account_holder]. It must be they're hacking the game.")
				CRASH("[key_name(usr)] tried to adjust [inserted_modify_id.registered_name]'s vendor free status of [B.account_holder]. It must be they're hacking the game.")

			if(B.active_departments & SSeconomy.get_budget_acc_bitflag(paycheck_t))
				B.active_departments &= ~SSeconomy.get_budget_acc_bitflag(paycheck_t) // turn off
			else
				B.active_departments |= SSeconomy.get_budget_acc_bitflag(paycheck_t) // turn on

		if ("turn_on_off_department_manifest")
			var/target_bitflag = text2num(href_list["target_bitflag"])
			var/datum/record/crew/record = find_record(inserted_modify_id.registered_name, GLOB.manifest.general)
			if(!record)
				updateUsrDialog()
				return

			if(record.active_department & target_bitflag)
				record.active_department &= ~target_bitflag // turn off
			else
				record.active_department |= target_bitflag // turn on

		if ("print")
			if (!( printing ))
				printing = 1
				say("Printing...")
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper( loc )
				var/t1 = "<B>Crew Manifest:</B><BR>"
				for(var/datum/record/crew/t in sort_record(GLOB.manifest.general))
					t1 += t.name + " - " + t.rank + "<br>"
				P.default_raw_text = t1
				P.name = "paper- 'Crew Manifest'"
				printing = null
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

		if ("open_new_account")
			if(!inserted_scan_id)
				say("No ID detected.")
				updateUsrDialog()
				return
			if(!(ACCESS_HOP in inserted_scan_id.access))
				say("Insufficient access to create a new bank account.")
				return
			var/datum/bank_account/B = SSeconomy.get_budget_account(initial(target_paycheck))
			switch(alert("Would you like to open a new bank account?\nIt will cost 1,000 credits in [LOWER_TEXT(initial(target_paycheck))] budget.","Open a new account","Yes","No"))
				if("No")
					return
				if("Yes")
					if(!B.has_money(NEW_BANK_ACCOUNT_COST))
						say("Insufficient budget balance, abort opening a new bank account.")
						return
			if (!(printing))
				printing = 1
				var/target_name = reject_bad_text(stripped_input("Write the bank owner's name", "Account owner's name?"), MAX_NAME_LEN)
				if(!target_name)
					printing = null
					return
				if(!B.adjust_money(-NEW_BANK_ACCOUNT_COST)) // double fail check
					say("Insufficient budget balance, abort opening a new bank account.")
					printing = null
					return

				B = new /datum/bank_account(target_name, SSjob.get_job(JOB_NAME_ASSISTANT))
				for(var/each in B.payment_per_department)
					B.payment_per_department[each] = 0
				say("Printing...")
				sleep(50)
				var/obj/item/paper/printed_paper = new /obj/item/paper( loc )
				printed_paper.name = "New bank account information"
				var/final_paper_text = "<b>* Owner:</b> [target_name]<br>"
				final_paper_text += "<b>* Bank ID:</b> [B.account_id]<br>"
				final_paper_text += "--- Created by Nanotrasen Space Finance ---"
				printed_paper.add_raw_text(final_paper_text)
				printed_paper.update_appearance()
				printing = null
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

	if (inserted_modify_id)
		inserted_modify_id.update_label()
	updateUsrDialog()

/// Returns if auth id has head access that is eligible to adjust payment
/obj/machinery/computer/card/proc/check_auth_payment()
	for(var/each in list(ACCESS_HEADS, ACCESS_CHANGE_IDS, ACCESS_HOP, ACCESS_CMO, ACCESS_RD, ACCESS_CE))
		if(each in inserted_scan_id.access)
			return TRUE
	return FALSE

/obj/machinery/computer/card/centcom
	name = "\improper CentCom identification console"
	circuit = /obj/item/circuitboard/computer/card/centcom
	req_access = list(ACCESS_CENT_CAPTAIN)
	is_centcom = TRUE

/obj/machinery/computer/card/minor
	name = "department management console"
	desc = "You can use this to change ID's for specific departments."
	icon_screen = "idminor"
	circuit = /obj/item/circuitboard/computer/card/minor

/obj/machinery/computer/card/minor/Initialize(mapload)
	. = ..()
	var/obj/item/circuitboard/computer/card/minor/typed_circuit = circuit
	if(department_bitflag)
		for(var/i in 1 to length(typed_circuit.dept_list))
			if(department_bitflag == typed_circuit.dept_list[i])
				typed_circuit.counting = i
				break
	else
		department_bitflag = typed_circuit.dept_list[typed_circuit.counting]
	name = "[LOWER_TEXT(typed_circuit.dept_list_name[typed_circuit.counting])] department console"

/obj/machinery/computer/card/minor/hos
	department_bitflag = DEPARTMENT_BITFLAG_SECURITY
	target_paycheck = ACCOUNT_SEC_ID
	icon_screen = "idhos"

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/card/minor/cmo
	department_bitflag = DEPARTMENT_BITFLAG_MEDICAL
	target_paycheck = ACCOUNT_MED_ID
	icon_screen = "idcmo"

/obj/machinery/computer/card/minor/rd
	department_bitflag = DEPARTMENT_BITFLAG_SCIENCE
	target_paycheck = ACCOUNT_SCI_ID
	icon_screen = "idrd"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/card/minor/ce
	department_bitflag = DEPARTMENT_BITFLAG_ENGINEERING
	target_paycheck = ACCOUNT_ENG_ID
	icon_screen = "idce"

	light_color = LIGHT_COLOR_DIM_YELLOW


#undef NEW_BANK_ACCOUNT_COST
