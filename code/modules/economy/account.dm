#define DUMPTIME 3000

/datum/bank_account
	var/account_holder = "Rusty Venture"
	var/account_balance = 0
	var/datum/job/account_job
	var/list/bank_cards = list()
	var/add_to_accounts = TRUE
	var/account_id
	/// used for NEET quirk to give you extra credits
	var/welfare = FALSE
	var/being_dumped = FALSE //pink levels are rising
	var/withdrawDelay = 0
	/// used for cryo'ed people's account. Once it's TRUE, most bank features of the bank account will be disabled.
	var/suspended = FALSE

	///
	var/active_departments = NONE
	/// payment from each department.
	var/list/payment_per_department = list(
		ACCOUNT_CIV=1,
		ACCOUNT_SRV=2,
		ACCOUNT_CAR=3,
		ACCOUNT_ENG=4,
		ACCOUNT_SCI=5,
		ACCOUNT_MED=6,
		ACCOUNT_SEC=7,
		ACCOUNT_VIP=8
	)
	/// bonus from each department.
	var/list/bonus_per_department = list(
		ACCOUNT_CIV=0,
		ACCOUNT_SRV=0,
		ACCOUNT_CAR=0,
		ACCOUNT_ENG=0,
		ACCOUNT_SCI=0,
		ACCOUNT_MED=0,
		ACCOUNT_SEC=0,
		ACCOUNT_VIP=0
	)
	/// the amount of credits that would be returned to the station budgets before it siphons roundstart credits into void when its owner went cryo.
	var/list/total_paid_payment = list(
		ACCOUNT_CIV=0,
		ACCOUNT_SRV=0,
		ACCOUNT_CAR=0,
		ACCOUNT_ENG=0,
		ACCOUNT_SCI=0,
		ACCOUNT_MED=0,
		ACCOUNT_SEC=0,
		ACCOUNT_VIP=0
	)

/datum/bank_account/New(newname, job)
	if(add_to_accounts)
		SSeconomy.bank_accounts += src
	account_holder = newname
	account_job = job
	account_id = rand(111111,999999)

	active_departments = account_job.bank_account_department
	for(var/D in payment_per_department)
		payment_per_department[D] = payment_per_department[D]

/datum/bank_account/Destroy()
	if(add_to_accounts)
		SSeconomy.bank_accounts -= src
	return ..()

/datum/bank_account/proc/dumpeet()
	being_dumped = TRUE
	withdrawDelay = world.time + DUMPTIME

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
		from.adjust_money(-amount)
		return TRUE
	return FALSE

/datum/bank_account/proc/payday(amt_of_paychecks, free = FALSE)
	var/bank_card_talk_sound = TRUE
	if(suspended)
		bank_card_talk("ERROR: Payday aborted, the account is closed by Nanotrasen Space Finance.", sound=bank_card_talk_sound--)
		return
	if(welfare)
		adjust_money(PAYCHECK_WELFARE) // Don't let welfare siphon your station budget
		bank_card_talk("Nanotrasen welfare system processed, account now holds $[account_balance], supported with [PAYCHECK_WELFARE] credits.", sound=bank_card_talk_sound--)

	for(var/D in payment_per_department)
		var/paycheck_success = FALSE
		if(payment_per_department[D] > 0 || bonus_per_department[D] > 0)
			var/money_to_transfer = payment_per_department[D] * amt_of_paychecks
			if((money_to_transfer + bonus_per_department[D]) < 0) //Check if the bonus is docking more pay than possible
				bonus_per_department[D] -= money_to_transfer //Remove the debt with the payday
				money_to_transfer = 0 //No money for you
			else
				money_to_transfer += bonus_per_department[D]
			if(free)
				adjust_money(money_to_transfer)
				if(bonus_per_department[D] > 0) //Get rid of bonus if we have one
					bonus_per_department[D] = 0
			else
				var/datum/bank_account/B = SSeconomy.get_dep_account(D)
				if(B)
					if(!transfer_money(B, money_to_transfer))
						bank_card_talk("ERROR: Payday aborted, [D] departmental funds insufficient.", sound=bank_card_talk_sound--)
						continue
					else
						bank_card_talk("Payday processed, account now holds $[account_balance], paid with [money_to_transfer] credits from [D] budget.", sound=bank_card_talk_sound--)
						total_paid_payment[D] += money_to_transfer
						//The bonus only resets once it goes through.
						if(bonus_per_department[D] > 0) //And we're not getting rid of debt
							bonus_per_department[D] = 0
						paycheck_success = TRUE
			if(!paycheck_success)
				bank_card_talk("ERROR: Payday aborted, unable to contact [D] departmental account.", sound=bank_card_talk_sound--)

/datum/bank_account/proc/bank_card_talk(message, force, sound=TRUE)
	if(!message || !bank_cards.len)
		return
	for(var/obj/A in bank_cards)
		var/mob/card_holder = recursive_loc_check(A, /mob)
		if(ismob(card_holder)) //If on a mob
			if(card_holder.client && !(card_holder.client.prefs.chat_toggles & CHAT_BANKCARD) && !force)
				return

			if(sound)
				card_holder.playsound_local(get_turf(card_holder), 'sound/machines/twobeep_high.ogg', 50, TRUE)
			if(card_holder.can_hear())
				to_chat(card_holder, "[icon2html(A, card_holder)] *[message]*")
		else if(isturf(A.loc)) //If on the ground
			for(var/mob/M as() in hearers(1,get_turf(A)))
				if(M.client && !(M.clie
				nt.prefs.chat_toggles & CHAT_BANKCARD) && !force)
					return
				if(sound)
					playsound(A, 'sound/machines/twobeep_high.ogg', 50, TRUE)
				A.audible_message("[icon2html(A, hearers(A))] *[message]*", null, 1)
				break
		else
			for(var/mob/M in A.loc) //If inside a container with other mobs (e.g. locker)
				if(M.client && !(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force)
					return
				if(sound)
					M.playsound_local(get_turf(M), 'sound/machines/twobeep_high.ogg', 50, TRUE)
				if(M.can_hear())
					to_chat(M, "[icon2html(A, M)] *[message]*")

/datum/bank_account/department
	account_holder = "Guild Credit Agency"
	var/department_id = "REPLACE_ME"
	var/budget_department_flag = "REPLACE_ME2"
	add_to_accounts = FALSE

/datum/bank_account/department/New(dep_id, dep_flag, budget)
	department_id = dep_id
	budget_department_flag = dep_flag
	account_balance = budget
	var/list/total_department_list = SSeconomy.department_accounts+SSeconomy.nonstation_accounts

	account_holder = total_department_list[dep_id]

	SSeconomy.generated_accounts += src

/datum/bank_account/proc/is_nonstation_account() // returns TRUE if the budget account is not Station department. i.e.) medical budget, security budget: FALSE / `nonstation_accounts` like VIP one: TRUE
	for(var/each in SSeconomy.nonstation_accounts)
		if(account_holder == SSeconomy.nonstation_accounts[each])
			return TRUE
	return FALSE

#undef DUMPTIME
