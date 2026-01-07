#define ACCOUNT_CREATION_MAX_ATTEMPT 2000

/datum/bank_account
	var/account_holder = "Rusty Venture"
	var/account_balance = 0
	var/custom_currency = list(ACCOUNT_CURRENCY_MINING = 0)
	var/datum/job/account_job
	/// List of physical cards that bound to this account
	var/list/bank_cards = list()
	/// If TRUE, SSeconomy will store an account into `SSeconomy.bank_accounts`
	var/add_to_accounts = TRUE
	var/account_id
	var/withdrawDelay = 0
	/// used for cryo'ed people's account. Once it's TRUE, most bank features of the bank account will be disabled.
	var/suspended = FALSE

	/// active department will sell things for free
	var/active_departments = NONE
	/// payment from each department.
	var/list/payment_per_department = list()
	/// bonus from each department.
	var/list/bonus_per_department = list()

/datum/bank_account/New(newname, job)
	account_holder = newname
	account_job = job
	account_id = rand(111111,999999)
	for(var/i in 1 to ACCOUNT_CREATION_MAX_ATTEMPT)
		if(!SSeconomy.get_bank_account_by_id(account_id)) // Don't get the same account ID
			break
		account_id = rand(111111,999999)
		if(i == ACCOUNT_CREATION_MAX_ATTEMPT)
			CRASH("Something's wrong on creating a bank account")

	// initialising payment data into an account for each department including non-station
	for(var/datum/bank_account/department/each as() in subtypesof(/datum/bank_account/department))
		payment_per_department += list("[initial(each.department_id)]"=0)
		bonus_per_department += list("[initial(each.department_id)]"=0)

	active_departments = account_job.bank_account_department
	for(var/D in account_job.payment_per_department)
		payment_per_department[D] = account_job.payment_per_department[D]

	if(add_to_accounts)
		SSeconomy.bank_accounts += src // this should be added when New() is finished

/datum/bank_account/Destroy()
	if(add_to_accounts)
		SSeconomy.bank_accounts -= src
	return ..()

/datum/bank_account/proc/_adjust_money(amt)
	account_balance += amt
	if(account_balance < 0)
		account_balance = 0

/datum/bank_account/proc/has_money(amt)
	return account_balance >= amt

/datum/bank_account/proc/adjust_money(amt)
	if((amt < 0 && has_money(-amt)) || amt > 0)
		_adjust_money(amt)
		return TRUE
	return FALSE

/datum/bank_account/proc/transfer_money(datum/bank_account/from, amount)
	if(from.has_money(amount))
		adjust_money(amount)
		SSblackbox.record_feedback("amount", "credits_transferred", amount)
		log_econ("[amount] credits were transferred from [from.account_holder]'s account to [src.account_holder]")
		from.adjust_money(-amount)
		return TRUE
	return FALSE

/datum/bank_account/proc/payday(amt_of_paychecks, free = FALSE)
	if(suspended)
		bank_card_talk("ERROR: Payday aborted, account closed by Nanotrasen Space Finance.")
		return

	for(var/D in payment_per_department)
		if(payment_per_department[D] <= 0 && bonus_per_department[D] <= 0)
			continue

		var/money_to_transfer = payment_per_department[D] * amt_of_paychecks
		if((money_to_transfer + bonus_per_department[D]) < 0) //Check if the bonus is docking more pay than possible
			bonus_per_department[D] -= money_to_transfer //Remove the debt with the payday
			money_to_transfer = 0 //No money for you
		else
			money_to_transfer += bonus_per_department[D]
		if(free)
			adjust_money(money_to_transfer)
			SSblackbox.record_feedback("amount", "free_income", money_to_transfer)
			log_econ("[money_to_transfer] credits were given to [src.account_holder]'s account from income.")
			if(bonus_per_department[D] > 0) //Get rid of bonus if we have one
				bonus_per_department[D] = 0
		else
			var/datum/bank_account/B = SSeconomy.get_budget_account(D)
			if(!B)
				bank_card_talk("ERROR: Payday aborted, unable to query [D] departmental account.")
			else
				if(!transfer_money(B, money_to_transfer))
					bank_card_talk("ERROR: Payday aborted, [D] departmental funds insufficient.")
					bonus_per_department[D] += (money_to_transfer-bonus_per_department[D]) // you'll get paid someday
					continue
				else
					bank_card_talk("Payday processed, account now holds $[account_balance], paid with $[money_to_transfer] from [D] budget.")
					//The bonus only resets once it goes through.
					if(bonus_per_department[D] > 0) //And we're not getting rid of debt
						bonus_per_department[D] = 0

/datum/bank_account/proc/bank_card_talk(message, force)
	if(!message || !bank_cards.len)
		return
	for(var/obj/A in bank_cards)
		var/mob/card_holder = recursive_loc_check(A, /mob)
		if(ismob(card_holder)) //If on a mob
			if(card_holder.client && !card_holder.client.prefs.read_player_preference(/datum/preference/toggle/chat_bankcard) && !force)
				return

			card_holder.playsound_local(get_turf(card_holder), 'sound/machines/twobeep_high.ogg', 50, TRUE)
			if(card_holder.can_hear())
				to_chat(card_holder, "[icon2html(A, card_holder)] *[message]*")
		else if(isturf(A.loc)) //If on the ground
			for(var/mob/M as() in hearers(1,get_turf(A)))
				if(M.client && !M.client.prefs.read_player_preference(/datum/preference/toggle/chat_bankcard) && !force)
					return
				playsound(A, 'sound/machines/twobeep_high.ogg', 50, TRUE)
				A.audible_message("[icon2html(A, hearers(A))] *[message]*", null, 1)
				break
		else
			for(var/mob/M in A.loc) //If inside a container with other mobs (e.g. locker)
				if(M.client && !M.client.prefs.read_player_preference(/datum/preference/toggle/chat_bankcard) && !force)
					return
				M.playsound_local(get_turf(M), 'sound/machines/twobeep_high.ogg', 50, TRUE)
				if(M.can_hear())
					to_chat(M, "[icon2html(A, M)] *[message]*")

