#define VIP_BUDGET_BASE rand(8888888, 11111111)
#define BUDGET_RATIO_TYPE_A 1
#define BUDGET_RATIO_TYPE_B 2

SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	init_order = INIT_ORDER_ECONOMY
	runlevels = RUNLEVEL_GAME
	var/roundstart_paychecks = 5
	var/budget_pool = 25200 // "25000 / 7 = 3571" is ugly.
	var/list/department_accounts = list(ACCOUNT_CIV_ID = ACCOUNT_CIV_NAME,
										ACCOUNT_SRV_ID = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR_ID = ACCOUNT_CAR_NAME,
										ACCOUNT_ENG_ID = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI_ID = ACCOUNT_SCI_NAME,
										ACCOUNT_MED_ID = ACCOUNT_MED_NAME,
										ACCOUNT_SEC_ID = ACCOUNT_SEC_NAME)
	var/list/nonstation_accounts = list(ACCOUNT_VIP_ID = ACCOUNT_VIP_NAME)
	var/list/account_bitflags = list(ACCOUNT_COM_ID = ACCOUNT_COM_BITFLAG,
									 ACCOUNT_CIV_ID = ACCOUNT_CIV_BITFLAG,
									 ACCOUNT_SRV_ID = ACCOUNT_SRV_BITFLAG,
									 ACCOUNT_CAR_ID = ACCOUNT_CAR_BITFLAG,
									 ACCOUNT_ENG_ID = ACCOUNT_ENG_BITFLAG,
									 ACCOUNT_SCI_ID = ACCOUNT_SCI_BITFLAG,
									 ACCOUNT_MED_ID = ACCOUNT_MED_BITFLAG,
									 ACCOUNT_SEC_ID = ACCOUNT_SEC_BITFLAG,
									 ACCOUNT_VIP_ID = ACCOUNT_VIP_BITFLAG)
	var/list/generated_accounts = list()
	var/full_ancap = FALSE // Enables extra money charges for things that normally would be free, such as sleepers/cryo/cloning.
							//Take care when enabling, as players will NOT respond well if the economy is set up for low cash flows.
	var/list/bank_accounts = list() //List of normal accounts (not department accounts)
	var/list/dep_cards = list()
	///The modifier multiplied to the value of bounties paid out.
	///Multiplied as they go to all department accounts rather than just cargo.
	var/bounty_modifier = 3

	/// Number of mail items generated.
	var/mail_waiting
	/// Mail Holiday: AKA does mail arrive today? Always blocked on Sundays, but not on bee, the mail is 24/7.
	var/mail_blocked = FALSE


	/// checking `if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))` costs (a little bit) more resource. this is faster.
	var/static/united_budget_trait = FALSE

/datum/controller/subsystem/economy/Initialize(timeofday)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		united_budget_trait = TRUE

	var/budget_to_hand_out = united_budget_trait ? budget_pool : round(budget_pool / department_accounts.len)
	for(var/A in department_accounts)
		new /datum/bank_account/department(A, budget_to_hand_out)

	if(united_budget_trait)
		var/datum/bank_account/department/D = get_dep_account(ACCOUNT_CAR_ID)
		department_accounts[ACCOUNT_CAR_ID] = ACCOUNT_ALL_NAME
		D.account_holder = ACCOUNT_ALL_NAME
		// if you want to remove united_budget feature, try an event

	for(var/A in nonstation_accounts)
		new /datum/bank_account/department(A, VIP_BUDGET_BASE)

	return ..()

/datum/controller/subsystem/economy/Recover()
	generated_accounts = SSeconomy.generated_accounts
	dep_cards = SSeconomy.dep_cards

/datum/controller/subsystem/economy/fire(resumed = 0)
	for(var/A in bank_accounts)
		var/datum/bank_account/B = A
		B.payday(1)
	var/effective_mailcount = living_player_count()
	mail_waiting += clamp(effective_mailcount, 1, MAX_MAIL_PER_MINUTE)

/datum/controller/subsystem/economy/proc/get_bank_account_by_id(target_id)
	for(var/datum/bank_account/target_account in SSeconomy.bank_accounts)
		if(target_account.account_id == target_id)
			return target_account
	return null

/datum/controller/subsystem/economy/proc/get_dep_account(dep_id)
	if(united_budget_trait && !(dep_id in nonstation_accounts)) // using 'is_nonstation()' here is innecessary
		dep_id = ACCOUNT_CAR_ID
	for(var/datum/bank_account/department/D in generated_accounts)
		if(D.department_id == dep_id)
			return D

/datum/controller/subsystem/economy/proc/is_nonstation_account(datum/bank_account/department/D) // takes a bank account type or dep_ID define
	if(!D)
		return FALSE
	for(var/each in SSeconomy.nonstation_accounts)
		if(D.account_holder == SSeconomy.nonstation_accounts[each])
			return TRUE
	return FALSE

/datum/controller/subsystem/economy/proc/distribute_funds(amount)
	var/datum/bank_account/eng = get_dep_account(ACCOUNT_ENG_ID)
	var/datum/bank_account/sec = get_dep_account(ACCOUNT_SEC_ID)
	var/datum/bank_account/med = get_dep_account(ACCOUNT_MED_ID)
	var/datum/bank_account/srv = get_dep_account(ACCOUNT_SRV_ID)
	var/datum/bank_account/sci = get_dep_account(ACCOUNT_SCI_ID)
	var/datum/bank_account/civ = get_dep_account(ACCOUNT_CIV_ID)
	var/datum/bank_account/car = get_dep_account(ACCOUNT_CAR_ID)

	var/departments = 0

	if(eng)
		departments += BUDGET_RATIO_TYPE_B
	if(sec)
		departments += BUDGET_RATIO_TYPE_B
	if(med)
		departments += BUDGET_RATIO_TYPE_B
	if(srv)
		departments += BUDGET_RATIO_TYPE_A
	if(sci)
		departments += BUDGET_RATIO_TYPE_B
	if(civ)
		departments += BUDGET_RATIO_TYPE_A
	if(car)
		departments += BUDGET_RATIO_TYPE_B

	var/parts = round(amount / departments)

	var/engineering_cash = parts * BUDGET_RATIO_TYPE_B
	var/security_cash = parts * BUDGET_RATIO_TYPE_B
	var/medical_cash = parts * BUDGET_RATIO_TYPE_B
	var/service_cash = parts * BUDGET_RATIO_TYPE_A
	var/science_cash = parts * BUDGET_RATIO_TYPE_B
	var/civilian_cash = parts * BUDGET_RATIO_TYPE_A
	var/cargo_cash = parts * BUDGET_RATIO_TYPE_B

	eng?.adjust_money(engineering_cash)
	sec?.adjust_money(security_cash)
	med?.adjust_money(medical_cash)
	srv?.adjust_money(service_cash)
	sci?.adjust_money(science_cash)
	civ?.adjust_money(civilian_cash)
	car?.adjust_money(cargo_cash)

	// VIP budget will not dry
	var/datum/bank_account/vip = get_dep_account(ACCOUNT_VIP_ID)
	vip?.adjust_money(cargo_cash)

#undef VIP_BUDGET_BASE
#undef BUDGET_RATIO_TYPE_A
#undef BUDGET_RATIO_TYPE_B
