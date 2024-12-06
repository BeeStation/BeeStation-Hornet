#define CARDCON_DEPARTMENT_CIVILIAN "Civilian"
#define CARDCON_DEPARTMENT_SECURITY "Security"
#define CARDCON_DEPARTMENT_MEDICAL "Medical"
#define CARDCON_DEPARTMENT_SUPPLY "Supply"
#define CARDCON_DEPARTMENT_SCIENCE "Science"
#define CARDCON_DEPARTMENT_ENGINEERING "Engineering"
#define CARDCON_DEPARTMENT_COMMAND "Command"

/datum/computer_file/program/paycheck_manager
	filename = "paycheck_manager"
	filedesc = "Pay Check Manager"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program for viewing and changing job slot avalibility."
	transfer_access = list(ACCESS_HEADS)
	requires_ntnet = 1
	size = 4
	tgui_id = "NtosPaycheckManager"
	program_icon = "address-book"

	//Which department this computer has access to.
	var/target_dept = DEPT_ALL
	//Which departments you are able to change the paychecks of.
	var/available_paycheck_departments = list()
	//Which department budget ID the target card gets their money from.
	var/target_paycheck = ACCOUNT_SRV_ID
	//For some reason everything was exploding if this was static.
	var/list/sub_managers

/datum/computer_file/program/paycheck_manager/New(obj/item/modular_computer/comp)
	. = ..()
	sub_managers = list(
		"[ACCESS_HOP]" = list(
			"department" = list(CARDCON_DEPARTMENT_SUPPLY, CARDCON_DEPARTMENT_COMMAND),
			"region" = 1,
			"head" = JOB_NAME_HEADOFPERSONNEL
		),
		"[ACCESS_HOS]" = list(
			"department" = CARDCON_DEPARTMENT_SECURITY,
			"region" = 2,
			"head" = JOB_NAME_HEADOFSECURITY
		),
		"[ACCESS_CMO]" = list(
			"department" = CARDCON_DEPARTMENT_MEDICAL,
			"region" = 3,
			"head" = JOB_NAME_CHIEFMEDICALOFFICER
		),
		"[ACCESS_RD]" = list(
			"department" = CARDCON_DEPARTMENT_SCIENCE,
			"region" = 4,
			"head" = JOB_NAME_RESEARCHDIRECTOR
		),
		"[ACCESS_CE]" = list(
			"department" = CARDCON_DEPARTMENT_ENGINEERING,
			"region" = 5,
			"head" = JOB_NAME_CHIEFENGINEER
		)
	)


/datum/computer_file/program/paycheck_manager/proc/authenticate(mob/user, obj/item/card/id/id_card)
	if(!id_card)
		return

	region_access = list()
	if(!target_dept && (ACCESS_CHANGE_IDS in id_card.access))
		minor = FALSE
		authenticated = TRUE
		update_static_data(user)
		return TRUE

	var/list/head_types = list()
	for(var/access_text in sub_managers)
		var/list/info = sub_managers[access_text]
		var/access = text2num(access_text)
		if((access in id_card.access) && ((info["region"] in target_dept) || !length(target_dept)))
			region_access |= info["region"]
			//I don't even know what I'm doing anymore
			head_types += info["head"]

	head_subordinates = list()
	if(length(head_types))
		for(var/j in SSjob.occupations)
			var/datum/job/job = j
			for(var/head in head_types)//god why
				if(head in job.department_head)
					head_subordinates += job.title

	if(length(region_access))
		minor = TRUE
		authenticated = TRUE
		update_static_data(user)
		return TRUE

	return FALSE

/datum/computer_file/program/paycheck_manager/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/computer_hardware/card_slot/card_slot2

	if(computer)
		card_slot2 = computer.all_components[MC_CARD2]
		data["have_id_slot"] = !!(card_slot2)
	else
		data["have_id_slot"] = FALSE

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

/datum/computer_file/program/paycheck_manager/ui_static_data(mob/user)
	var/list/data = list()
	data["minor"] = target_dept || minor ? TRUE : FALSE

	var/list/departments = target_dept
	if(isnull(departments))
		departments = list(
			CARDCON_DEPARTMENT_COMMAND = list(JOB_NAME_CAPTAIN),
			CARDCON_DEPARTMENT_ENGINEERING = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_ENGINEERING),
			CARDCON_DEPARTMENT_MEDICAL = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_MEDICAL),
			CARDCON_DEPARTMENT_SCIENCE = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SCIENCE),
			CARDCON_DEPARTMENT_SECURITY = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY),
			CARDCON_DEPARTMENT_SUPPLY = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CARGO),
			CARDCON_DEPARTMENT_CIVILIAN = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CIVILIAN)
		)

/datum/computer_file/program/paycheck_manager/ui_act(action, params)
	if(..())
		return TRUE

	if(!computer)
		return

	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = computer.all_components[MC_CARD2]

	if(!card_slot || !card_slot2)
		return

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = card_slot.stored_card
	var/obj/item/card/id/target_id_card = card_slot2.stored_card


/*
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
				var/datum/record/crew/record = find_record(B.account_holder, GLOB.manifest.general)
				dat += "<tr>"
				dat += "<td>[B.account_holder] [B.suspended ? "(Account closed)" : ""]</td>"
				dat += "<td>[record ? record.rank : "(No data)"]</td>"
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
*/

#undef CARDCON_DEPARTMENT_CIVILIAN
#undef CARDCON_DEPARTMENT_SECURITY
#undef CARDCON_DEPARTMENT_MEDICAL
#undef CARDCON_DEPARTMENT_SCIENCE
#undef CARDCON_DEPARTMENT_SUPPLY
#undef CARDCON_DEPARTMENT_ENGINEERING
#undef CARDCON_DEPARTMENT_COMMAND
