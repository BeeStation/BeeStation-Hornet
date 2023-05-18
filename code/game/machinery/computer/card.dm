#define DEPT_ALL 0
#define DEPT_GEN 1
#define DEPT_SEC 2
#define DEPT_MED 3
#define DEPT_SCI 4
#define DEPT_ENG 5
#define DEPT_SUP 6

#define NEW_BANK_ACCOUNT_COST 1000

//Keeps track of the time for the ID console. Having it as a global variable prevents people from dismantling/reassembling it to
//increase the slots of many jobs.
GLOBAL_VAR_INIT(time_last_changed_position, 0)

/obj/machinery/computer/card
	name = "identification console"
	desc = "You can use this to manage jobs and ID access."
	icon_screen = "id"
	icon_keyboard = "id_key"
	req_one_access = list(ACCESS_HEADS, ACCESS_CHANGE_IDS)
	circuit = /obj/item/circuitboard/computer/card
	var/mode = 0
	var/printing = null
	var/target_dept = DEPT_ALL //Which department this computer has access to.
	var/available_paycheck_departments = list()
	var/target_paycheck = ACCOUNT_SRV_ID

	//Cooldown for closing positions in seconds
	//if set to -1: No cooldown... probably a bad idea
	//if set to 0: Not able to close "original" positions. You can only close positions that you have opened before
	var/change_position_cooldown = 30
	//Jobs you cannot open new positions for
	var/list/blacklisted = list(
		JOB_NAME_AI,
		JOB_NAME_ASSISTANT,
		JOB_NAME_CYBORG,
		JOB_NAME_CAPTAIN,
		JOB_NAME_HEADOFPERSONNEL,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_CHIEFENGINEER,
		JOB_NAME_RESEARCHDIRECTOR,
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_BRIGPHYSICIAN,
		JOB_NAME_DEPUTY)

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list();
	var/obj/item/card/id/inserted_scan_id
	var/obj/item/card/id/inserted_modify_id
	var/list/region_access = null
	var/region_access_payment = NONE
	var/list/head_subordinates = null

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/card/Initialize(mapload)
	. = ..()
	change_position_cooldown = CONFIG_GET(number/id_console_jobslot_delay)
	for(var/G in typesof(/datum/job/gimmick))
		var/datum/job/gimmick/J = new G
		blacklisted += J.title

	// This determines which department payment list the console will show to you.
	if(!target_dept)
		available_paycheck_departments |= list(ACCOUNT_COM_ID)
	if((target_dept == DEPT_GEN) || !target_dept)
		available_paycheck_departments |= list(ACCOUNT_CIV_ID, ACCOUNT_SRV_ID, ACCOUNT_CAR_ID)
	if((target_dept == DEPT_ENG) || !target_dept)
		available_paycheck_departments |= list(ACCOUNT_ENG_ID)
	if((target_dept == DEPT_SCI) || !target_dept)
		available_paycheck_departments |= list(ACCOUNT_SCI_ID)
	if((target_dept == DEPT_MED) || !target_dept)
		available_paycheck_departments |= list(ACCOUNT_MED_ID)
	if((target_dept == DEPT_SEC) || !target_dept)
		available_paycheck_departments |= list(ACCOUNT_SEC_ID)


/obj/machinery/computer/card/examine(mob/user)
	. = ..()
	if(inserted_scan_id || inserted_modify_id)
		. += "<span class='notice'>Alt-click to eject the ID card.</span>"

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

//Check if you can't open a new position for a certain job
/obj/machinery/computer/card/proc/job_blacklisted(jobtitle)
	return (jobtitle in blacklisted)

//Logic check for Topic() if you can open the job
/obj/machinery/computer/card/proc/can_open_job(datum/job/job)
	if(job)
		if(!job_blacklisted(job.title))
			if((job.total_positions <= GLOB.player_list.len * (max_relative_positions / 100)))
				var/delta = (world.time / 10) - GLOB.time_last_changed_position
				if((change_position_cooldown < delta) || (opened_positions[job.title] < 0))
					return 1
				return -2
			return -1
	return 0

//Logic check for Topic() if you can close the job
/obj/machinery/computer/card/proc/can_close_job(datum/job/job)
	if(job)
		if(!job_blacklisted(job.title))
			if(job.total_positions > job.current_positions)
				var/delta = (world.time / 10) - GLOB.time_last_changed_position
				if((change_position_cooldown < delta) || (opened_positions[job.title] > 0))
					return 1
				return -2
			return -1
	return 0

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

	user.visible_message("<span class='notice'>[user] inserts \the [card_to_insert] into \the [src].</span>",
						"<span class='notice'>You insert \the [card_to_insert] into \the [src].</span>")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	updateUsrDialog()
	return TRUE

