/datum/round_event_control/united_budget_setup
	name = "United budget - Setup"
	typepath = /datum/round_event/united_budget_setup
	max_occurrences = 0

/datum/round_event/united_budget_setup
	announceWhen	= 0

/datum/round_event/united_budget_setup/announce()
	priority_announce("Your station has been selected for one of our financial experiments! All station budgets have been united into one, and all budget cards will be linked to one account!", "Central Command Update", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/united_budget_setup/start()
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		SSstation.station_traits += new /datum/station_trait/united_budget
	else
		return

	var/datum/bank_account/department/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	for(var/obj/item/card/id/departmental_budget/I in SSeconomy.dep_cards)
		I.registered_account = D
		I.department_ID = ACCOUNT_CAR_ID
		I.department_name = ACCOUNT_ALL_NAME
		I.name = "departmental card ([I.department_name])"
		I.desc = "Provides access to the [I.department_name] budget."

	var/money_to_gather = 0

	for(var/datum/bank_account/department/each in SSeconomy.budget_accounts)
		if(!each.is_nonstation_account())
			money_to_gather += each.account_balance
	D.account_balance = round(money_to_gather)
	D.account_holder = ACCOUNT_ALL_NAME

//-----------------------------------------------------------------------------------------
/datum/round_event_control/united_budget_cancel
	name = "United budget - Cancel"
	typepath = /datum/round_event/united_budget_cancel
	max_occurrences = 0

/datum/round_event/united_budget_cancel
	announceWhen	= 0

/datum/round_event/united_budget_cancel/announce()
	priority_announce("All unified budget accounts have been converted to individual departmental accounts.", "Central Command Update", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/united_budget_cancel/start()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		for(var/datum/station_trait/united_budget/target_trait in SSstation.station_traits) // an easy way to grab a specific datum
			SSstation.station_traits -= target_trait
			qdel(target_trait)
		SSstation.status_traits -= STATION_TRAIT_UNITED_BUDGET
	else
		return

	for(var/obj/item/card/id/departmental_budget/I in SSeconomy.dep_cards)
		var/datum/bank_account/department/B = SSeconomy.get_budget_account(initial(I.department_ID))
		if(B)
			if(B.is_nonstation_account())
				continue
			I.registered_account = B
			I.department_ID = initial(I.department_ID)
			I.department_name = initial(I.department_name)
			I.name = "departmental card ([I.department_name])"
			I.desc = "Provides access to the [I.department_name] budget."

	var/datum/bank_account/department/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	D.account_holder = ACCOUNT_CAR_NAME // recover the true name

	var/budget_size = 0
	for(var/datum/bank_account/department/each in SSeconomy.budget_accounts)
		if(!each.is_nonstation_account())
			budget_size++
	var/money_to_distribute = round(D.account_balance / budget_size)
	for(var/datum/bank_account/department/each in SSeconomy.budget_accounts)
		if(!each.is_nonstation_account())
			each.account_balance = money_to_distribute

