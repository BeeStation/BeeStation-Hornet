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

	//Bitflag for which departments this program has access to.
	var/target_dept = DEPARTMENTAL_FLAG_ALL
	//Which department budget ID the target card gets their money from.
	var/target_paycheck = ACCOUNT_CIV_ID

/datum/computer_file/program/paycheck_manager/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosPaycheckManager")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/computer_file/program/paycheck_manager/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/computer_hardware/card_slot/card_slot2

	if(computer)
		card_slot2 = computer.all_components[MC_CARD2]
		data["have_id_slot"] = !!(card_slot2)
	else
		data["have_id_slot"] = FALSE

	if(!card_slot2)
		return data //We're just gonna error out on the js side at this point anyway

	var/authenticated = FALSE
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/user_id = card_slot?.stored_card
	if(user_id)
		if(ACCESS_HEADS in user_id.access)
			authenticated = TRUE


		var/list/paycheck_departments = list()

		if(ACCESS_CAPTAIN in user_id.access)
			paycheck_departments |= ACCOUNT_COM_ID //Captains can adjust the pay of their underling heads of staff.
		if(ACCESS_HOS in user_id.access)
			paycheck_departments |= ACCOUNT_SEC_ID
		if(ACCESS_CMO in user_id.access)
			paycheck_departments |= ACCOUNT_MED_ID
		if(ACCESS_RD in user_id.access)
			paycheck_departments |= ACCOUNT_SCI_ID
		if(ACCESS_CE in user_id.access)
			paycheck_departments |= ACCOUNT_ENG_ID
		if(ACCESS_HOP in user_id.access) // HOP can adjust all department's (besides command) pay rates. After all they are a head of PERSONNEL
			paycheck_departments |= ACCOUNT_SRV_ID
			paycheck_departments |= ACCOUNT_CIV_ID
			paycheck_departments |= ACCOUNT_CAR_ID //Currently no seperation between service/civillian and supply
			paycheck_departments |= ACCOUNT_SEC_ID
			paycheck_departments |= ACCOUNT_MED_ID
			paycheck_departments |= ACCOUNT_SCI_ID
			paycheck_departments |= ACCOUNT_ENG_ID

		data["departments"] = paycheck_departments
		data["authenticated"] = authenticated

	var/obj/item/card/id/id_card = card_slot2.stored_card
	data["target_id"] = id_card
	if(id_card)
		data["target_id_rank"] = id_card.assignment ? id_card.assignment : "Unassigned"
		data["target_id_owner"] = id_card.registered_name ? id_card.registered_name : "--------------"
		if(id_card.registered_account)
			data["registered_bank_account"] = id_card.registered_account
			data["payment_per_department"]  = id_card.registered_account.payment_per_department
			data["payment_per_department"]  = id_card.registered_account.payment_per_department
			data["transaction_history"]		= id_card.registered_account.transaction_history
			data["active_department"]		= id_card.registered_account.active_departments
	return data

/datum/computer_file/program/paycheck_manager/ui_act(action, params)
	if(..())
		return TRUE
	if(!computer)
		return
	var/obj/item/computer_hardware/card_slot/card_slot2 = computer.all_components[MC_CARD2]
	var/obj/item/card/id/id_card = card_slot2.stored_card
	var/mob/user = usr
	switch(action)
		if("eject_target_id")
			eject_target_id(user, id_card)
			. = TRUE
		if("create_account")
			. = TRUE
		if("delete_account")
			. = TRUE
		if("set_pay")
			. = TRUE
		if("set_bonus")
			. = TRUE
		if("set_department_vendor")
			. = TRUE
	return TRUE

/datum/computer_file/program/paycheck_manager/proc/eject_target_id(mob/user, obj/item/card/id/target_id_card)
	var/obj/item/computer_hardware/card_slot/card_slot2 = computer.all_components[MC_CARD2]
	if(!card_slot2)
		return FALSE
	if(target_id_card)
		return card_slot2.try_eject(user)
	else
		var/obj/item/id_card = user.get_active_held_item()
		if(istype(id_card, /obj/item/card/id))
			return card_slot2.try_insert(id_card, user)
	return FALSE

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
