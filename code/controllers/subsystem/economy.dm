SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	runlevels = RUNLEVEL_GAME
	dependencies = list(
		/datum/controller/subsystem/job,
		/datum/controller/subsystem/processing/station,
	)

	var/roundstart_paychecks = 5
	/// Budget pool afforded to the station. It will be divided between all budgets. MIND!! THIS INCUDED VIP, WELFARE AND MINING GOLEM!!!
	var/budget_pool = 50000
	var/full_ancap = FALSE // Enables extra money charges for things that normally would be free, such as sleepers/cryo/cloning.
							//Take care when enabling, as players will NOT respond well if the economy is set up for low cash flows.
	/// List of normal accounts (not department accounts)
	var/list/bank_accounts = list()
	/// List of budget accounts (including nonstation accounts)
	var/list/budget_accounts = list()
	///
	var/list/dep_cards = list()
	///The modifier multiplied to the value of bounties paid out.
	///Multiplied as they go to all department accounts rather than just cargo.
	var/bounty_modifier = 9

	/// Number of mail items generated.
	var/mail_waiting
	/// Mail Holiday: AKA does mail arrive today? Always blocked on Sundays, but not on bee, the mail is 24/7.
	var/mail_blocked = FALSE

/datum/controller/subsystem/economy/Initialize()
	var/budget_size = 0
	var/remaining_budget_pool = budget_pool

	// First pass: subtract fixed starting budgets
	for(var/datum/bank_account/department/each as() in subtypesof(/datum/bank_account/department))
		if(initial(each.starting_budget))
			remaining_budget_pool -= initial(each.starting_budget)

	// Second pass: count departments that should receive a share
	for(var/datum/bank_account/department/each as() in subtypesof(/datum/bank_account/department))
		if(!initial(each.nonstation_account))
			if(!initial(each.starting_budget)) // only count those without a fixed starting budget
				budget_size++

	var/budget_to_hand_out = (budget_size > 0) ? round(remaining_budget_pool / budget_size) : 0

	// Create department accounts
	for(var/datum/bank_account/department/dep as() in subtypesof(/datum/bank_account/department))
		var/datum/bank_account/department/D
		if(initial(dep.starting_budget))
			D = new dep(initial(dep.starting_budget))
		else
			D = new dep(budget_to_hand_out)

		budget_accounts += D

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		var/datum/bank_account/department/D = get_budget_account(ACCOUNT_CAR_ID)
		D.account_balance = budget_pool
		D.account_holder = ACCOUNT_ALL_NAME

	return SS_INIT_SUCCESS

/datum/controller/subsystem/economy/Recover()
	budget_accounts = SSeconomy.budget_accounts
	dep_cards = SSeconomy.dep_cards

/datum/controller/subsystem/economy/fire(resumed = 0)
	for(var/A in bank_accounts)
		var/datum/bank_account/B = A
		B.payday(1)
	var/effective_mailcount = living_player_count()
	mail_waiting = clamp(mail_waiting + clamp(effective_mailcount, 1, MAX_MAIL_PER_MINUTE * (wait / (1 MINUTES))), 0, MAX_MAIL_LIMIT)

/datum/controller/subsystem/economy/proc/get_bank_account_by_id(target_id)
	if(!length(bank_accounts))
		return FALSE
	if(istype(target_id, /datum/bank_account))
		stack_trace("proc took account type itself, but it is supposed to take account id number.")
		return target_id
	target_id = text2num(target_id) // failsafe to replace the string into number
	for(var/datum/bank_account/target_account in bank_accounts)
		if(target_account.account_id == target_id)
			return target_account
	return null

/// Returns a budget account type, but it will return the united budget account(cargo one) if united budget is active
/datum/controller/subsystem/economy/proc/get_budget_account(dept_id, force=FALSE)
	var/static/datum/bank_account/department/united_budget
	if(!united_budget)
		for(var/datum/bank_account/department/D in budget_accounts)
			if(D.department_id == ACCOUNT_CAR_ID)
				united_budget = D
				break

	var/static/list/budget_id_list = list()
	if(!length(budget_id_list))
		for(var/datum/bank_account/department/D in budget_accounts)
			budget_id_list += list("[D.department_id]" = D)

	var/datum/bank_account/department/target_budget = budget_id_list[dept_id]

	if(!target_budget)
		stack_trace("failed to get a budget account with the given parameter: [dept_id]")
		return budget_id_list[ACCOUNT_CAR_ID] // this will prevent the game being broken

	if(force || target_budget.is_nonstation_account())  // Warning: do not replace this into `is_nonstation_account(target_budget)` or it will loop. We have 2 types of the procs that have the same name for conveniet purpose.
		return target_budget // 'force' is used to grab a correct budget regardless of united budget.
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		return united_budget
	else
		return target_budget

/// Returns a budget account's bitflag
/datum/controller/subsystem/economy/proc/get_budget_acc_bitflag(dept_id)
	for(var/datum/bank_account/department/each in budget_accounts)
		if(each.department_id == dept_id)
			return each.department_bitflag
	CRASH("the proc has taken wrong dept id or admin did something worse: [dept_id]")

/// Returns multiple budget accounts based on the given bitflag.
/datum/controller/subsystem/economy/proc/get_dept_id_by_bitflag(target_bitflag)
	if(!target_bitflag) // 0 is not valid bitflag
		return FALSE
	target_bitflag = text2num(target_bitflag) // failsafe to replace the string into number
	if(!isnum(target_bitflag))
		CRASH("the proc has taken non-numeral parameter: [target_bitflag]")

	. = list()
	for(var/datum/bank_account/department/D in budget_accounts)
		if(D.department_bitflag & target_bitflag)
			. += D

	if(!length(.))
		CRASH("none of budget accounts has the bitflag: [target_bitflag]")

/// returns if a budget is not bound to the station. a parameter can accept two types: department account object, or budget DEFINE. The proc can accept both.
/datum/controller/subsystem/economy/proc/is_nonstation_account(datum/bank_account/department/D) // takes a bank account type or dep_ID define
	if(!D) // null check first
		return FALSE
	if(!istype(D, /datum/bank_account/department)) // if parameter was given as a dept id, replace it into better type
		D = SSeconomy.get_budget_account(D) // tricky
	if(!istype(D, /datum/bank_account/department)) // if it failed to replacing, return false.
		return FALSE
	return D.nonstation_account
	// this proc is useful when you don't want to declare a variable

/// Check `subsystem\economy.dm`
/datum/bank_account/department/proc/is_nonstation_account() // It's better to read than if(D.nonstation_account)
	return nonstation_account

/// Returns the total amount of shares into which distributed funds are split
/datum/controller/subsystem/economy/proc/distribution_sum()
	var/distribution_sum = 0
	for(var/datum/bank_account/department/D in budget_accounts)
		distribution_sum += D.budget_ratio
	return distribution_sum

/// Distributes funds to every budget according to its budget ratio
/datum/controller/subsystem/economy/proc/distribute_funds(amount)
	var/single_part = round(amount / distribution_sum())
	for(var/datum/bank_account/department/D in budget_accounts)
		D.adjust_money(single_part * D.budget_ratio)
		if(D.nonstation_account)
			D.adjust_money(amount) // Who'd think Nanotrasen gets a lot of profit from your station

