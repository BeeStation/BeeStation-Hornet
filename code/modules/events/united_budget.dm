/datum/round_event_control/united_budget_setup
	name = "United budget - Setup"
	typepath = /datum/round_event/united_budget_setup
	max_occurrences = 0

/datum/round_event/united_budget_setup
	announceWhen	= 0

/datum/round_event/united_budget_setup/announce()
	priority_announce("As your station is selected for our financial experiments, all station budgets are united into one, and all budget cards will be linked to that one.", "Central Command Update", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/united_budget_setup/start()
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		SSstation.station_traits += new /datum/station_trait/united_budget
		SSeconomy.united_budget_trait = TRUE
	else
		return

	for(var/obj/item/card/id/departmental_budget/I in SSeconomy.dep_cards)
		var/datum/bank_account/B = SSeconomy.get_dep_account(ACCOUNT_CAR_ID)
		if(B)
			if(B.is_nonstation_account())
				continue
			I.registered_account = B
			I.department_ID = ACCOUNT_CAR_ID
			I.department_name = ACCOUNT_ALL_NAME
			I.name = "departmental card ([I.department_name])"
			I.desc = "Provides access to the [I.department_name]."

	var/money_to_gather = 0
	for(var/i in SSeconomy.department_accounts)
		var/datum/bank_account/department/D = SSeconomy.get_dep_account(i)
		money_to_gather += D.account_balance
	var/datum/bank_account/department/D = SSeconomy.get_dep_account(ACCOUNT_CAR_ID)
	D.account_balance = round(money_to_gather)
	D.account_holder = ACCOUNT_ALL_NAME
	SSeconomy.department_accounts[ACCOUNT_CAR_ID] = ACCOUNT_ALL_NAME

//-----------------------------------------------------------------------------------------
/datum/round_event_control/united_budget_cancel
	name = "United budget - Cancel"
	typepath = /datum/round_event/united_budget_cancel
	max_occurrences = 0

/datum/round_event/united_budget_cancel
	announceWhen	= 0

/datum/round_event/united_budget_cancel/announce()
	priority_announce("We reverted our previous budget plan that was applied to your station. All budget accounts that was once linked to one will work individually again.", "Central Command Update", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/united_budget_cancel/start()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		for(var/datum/station_trait/united_budget/target_trait in SSstation.station_traits) // an easy way to grab a specific datum
			SSstation.station_traits -= target_trait
			qdel(target_trait)
		SSstation.status_traits -= STATION_TRAIT_UNITED_BUDGET
		SSeconomy.united_budget_trait = FALSE
	else
		return

	for(var/obj/item/card/id/departmental_budget/I in SSeconomy.dep_cards)
		var/datum/bank_account/B = SSeconomy.get_dep_account(initial(I.department_ID))
		if(B)
			if(B.is_nonstation_account())
				continue
			I.registered_account = B
			I.department_ID = initial(I.department_ID)
			I.department_name = initial(I.department_name)
			I.name = "departmental card ([I.department_name])"
			I.desc = "Provides access to the [I.department_name]."

	var/money_to_distribute = round(SSeconomy.get_dep_account(ACCOUNT_CAR_ID).account_balance / SSeconomy.department_accounts.len)
	for(var/i in SSeconomy.department_accounts)
		var/datum/bank_account/department/D = SSeconomy.get_dep_account(i)
		D.account_balance = money_to_distribute

	var/datum/bank_account/department/D = SSeconomy.get_dep_account(ACCOUNT_CAR_ID)
	D.account_holder = ACCOUNT_CAR_NAME
	SSeconomy.department_accounts[ACCOUNT_CAR_ID] = ACCOUNT_CAR_NAME
