#define DEPT_ALL 0
#define DEPT_GEN 1
#define DEPT_SEC 2
#define DEPT_MED 3
#define DEPT_SCI 4
#define DEPT_ENG 5
#define DEPT_SUP 6

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
	var/list/head_subordinates = null

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/card/Initialize(mapload)
	. = ..()
	change_position_cooldown = CONFIG_GET(number/id_console_jobslot_delay)
	for(var/G in typesof(/datum/job/gimmick))
		var/datum/job/gimmick/J = new G
		blacklisted += J.title

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
	if(inserted_modify_id.registered_account)
		inserted_modify_id.registered_account.account_department = get_department_by_hud(inserted_modify_id.hud_state) // your true department by your hud icon color
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
		for(var/datum/data/record/t in sortRecord(GLOB.data_core.general))
			crew += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
		dat = "<tt><b>Crew Manifest:</b><br>Please use security record computer to modify entries.<br><br>[crew]<a href='?src=[REF(src)];choice=print'>Print</a><br><br><a href='?src=[REF(src)];choice=mode;mode_target=0'>Access ID modification console.</a><br></tt>"

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
		dat += "<tr><td style='width:25%'><b>Job</b></td><td style='width:25%'><b>Slots</b></td><td style='width:25%'><b>Open job</b></td><td style='width:25%'><b>Close job</b><td style='width:25%'><b>Prioritize</b></td></td></tr>"
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
				paycheck_departments |= ACCOUNT_SRV
				paycheck_departments |= ACCOUNT_CIV
				paycheck_departments |= ACCOUNT_CAR //Currently no seperation between service/civillian and supply
			if((ACCESS_HOS in inserted_scan_id.access) && ((target_dept==DEPT_SEC) || !target_dept))
				paycheck_departments |= ACCOUNT_SEC
			if((ACCESS_CMO in inserted_scan_id.access) && ((target_dept==DEPT_MED) || !target_dept))
				paycheck_departments |= ACCOUNT_MED
			if((ACCESS_RD in inserted_scan_id.access) && ((target_dept==DEPT_SCI) || !target_dept))
				paycheck_departments |= ACCOUNT_SCI
			if((ACCESS_CE in inserted_scan_id.access) && ((target_dept==DEPT_ENG) || !target_dept))
				paycheck_departments |= ACCOUNT_ENG
		else
			S = "--------"
		dat += "<a href='?src=[REF(src)];choice=inserted_scan_id'>[S]</a>"
		dat += "<table>"
		dat += "<tr><td style='width:25%'><b>Name</b></td><td style='width:25%'><b>Job</b></td><td style='width:25%'><b>Paycheck</b></td><td style='width:25%'><b>Pay Bonus</b></td></tr>"

		for(var/A in SSeconomy.bank_accounts)
			var/datum/bank_account/B = A
			if(!(B.account_department in paycheck_departments))
				continue
			dat += "<tr>"
			dat += "<td>[B.account_holder]</td>"
			dat += "<td>[B.account_job.title]</td>"
			dat += "<td><a href='?src=[REF(src)];choice=adjust_pay;account=[B.account_holder]'>$[B.paycheck_amount]</a></td>"
			dat += "<td><a href='?src=[REF(src)];choice=adjust_bonus;account=[B.account_holder]'>$[B.paycheck_bonus]</a></td>"
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
			if(job == JOB_NAME_CHIEFENGINEER)
				jobs_all += "<br/>* Engineering: "
			if(job == JOB_NAME_RESEARCHDIRECTOR)
				jobs_all += "<br/>* R&D: "
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

			var/accesses = ""
			if(istype(src, /obj/machinery/computer/card/centcom))
				accesses += "<h5>Central Command:</h5>"
				for(var/A in get_all_centcom_access())
					if(A in inserted_modify_id.access)
						accesses += "<a href='?src=[REF(src)];choice=access;access_target=[A];allowed=0'><font color=\"6bc473\">[replacetext(get_centcom_access_desc(A), " ", "&nbsp")]</font></a> "
					else
						accesses += "<a href='?src=[REF(src)];choice=access;access_target=[A];allowed=1'>[replacetext(get_centcom_access_desc(A), " ", "&nbsp")]</a> "
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
			body = "[carddesc]<br>[jobs]<br><br>[accesses]" //CHECK THIS

		else
			body = "<a href='?src=[REF(src)];choice=auth'>{Log in}</a> <br><hr>"
			body += "<a href='?src=[REF(src)];choice=mode;mode_target=1'>Access Crew Manifest</a>"
			if(!target_dept)
				body += "<br><hr><a href = '?src=[REF(src)];choice=mode;mode_target=2'>Job Management</a>"
			body += "<a href='?src=[REF(src)];choice=mode;mode_target=3'>Paycheck Management</a>"

		dat = "<tt>[header][body]<hr><br></tt>"
	var/datum/browser/popup = new(user, "id_com", src.name, 900, 620)
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
					head_subordinates = list()
					if(ACCESS_CHANGE_IDS in inserted_scan_id.access)
						if(target_dept)
							head_subordinates = get_all_jobs()
							region_access |= target_dept
							authenticated = 1
						else
							authenticated = 2
						playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)

					else
						if((ACCESS_HOP in inserted_scan_id.access) && ((target_dept==DEPT_GEN) || !target_dept))
							region_access |= DEPT_GEN
							region_access |= DEPT_SUP //Currently no seperation between service/civillian and supply
							get_subordinates(JOB_NAME_HEADOFPERSONNEL)
						if((ACCESS_HOS in inserted_scan_id.access) && ((target_dept==DEPT_SEC) || !target_dept))
							region_access |= DEPT_SEC
							get_subordinates(JOB_NAME_HEADOFSECURITY)
						if((ACCESS_CMO in inserted_scan_id.access) && ((target_dept==DEPT_MED) || !target_dept))
							region_access |= DEPT_MED
							get_subordinates(JOB_NAME_CHIEFMEDICALOFFICER)
						if((ACCESS_RD in inserted_scan_id.access) && ((target_dept==DEPT_SCI) || !target_dept))
							region_access |= DEPT_SCI
							get_subordinates(JOB_NAME_RESEARCHDIRECTOR)
						if((ACCESS_CE in inserted_scan_id.access) && ((target_dept==DEPT_ENG) || !target_dept))
							region_access |= DEPT_ENG
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
							inserted_modify_id.access += access_type
							log_id("[key_name(usr)] added [get_access_desc(access_type)] to [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")
						playsound(src, "terminal_type", 50, FALSE)
		if ("assign")
			if (authenticated == 2)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/newJob = reject_bad_text(stripped_input("Enter a custom job assignment.", "Assignment", inserted_modify_id ? inserted_modify_id.assignment : "Unassigned"), MAX_NAME_LEN)
					if(newJob)
						t1 = newJob
						log_id("[key_name(usr)] changed [inserted_modify_id] assignment to [newJob] using [inserted_scan_id] at [AREACOORD(usr)].")

				else if(t1 == "Unassigned")
					inserted_modify_id.access -= get_all_accesses()
					log_id("[key_name(usr)] unassigned and stripped all access from [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")

				else
					var/datum/job/jobdatum
					for(var/jobtype in typesof(/datum/job))
						var/datum/job/J = new jobtype
						if(ckey(J.title) == ckey(t1))
							jobdatum = J
							updateUsrDialog()
							break

					if(!jobdatum)
						to_chat(usr, "<span class='error'>No log exists for this job.</span>")
						updateUsrDialog()
						return

					inserted_modify_id.access = ( istype(src, /obj/machinery/computer/card/centcom) ? get_centcom_access(t1) : jobdatum.get_access() )
					log_id("[key_name(usr)] assigned [jobdatum] job to [inserted_modify_id], overriding all previous access using [inserted_scan_id] at [AREACOORD(usr)].")

				if (inserted_modify_id)
					inserted_modify_id.assignment = t1
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
		if ("demote")
			if(inserted_modify_id.assignment in head_subordinates || inserted_modify_id.assignment == "Assistant")
				inserted_modify_id.assignment = "Unassigned"
				log_id("[key_name(usr)] demoted [inserted_modify_id], unassigning the card without affecting access, using [inserted_scan_id] at [AREACOORD(usr)].")
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			else
				to_chat(usr, "<span class='error'>You are not authorized to demote this position.</span>")
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

		if ("adjust_pay")
			//Adjust the paycheck of a crew member. Can't be less than zero.
			if(!inserted_scan_id)
				updateUsrDialog()
				return
			var/account_name = href_list["account"]
			var/datum/bank_account/account = null
			for(var/datum/bank_account/B in SSeconomy.bank_accounts)
				if(B.account_holder == account_name)
					account = B
					break
			if(isnull(account))
				updateUsrDialog()
				return
			switch(account.account_department) //Checking if the user has access to change pay.
				if(ACCOUNT_SRV,ACCOUNT_CIV,ACCOUNT_CAR)
					if(!(ACCESS_HOP in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_SEC)
					if(!(ACCESS_HOS in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_MED)
					if(!(ACCESS_CMO in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_SCI)
					if(!(ACCESS_RD in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_ENG)
					if(!(ACCESS_CE in inserted_scan_id.access))
						updateUsrDialog()
						return
			var/new_pay = FLOOR(input(usr, "Input the new paycheck amount.", "Set new paycheck amount.", account.paycheck_amount) as num|null, 1)
			if(isnull(new_pay))
				updateUsrDialog()
				return
			if(new_pay < 0)
				to_chat(usr, "<span class='warning'>Paychecks cannot be negative.</span>")
				updateUsrDialog()
				return
			account.paycheck_amount = new_pay

		if ("adjust_bonus")
			//Adjust the bonus pay of a crew member. Negative amounts dock pay.
			if(!inserted_scan_id)
				updateUsrDialog()
				return
			var/account_name = href_list["account"]
			var/datum/bank_account/account = null
			for(var/datum/bank_account/B in SSeconomy.bank_accounts)
				if(B.account_holder == account_name)
					account = B
					break
			if(isnull(account))
				updateUsrDialog()
				return
			switch(account.account_department) //Checking if the user has access to change pay.
				if(ACCOUNT_SRV,ACCOUNT_CIV,ACCOUNT_CAR)
					if(!(ACCESS_HOP in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_SEC)
					if(!(ACCESS_HOS in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_MED)
					if(!(ACCESS_CMO in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_SCI)
					if(!(ACCESS_RD in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_ENG)
					if(!(ACCESS_CE in inserted_scan_id.access))
						updateUsrDialog()
						return
			var/new_bonus = FLOOR(input(usr, "Input the bonus amount. Negative values will dock paychecks.", "Set paycheck bonus", account.paycheck_bonus) as num|null, 1)
			if(isnull(new_bonus))
				updateUsrDialog()
				return
			account.paycheck_bonus = new_bonus

		if ("print")
			if (!( printing ))
				printing = 1
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper( loc )
				var/t1 = "<B>Crew Manifest:</B><BR>"
				for(var/datum/data/record/t in sortRecord(GLOB.data_core.general))
					t1 += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
				P.info = t1
				P.name = "paper- 'Crew Manifest'"
				printing = null
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	if (inserted_modify_id)
		inserted_modify_id.update_label()
	updateUsrDialog()

/obj/machinery/computer/card/proc/get_subordinates(rank)
	for(var/datum/job/job in SSjob.occupations)
		if(rank in job.department_head)
			head_subordinates += job.title

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
	icon_screen = "idhos"

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/card/minor/cmo
	target_dept = DEPT_MED
	icon_screen = "idcmo"

/obj/machinery/computer/card/minor/rd
	target_dept = DEPT_SCI
	icon_screen = "idrd"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/card/minor/ce
	target_dept = DEPT_ENG
	icon_screen = "idce"

	light_color = LIGHT_COLOR_YELLOW

#undef DEPT_ALL
#undef DEPT_GEN
#undef DEPT_SEC
#undef DEPT_MED
#undef DEPT_SCI
#undef DEPT_ENG
#undef DEPT_SUP