/obj/machinery/computer/card/proc/id_eject(mob/user, obj/target)
	if(!target)
		to_chat(user, "<span class='warning'>That slot is empty!</span>")
		return FALSE
	else
		if(target == inserted_modify_id)
			update_modify_manifest()
		target.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(target)
		user.visible_message("<span class='notice'>[user] gets \the [target] from \the [src].</span>", \
							"<span class='notice'>You get \the [target] from \the [src].</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()
		return TRUE

/obj/machinery/computer/card/proc/update_modify_manifest()
	GLOB.data_core.manifest_modify(inserted_modify_id.registered_name, inserted_modify_id.assignment, inserted_modify_id.hud_state)

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
		for(var/datum/data/record/t in sort_record(GLOB.data_core.general))
			crew += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
		dat = "<tt><b>Crew Manifest:</b><br>Please use security record computer to modify entries.<br><br>[crew]<a href='?src=[REF(src)];choice=print'>Print</a><br><br><a href='?src=[REF(src)];choice=mode;mode_target=0'>Return</a><br></tt>"

	else if(mode == 2)
		// JOB MANAGEMENT
		dat = "<a href='?src=[REF(src)];choice=return'>Return</a>"
		dat += " || Confirm Identity: "
		var/S
		if(inserted_scan_id)
			S = html_encode(inserted_scan_id.name)
		else
			S = "--------"
		dat += "<a href='?src=[REF(src)];choice=inserted_scan_id'>[S]</a>"
		dat += "<table>"
		dat += "<tr><td style='width:25%'><b>Job</b></td><td style='width:5%'><b>Slots</b></td><td style='width:20%'><b>Open job</b></td><td style='width:20%'><b>Close job</b><td style='width:20%'><b>Prioritize</b></td></td></tr>"
		var/ID
		if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !target_dept)
			ID = 1
		else
			ID = 0
		for(var/datum/job/job in SSjob.occupations)
			dat += "<tr>"
			if(job.title in blacklisted)
				continue
			dat += "<td>[job.title]</td>"
			dat += "<td>[job.current_positions]/[job.total_positions]</td>"
			dat += "<td>"
			switch(can_open_job(job))
				if(1)
					if(ID)
						dat += "<a href='?src=[REF(src)];choice=make_job_available;job=[job.title]'>Open Position</a><br>"
					else
						dat += "Open Position"
				if(-1)
					dat += "Denied"
				if(-2)
					var/time_to_wait = round(change_position_cooldown - ((world.time / 10) - GLOB.time_last_changed_position), 1)
					var/mins = round(time_to_wait / 60)
					var/seconds = time_to_wait - (60*mins)
					dat += "Cooldown ongoing: [mins]:[(seconds < 10) ? "0[seconds]" : "[seconds]"]"
				if(0)
					dat += "Denied"
			dat += "</td><td>"
			switch(can_close_job(job))
				if(1)
					if(ID)
						dat += "<a href='?src=[REF(src)];choice=make_job_unavailable;job=[job.title]'>Close Position</a>"
					else
						dat += "Close Position"
				if(-1)
					dat += "Denied"
				if(-2)
					var/time_to_wait = round(change_position_cooldown - ((world.time / 10) - GLOB.time_last_changed_position), 1)
					var/mins = round(time_to_wait / 60)
					var/seconds = time_to_wait - (60*mins)
					dat += "Cooldown ongoing: [mins]:[(seconds < 10) ? "0[seconds]" : "[seconds]"]"
				if(0)
					dat += "Denied"
			dat += "</td><td>"
			switch(job.total_positions)
				if(0)
					dat += "Denied"
				else
					if(ID)
						if(job in SSjob.prioritized_jobs)
							dat += "<a href='?src=[REF(src)];choice=prioritize_job;job=[job.title]'>Deprioritize</a>"
						else
							if(SSjob.prioritized_jobs.len < 5)
								dat += "<a href='?src=[REF(src)];choice=prioritize_job;job=[job.title]'>Prioritize</a>"
							else
								dat += "Denied"
					else
						dat += "Prioritize"


			dat += "</td></tr>"
		dat += "</table>"
	else if(mode == 3)
		//PAYCHECK MANAGEMENT
		dat = "<a href='?src=[REF(src)];choice=return'>Return</a>"
		dat += " || Confirm Identity: "
		var/S
		var/list/paycheck_departments = list()
		if(inserted_scan_id)
			S = html_encode(inserted_scan_id.name)
			//Checking all the accesses and their corresponding departments
			if((ACCESS_HOP in inserted_scan_id.access) && ((target_dept==DEPT_GEN) || !target_dept))
				paycheck_departments |= ACCOUNT_SRV_ID
				paycheck_departments |= ACCOUNT_CIV_ID
				paycheck_departments |= ACCOUNT_CAR_ID //Currently no seperation between service/civillian and supply
			if((ACCESS_HOS in inserted_scan_id.access) && ((target_dept==DEPT_SEC) || !target_dept))
				paycheck_departments |= ACCOUNT_SEC_ID
			if((ACCESS_CMO in inserted_scan_id.access) && ((target_dept==DEPT_MED) || !target_dept))
				paycheck_departments |= ACCOUNT_MED_ID
			if((ACCESS_RD in inserted_scan_id.access) && ((target_dept==DEPT_SCI) || !target_dept))
				paycheck_departments |= ACCOUNT_SCI_ID
			if((ACCESS_CE in inserted_scan_id.access) && ((target_dept==DEPT_ENG) || !target_dept))
				paycheck_departments |= ACCOUNT_ENG_ID
		else
			S = "--------"
		dat += "<a href='?src=[REF(src)];choice=inserted_scan_id'>[S]</a><br>"
		dat += "<td>target department: "
		if(length(paycheck_departments))
			for(var/P in available_paycheck_departments)
				if(SSeconomy.is_nonstation_account(P))
					continue
				var/colourful = "[P == target_paycheck ? "<font color=\"6bc473\">" : "" ]"
				dat += "<a href='?src=[REF(src)];choice=set_paycheck_department;paytype=[P]'>[colourful][P][colourful ? "</font>" : ""]</a> "
		dat += "</td>"
		dat += "<table>"
		dat += "<tr><td style='width:30%'><b>Name</b></td><td style='width:20%'><b>Job</b></td><td style='width:20%'><b>Department</b></td><td style='width:15%'><b>Paycheck</b></td><td style='width:15%'><b>Pay Bonus</b></td></tr>"

		if(length(paycheck_departments))
			for(var/datum/bank_account/B in SSeconomy.bank_accounts)
				var/datum/data/record/R = find_record("name", B.account_holder, GLOB.data_core.general)
				dat += "<tr>"
				dat += "<td>[B.account_holder] [B.suspended ? "(Account closed)" : ""]</td>"
				dat += "<td>[R ? R.fields["rank"] : "(No data)"]</td>"
				if(!(target_paycheck in paycheck_departments))
					dat += "<td>(Auth-denied)</td>"
				else
					if(B.active_departments & SSeconomy.get_budget_acc_bitflag(target_paycheck))
						dat += "<td><a href='?src=[REF(src)];choice=turn_on_off_department_bank;bank_account=[B.account_id];check_card=1'><font color=\"6bc473\">Free Vendor Access</font></a></td>"
					else
						dat += "<td><a href='?src=[REF(src)];choice=turn_on_off_department_bank;bank_account=[B.account_id];check_card=1;paycheck_t=[target_paycheck]'>No Free Vendor Access</a></td>"
				if(B.suspended)
					dat += "<td>Closed</td>"
					dat += "<td>$0</td>"
				else if(!(target_paycheck in paycheck_departments))
					dat += "<td>$[B.payment_per_department[target_paycheck]] (Auth-denied)</td>"
					dat += "<td>$[B.bonus_per_department[target_paycheck]]</td>"
				else
					dat += "<td><a href='?src=[REF(src)];choice=adjust_pay;paycheck_t=[target_paycheck];bank_account=[B.account_id]'>$[B.payment_per_department[target_paycheck]]</a></td>"
					dat += "<td><a href='?src=[REF(src)];choice=adjust_bonus;paycheck_t=[target_paycheck];bank_account=[B.account_id]'>$[B.bonus_per_department[target_paycheck]]</a></td>"
				dat += "</tr>"
	else
		var/header = ""

		var/scan_name = inserted_scan_id ? html_encode(inserted_scan_id.name) : "--------"
		var/target_name = inserted_modify_id ? html_encode(inserted_modify_id.name) : "--------"
		var/target_owner = (inserted_modify_id && inserted_modify_id.registered_name) ? html_encode(inserted_modify_id.registered_name) : "--------"
		var/target_rank = (inserted_modify_id && inserted_modify_id.assignment) ? html_encode(inserted_modify_id.assignment) : "Unassigned"

		if(!authenticated)
			header += "<br><i>Please insert the cards into the slots</i><br>"
			header += "Target: <a href='?src=[REF(src)];choice=inserted_modify_id'>[target_name]</a><br>"
			header += "Confirm Identity: <a href='?src=[REF(src)];choice=inserted_scan_id'>[scan_name]</a><br>"
		else
			header += "<div align='center'><br>"
			header += "<a href='?src=[REF(src)];choice=inserted_modify_id'>Remove [target_name]</a> || "
			header += "<a href='?src=[REF(src)];choice=inserted_scan_id'>Remove [scan_name]</a> <br> "
			header += "<a href='?src=[REF(src)];choice=mode;mode_target=1'>Access Crew Manifest</a> <br> "
			header += "<a href='?src=[REF(src)];choice=logout'>Log Out</a></div>"

		header += "<hr>"

		var/jobs_all = ""
		var/list/alljobs = list("Unassigned")
		alljobs += (istype(src, /obj/machinery/computer/card/centcom)? get_all_centcom_jobs() : get_all_jobs()) + "Custom"
		for(var/job in alljobs)
			if(job == JOB_NAME_ASSISTANT)
				jobs_all += "<br/>* Service: "
			if(job == JOB_NAME_QUARTERMASTER)
				jobs_all += "<br/>* Cargo: "
			if(job == JOB_NAME_RESEARCHDIRECTOR)
				jobs_all += "<br/>* R&D: "
			if(job == JOB_NAME_CHIEFENGINEER)
				jobs_all += "<br/>* Engineering: "
			if(job == JOB_NAME_CHIEFMEDICALOFFICER)
				jobs_all += "<br/>* Medical: "
			if(job == JOB_NAME_HEADOFSECURITY)
				jobs_all += "<br/>* Security: "
			if(job == "Custom")
				jobs_all += "<br/>"
			// these will make some separation for the department.
			jobs_all += "<a href='?src=[REF(src)];choice=assign;assign_target=[job]'>[replacetext(job, " ", "&nbsp")]</a> " //make sure there isn't a line break in the middle of a job


		var/body

		if (authenticated && inserted_modify_id)

			var/carddesc = text("")
			var/jobs = text("")
			if( authenticated == 2)
				carddesc += {"<script type="text/javascript">
									function markRed(){
										var nameField = document.getElementById('namefield');
										nameField.style.backgroundColor = "#FFDDDD";
									}
									function markGreen(){
										var nameField = document.getElementById('namefield');
										nameField.style.backgroundColor = "#DDFFDD";
									}
									function showAll(){
										var allJobsSlot = document.getElementById('alljobsslot');
										allJobsSlot.innerHTML = "<a href='#' onclick='hideAll()'>hide</a><br>"+ "[jobs_all]";
									}
									function hideAll(){
										var allJobsSlot = document.getElementById('alljobsslot');
										allJobsSlot.innerHTML = "<a href='#' onclick='showAll()'>show</a>";
									}
								</script>"}
				carddesc += "<form name='cardcomp' action='?src=[REF(src)]' method='get'>"
				carddesc += "<input type='hidden' name='src' value='[REF(src)]'>"
				carddesc += "<input type='hidden' name='choice' value='reg'>"
				carddesc += "<b>registered name:</b> <input type='text' id='namefield' name='reg' value='[target_owner]' style='width:250px; background-color:white;' onchange='markRed()'>"
				carddesc += "<input type='submit' value='Rename' onclick='markGreen()'>"
				carddesc += "</form>"
				carddesc += "<b>Assignment:</b> "

				jobs += "<span id='alljobsslot'><a href='#' onclick='showAll()'>[target_rank]</a></span>" //CHECK THIS

			else
				carddesc += "<b>registered_name:</b> [target_owner]</span>"
				jobs += "<b>Assignment:</b> [target_rank] (<a href='?src=[REF(src)];choice=demote'>Demote</a>)</span>"

			var/banking = ""
			banking += "<b>Department active & Bank account status:</b>"
			banking += "<table border='1' cellspacing='1' cellpadding='0'>"
			// Department active status
			banking += "<tr>"
			banking += "<td><b>Active Department Manifest:</b></td>"
			var/datum/data/record/R = find_record("name", inserted_modify_id.registered_name, GLOB.data_core.general)
			if(R)
				for(var/each in available_paycheck_departments)
					if(!(SSeconomy.get_budget_acc_bitflag(each) & region_access_payment))
						continue
					if(R.fields["active_dept"] & SSeconomy.get_budget_acc_bitflag(each))
						banking += "<td><a href='?src=[REF(src)];choice=turn_on_off_department_manifest;target_bitflag=[SSeconomy.get_budget_acc_bitflag(each)]'><font color=\"6bc473\">[each]</a></font></td>"
					else
						banking += "<td><a href='?src=[REF(src)];choice=turn_on_off_department_manifest;target_bitflag=[SSeconomy.get_budget_acc_bitflag(each)]'>[each]</a></td>"
			else
				banking += "<td colspan=\"8\"><b>Error: Cannot locate user entry in data core</b></td>"
			banking += "</tr>"
			//adjustable only when they have bank account in their card
			var/datum/bank_account/B = inserted_modify_id?.registered_account
			if(B)
				// Bank vendor free status - Lets you to buy department stuff for free
				banking += "<tr>"
				banking += "<td><b>Free Vendor Access:</b></td>"
				for(var/each in available_paycheck_departments)
					if(!(SSeconomy.get_budget_acc_bitflag(each) & region_access_payment))
						continue
					if(B.active_departments & SSeconomy.get_budget_acc_bitflag(each))
						banking += "<td><a href='?src=[REF(src)];choice=turn_on_off_department_bank;paycheck_t=[each]'><font color=\"6bc473\">[each]</a></font></td>"
					else
						banking += "<td><a href='?src=[REF(src)];choice=turn_on_off_department_bank;paycheck_t=[each]'>[each]</a></td>"
				banking += "</tr>"
				// Payment status
				banking += "<tr>"
				banking += "<td><b>Payment per department:</b></td>"
				for(var/each in available_paycheck_departments)
					if(!(SSeconomy.get_budget_acc_bitflag(each) & region_access_payment))
						continue
					if(SSeconomy.is_nonstation_account(each))
						banking += "<td>$[B.payment_per_department[each]]</td>"
						continue
					banking += "<td><a href='?src=[REF(src)];choice=adjust_pay;paycheck_t=[each]'>$[B.payment_per_department[each]]</a></td>"
				banking += "</tr>"
			else
				banking += "<td><b>Banking information:</b></td>"
				banking += "<td colspan=\"8\"><b>Error: No linked bank account detected</b></td>"
			banking += "</table>"
			banking += "<br>"

			var/accesses = ""
			if(istype(src, /obj/machinery/computer/card/centcom))
				accesses += "<h5>Central Command:</h5>"
				for(var/A in get_all_centcom_access())
					if(A in inserted_modify_id.access)
						accesses += "<a href='?src=[REF(src)];choice=access;access_target=[A];allowed=0'><font color=\"6bc473\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
					else
						accesses += "<a href='?src=[REF(src)];choice=access;access_target=[A];allowed=1'>[replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
			else
				accesses += "<div align='center'><b>Access</b></div>"
				accesses += "<table style='width:100%'>"
				accesses += "<tr>"
				for(var/i = 1; i <= 7; i++)
					if(authenticated == 1 && !(i in region_access))
						continue
					accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
				accesses += "</tr><tr>"
				for(var/i = 1; i <= 7; i++)
					if(authenticated == 1 && !(i in region_access))
						continue
					accesses += "<td style='width:14%' valign='top'>"
					for(var/A in get_region_accesses(i))
						if(A in inserted_modify_id.access)
							accesses += "<a href='?src=[REF(src)];choice=access;access_target=[A];allowed=0'><font color=\"6bc473\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
						else
							accesses += "<a href='?src=[REF(src)];choice=access;access_target=[A];allowed=1'>[replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
						accesses += "<br>"
					accesses += "</td>"
				accesses += "</tr></table>"
			body = "[carddesc]<br>[jobs]<br>[banking]<br>[accesses]" //CHECK THIS

		else
			body = "<a href='?src=[REF(src)];choice=auth'>{Log in}</a> <br><hr>"
			body += "<a href='?src=[REF(src)];choice=mode;mode_target=1'>Access Crew Manifest</a>"
			if(!target_dept)
				body += "<br><hr><a href = '?src=[REF(src)];choice=mode;mode_target=2'>Job Management</a>"
			body += "<a href='?src=[REF(src)];choice=mode;mode_target=3'>Paycheck Management</a>"
			if(target_dept == DEPT_ALL) // currently locked in HoP console only. other console can make bank account with their own budget if this lock is removed
				body += "<a href='?src=[REF(src)];choice=open_new_account'>Open a new bank account</a>"

		dat = "<tt>[header][body]<hr><br></tt>"
	var/datum/browser/popup = new(user, "id_com", src.name, 1150, 720)
	popup.set_content(dat)
	popup.open()

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
					region_access = list()
					region_access_payment = NONE
					head_subordinates = list()
					if(ACCESS_CHANGE_IDS in inserted_scan_id.access)
						if(target_dept)
							head_subordinates = get_all_jobs()
							region_access |= target_dept
							region_access_payment = ALL
							authenticated = 1
						else
							region_access_payment = ALL
							authenticated = 2
						playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)

					else
						if((ACCESS_HOP in inserted_scan_id.access) && ((target_dept==DEPT_GEN) || !target_dept))
							region_access |= DEPT_GEN
							region_access |= DEPT_SUP //Currently no seperation between service/civillian and supply
							region_access_payment |= ACCOUNT_COM_BITFLAG | ACCOUNT_CIV_BITFLAG | ACCOUNT_SRV_BITFLAG | ACCOUNT_CAR_BITFLAG
							get_subordinates(JOB_NAME_HEADOFPERSONNEL)
						if((ACCESS_HOS in inserted_scan_id.access) && ((target_dept==DEPT_SEC) || !target_dept))
							region_access |= DEPT_SEC
							region_access_payment |= ACCOUNT_SEC_BITFLAG
							get_subordinates(JOB_NAME_HEADOFSECURITY)
						if((ACCESS_CMO in inserted_scan_id.access) && ((target_dept==DEPT_MED) || !target_dept))
							region_access |= DEPT_MED
							region_access_payment |= ACCOUNT_MED_BITFLAG
							get_subordinates(JOB_NAME_CHIEFMEDICALOFFICER)
						if((ACCESS_RD in inserted_scan_id.access) && ((target_dept==DEPT_SCI) || !target_dept))
							region_access |= DEPT_SCI
							region_access_payment |= ACCOUNT_SCI_BITFLAG
							get_subordinates(JOB_NAME_RESEARCHDIRECTOR)
						if((ACCESS_CE in inserted_scan_id.access) && ((target_dept==DEPT_ENG) || !target_dept))
							region_access |= DEPT_ENG
							region_access_payment |= ACCOUNT_ENG_BITFLAG
							get_subordinates(JOB_NAME_CHIEFENGINEER)
						if(region_access)
							authenticated = 1
			else if ((!( authenticated ) && issilicon(usr)) && (!inserted_modify_id))
				to_chat(usr, "<span class='warning'>You can't modify an ID without an ID inserted to modify! Once one is in the modify slot on the computer, you can log in.</span>")
		if ("logout")
			region_access = null
			head_subordinates = null
			authenticated = 0
			playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)

		if("access")
			if(href_list["allowed"])
				if(authenticated)
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in (istype(src, /obj/machinery/computer/card/centcom)?get_all_centcom_access() : get_all_accesses()))
						inserted_modify_id.access -= access_type
						log_id("[key_name(usr)] removed [get_access_desc(access_type)] from [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")
						if(access_allowed == 1)
							inserted_modify_id.access |= access_type
							log_id("[key_name(usr)] added [get_access_desc(access_type)] to [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")
						playsound(src, "terminal_type", 50, FALSE)
		if ("assign")
			if (authenticated == 2)
				var/datum/bank_account/B = inserted_modify_id?.registered_account
				var/datum/data/record/R = find_record("name", inserted_modify_id.registered_name, GLOB.data_core.general)
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
					if(R)
						for(var/each in B.payment_per_department)
							if(SSeconomy.is_nonstation_account(each)) // do not touch VIP/Command flag
								continue
							R.fields["active_dept"] &= ~SSeconomy.get_budget_acc_bitflag(each) // turn off all bitflag for each department except for VIP/Command. *note: this actually shouldn't use `get_budget_acc_bitflag()` proc, because bitflags are the same but these have a different purpose.
						R.fields["active_dept"] &= ~DEPT_BITFLAG_COM  // micromanagement2. the reason is the same. Command should be removed manually.


					log_id("[key_name(usr)] unassigned and stripped all access from [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")

				else
					var/datum/job/jobdatum
					if(!istype(src, /obj/machinery/computer/card/centcom)) // station level
						jobdatum = SSjob.GetJob(t1)
						if(!jobdatum)
							to_chat(usr, "<span class='warning'>No log exists for this job.</span>")
							stack_trace("bad job string '[t1]' is given through HoP console by '[ckey(usr)]'")
							updateUsrDialog()
							return

						inserted_modify_id.access -= get_all_accesses()
						inserted_modify_id.access |= jobdatum.get_access()
					else // centcom level
						inserted_modify_id.access -= get_all_centcom_access()
						inserted_modify_id.access |= get_centcom_access(t1)

					// Step 1: reseting theirs first
					if(B && jobdatum) // 1-A: reseting bank payment
						for(var/each in inserted_modify_id.registered_account.payment_per_department)
							if(SSeconomy.is_nonstation_account(each))
								continue
							B.active_departments &= ~SSeconomy.get_budget_acc_bitflag(each)
							B.payment_per_department[each] = 0
							B.bonus_per_department[each] = 0
						B.active_departments &= ~SSeconomy.get_budget_acc_bitflag(ACCOUNT_COM_ID) // micromanagement
					if(R && jobdatum) // 1-B: reseting crew manifest
						for(var/each in available_paycheck_departments)
							if(SSeconomy.is_nonstation_account(each))
								continue
							R.fields["active_dept"] &= ~SSeconomy.get_budget_acc_bitflag(each)
						R.fields["active_dept"] &= ~DEPT_BITFLAG_COM  // micromanagement2
						// Note: `fields["active_dept"] = NONE` is a bad idea because you should keep VIP_BITFLAG.
					// Step 2: giving the job info into their bank and record
					if(B && jobdatum) // 2-A: setting bank payment
						for(var/each in jobdatum.payment_per_department)
							if(SSeconomy.is_nonstation_account(each))
								continue
							B.payment_per_department[each] = jobdatum.payment_per_department[each]
						B.active_departments |= jobdatum.bank_account_department
					if(R && jobdatum) // 2-B: setting crew manifest
						R.fields["active_dept"] |= jobdatum.departments

					log_id("[key_name(usr)] assigned [jobdatum || t1] job to [inserted_modify_id], manipulating it to the default access of the job using [inserted_scan_id] at [AREACOORD(usr)].")

				if (inserted_modify_id)
					inserted_modify_id.assignment = t1
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
				update_modify_manifest()

		if ("demote")
			if(inserted_modify_id.assignment in head_subordinates || inserted_modify_id.assignment == "Assistant")
				inserted_modify_id.assignment = "Demoted"
				log_id("[key_name(usr)] demoted [inserted_modify_id], unassigning the card without affecting access, using [inserted_scan_id] at [AREACOORD(usr)].")
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			else
				to_chat(usr, "<span class='error'>You are not authorized to demote this position.</span>")
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
						to_chat(usr, "<span class='error'>Invalid name entered.</span>")
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
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !target_dept)
				var/edit_job_target = href_list["job"]
				var/datum/job/j = SSjob.GetJob(edit_job_target)
				if(!j)
					updateUsrDialog()
					return 0
				if(can_open_job(j) != 1)
					updateUsrDialog()
					return 0
				if(opened_positions[edit_job_target] >= 0)
					GLOB.time_last_changed_position = world.time / 10
				j.total_positions++
				opened_positions[edit_job_target]++
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

		if("make_job_unavailable")
			// MAKE JOB POSITION UNAVAILABLE FOR LATE JOINERS
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !target_dept)
				var/edit_job_target = href_list["job"]
				var/datum/job/j = SSjob.GetJob(edit_job_target)
				if(!j)
					updateUsrDialog()
					return 0
				if(can_close_job(j) != 1)
					updateUsrDialog()
					return 0
				//Allow instant closing without cooldown if a position has been opened before
				if(opened_positions[edit_job_target] <= 0)
					GLOB.time_last_changed_position = world.time / 10
				j.total_positions--
				opened_positions[edit_job_target]--
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)

		if ("prioritize_job")
			// TOGGLE WHETHER JOB APPEARS AS PRIORITIZED IN THE LOBBY
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !target_dept)
				var/priority_target = href_list["job"]
				var/datum/job/j = SSjob.GetJob(priority_target)
				if(!j)
					updateUsrDialog()
					return 0
				var/priority = TRUE
				if(j in SSjob.prioritized_jobs)
					SSjob.prioritized_jobs -= j
					priority = FALSE
				else if(j.total_positions <= j.current_positions)
					to_chat(usr, "<span class='notice'>[j.title] has had all positions filled. Open up more slots before prioritizing it.</span>")
					updateUsrDialog()
					return
				else
					SSjob.prioritized_jobs += j
				to_chat(usr, "<span class='notice'>[j.title] has been successfully [priority ?  "prioritized" : "unprioritized"]. Potential employees will notice your request.</span>")
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
			var/new_pay = FLOOR(input(usr, "Input the new paycheck amount.", "Set new paycheck amount.", B.payment_per_department[target_paycheck]) as num|null, 1)
			if(isnull(new_pay))
				updateUsrDialog()
				return
			if(new_pay < 0)
				to_chat(usr, "<span class='warning'>Paychecks cannot be negative.</span>")
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
			var/new_bonus = FLOOR(input(usr, "Input the bonus amount. Negative values will dock paychecks.", "Set paycheck bonus", B.bonus_per_department[target_paycheck]) as num|null, 1)
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
			var/datum/data/record/R = find_record("name", inserted_modify_id.registered_name, GLOB.data_core.general)
			if(!R)
				updateUsrDialog()
				return

			if(R.fields["active_dept"] & target_bitflag)
				R.fields["active_dept"] &= ~target_bitflag // turn off
			else
				R.fields["active_dept"] |= target_bitflag // turn on

		if ("print")
			if (!( printing ))
				printing = 1
				say("Printing...")
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper( loc )
				var/t1 = "<B>Crew Manifest:</B><BR>"
				for(var/datum/data/record/t in sort_record(GLOB.data_core.general))
					t1 += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
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
			switch(alert("Would you like to open a new bank account?\nIt will cost 1,000 credits in [lowertext(initial(target_paycheck))] budget.","Open a new account","Yes","No"))
				if("No")
					return
				if("Yes")
					if(!B.has_money(NEW_BANK_ACCOUNT_COST))
						say("Insufficient budget balance, abort opening a new bank account.")
						return
			if (!(printing))
				printing = 1
				var/target_name = input("Write the bank owner's name", "Account owner's name?")
				if(!target_name)
					printing = null
					return
				if(!B.adjust_money(-NEW_BANK_ACCOUNT_COST)) // double fail check
					say("Insufficient budget balance, abort opening a new bank account.")
					printing = null
					return

				B = new /datum/bank_account(target_name, SSjob.GetJob(JOB_NAME_ASSISTANT))
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