/datum/bank_account/proc/_adjust_currency(type, amt)
	custom_currency[type] += amt
	if(custom_currency[type] < 0)
		custom_currency[type] = 0

/datum/bank_account/proc/adjust_currency(type, amt)
	if((amt < 0 && has_currency(type, -amt)) || amt > 0)
		_adjust_currency(type, amt)
		return TRUE
	return FALSE

/datum/bank_account/proc/has_currency(type, amt)
	return custom_currency[type] >= amt

/datum/bank_account/proc/report_currency(type)
	return custom_currency[type]

/datum/bank_account/department
	account_holder = "Guild Credit Agency"
	var/department_id = "REPLACE_ME"
	var/department_bitflag = NONE
	/// ratio as how a department takes money when a station get a profit
	var/budget_ratio = NONE
	/// if this is staton budget, set it as FALSE
	var/nonstation_account = TRUE
	/// used by non-station budgets to give specific amount of budgets
	var/exclusive_budget_pool
	/// basically non-station budgets are not good to show. These need to be FALSE.
	var/show_budget_information = TRUE
	/// Starting budget override for the depatmental bank account
	var/starting_budget
	add_to_accounts = FALSE

/datum/bank_account/department/New(budget)
	account_balance = exclusive_budget_pool ? exclusive_budget_pool : budget

/datum/bank_account/department/civilian
	account_holder = ACCOUNT_CIV_NAME
	department_id = ACCOUNT_CIV_ID
	department_bitflag = ACCOUNT_CIV_BITFLAG
	budget_ratio = BUDGET_RATIO_TYPE_SINGLE
	nonstation_account = FALSE

/datum/bank_account/department/service
	account_holder = ACCOUNT_SRV_NAME
	department_id = ACCOUNT_SRV_ID
	department_bitflag = ACCOUNT_SRV_BITFLAG
	budget_ratio = BUDGET_RATIO_TYPE_SINGLE
	nonstation_account = FALSE

/datum/bank_account/department/cargo
	account_holder = ACCOUNT_CAR_NAME
	department_id = ACCOUNT_CAR_ID
	department_bitflag = ACCOUNT_CAR_BITFLAG
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE
	starting_budget = 2000 // Reduced due to export changes
	custom_currency = list(ACCOUNT_CURRENCY_MINING = 100) // enough to buy a bottle of whiskey!

/datum/bank_account/department/science
	account_holder = ACCOUNT_SCI_NAME
	department_id = ACCOUNT_SCI_ID
	department_bitflag = ACCOUNT_SCI_BITFLAG
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE
	custom_currency = list(ACCOUNT_CURRENCY_MINING = 0, ACCOUNT_CURRENCY_EXPLO = 0)

/datum/bank_account/department/engineering
	account_holder = ACCOUNT_ENG_NAME
	department_id = ACCOUNT_ENG_ID
	department_bitflag = ACCOUNT_ENG_BITFLAG
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE

/datum/bank_account/department/medical
	account_holder = ACCOUNT_MED_NAME
	department_id = ACCOUNT_MED_ID
	department_bitflag = ACCOUNT_MED_BITFLAG
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE

/datum/bank_account/department/security
	account_holder = ACCOUNT_SEC_NAME
	department_id = ACCOUNT_SEC_ID
	department_bitflag = ACCOUNT_SEC_BITFLAG
	budget_ratio = BUDGET_RATIO_TYPE_DOUBLE
	nonstation_account = FALSE

/datum/bank_account/department/command
	account_holder = ACCOUNT_COM_NAME
	department_id = ACCOUNT_COM_ID
	department_bitflag = ACCOUNT_COM_BITFLAG
	show_budget_information = FALSE

/datum/bank_account/department/command/New()
	exclusive_budget_pool = NON_STATION_BUDGET_BASE
	..()

/datum/bank_account/department/vip
	account_holder = ACCOUNT_VIP_NAME
	department_id = ACCOUNT_VIP_ID
	department_bitflag = ACCOUNT_VIP_BITFLAG
	show_budget_information = TRUE // good flavour to flex their wealth power

/datum/bank_account/department/vip/New()
	exclusive_budget_pool = NON_STATION_BUDGET_BASE
	..()

/datum/bank_account/department/welfare
	account_holder = ACCOUNT_NEET_NAME
	department_id = ACCOUNT_NEET_ID
	department_bitflag = NONE // this doesn't need bitflag

/datum/bank_account/department/welfare/New()
	exclusive_budget_pool = NON_STATION_BUDGET_BASE
	..()

// all golems will share this account on their cards. the unknown RD wasn't surely a rich who can make a bank account for every golem.
/datum/bank_account/department/mining_golem
	account_holder = ACCOUNT_GOLEM_NAME
	department_id = ACCOUNT_GOLEM_ID
	department_bitflag = NONE
	exclusive_budget_pool = 13 // oh no, someone used it! damn communism

/datum/bank_account/remote // Bank account not belonging to the local station
	add_to_accounts = FALSE

#undef ACCOUNT_CREATION_MAX_ATTEMPT