/obj/machinery/computer/card/proc/get_subordinates(rank)
	for(var/datum/job/job in SSjob.occupations)
		if(rank in job.department_head)
			head_subordinates += job.title

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

/obj/machinery/computer/card/minor
	name = "department management console"
	desc = "You can use this to change ID's for specific departments."
	icon_screen = "idminor"
	circuit = /obj/item/circuitboard/computer/card/minor

/obj/machinery/computer/card/minor/Initialize(mapload)
	. = ..()
	var/obj/item/circuitboard/computer/card/minor/typed_circuit = circuit
	if(target_dept)
		typed_circuit.target_dept = target_dept
	else
		target_dept = typed_circuit.target_dept
	var/list/dept_list = list("general","security","medical","science","engineering")
	name = "[dept_list[target_dept]] department console"

/obj/machinery/computer/card/minor/hos
	target_dept = DEPT_SEC
	target_paycheck = ACCOUNT_SEC_ID
	icon_screen = "idhos"

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/card/minor/cmo
	target_dept = DEPT_MED
	target_paycheck = ACCOUNT_MED_ID
	icon_screen = "idcmo"

/obj/machinery/computer/card/minor/rd
	target_dept = DEPT_SCI
	target_paycheck = ACCOUNT_SCI_ID
	icon_screen = "idrd"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/card/minor/ce
	target_dept = DEPT_ENG
	target_paycheck = ACCOUNT_ENG_ID
	icon_screen = "idce"

	light_color = LIGHT_COLOR_YELLOW

#undef DEPT_ALL
#undef DEPT_GEN
#undef DEPT_SEC
#undef DEPT_MED
#undef DEPT_SCI
#undef DEPT_ENG
#undef DEPT_SUP

#undef NEW_BANK_ACCOUNT_COST
