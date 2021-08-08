SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	init_order = INIT_ORDER_ECONOMY
	runlevels = RUNLEVEL_GAME
	var/roundstart_paychecks = 5
	var/budget_pool = 35000
	var/list/department_accounts = list(ACCOUNT_CIV = ACCOUNT_CIV_NAME,
										ACCOUNT_ENG = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI = ACCOUNT_SCI_NAME,
										ACCOUNT_MED = ACCOUNT_MED_NAME,
										ACCOUNT_SRV = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR = ACCOUNT_CAR_NAME,
										ACCOUNT_SEC = ACCOUNT_SEC_NAME)
	var/list/generated_accounts = list()
	var/full_ancap = FALSE // Enables extra money charges for things that normally would be free, such as sleepers/cryo/cloning.
							//Take care when enabling, as players will NOT respond well if the economy is set up for low cash flows.
	var/list/bank_accounts = list() //List of normal accounts (not department accounts)
	var/list/dep_cards = list()
	///The modifier multiplied to the value of bounties paid out.
	var/bounty_modifier = 1

/datum/controller/subsystem/economy/Initialize(timeofday)
	var/budget_to_hand_out = round(budget_pool / department_accounts.len)
	for(var/A in department_accounts)
		new /datum/bank_account/department(A, budget_to_hand_out)
	return ..()

/datum/controller/subsystem/economy/fire(resumed = 0)
	boring_eng_payout()
	boring_sci_payout()
	boring_sec_payout()
	boring_med_payout()
	boring_srv_payout()
	boring_civ_payout()
	for(var/A in bank_accounts)
		var/datum/bank_account/B = A
		B.payday(1)


/datum/controller/subsystem/economy/proc/get_dep_account(dep_id)
	for(var/datum/bank_account/department/D in generated_accounts)
		if(D.department_id == dep_id)
			return D

/datum/controller/subsystem/economy/proc/boring_eng_payout()
	var/engineering_cash = 2000
	var/datum/bank_account/D = get_dep_account(ACCOUNT_ENG)
	if(D)
		D.adjust_money(engineering_cash)

/datum/controller/subsystem/economy/proc/boring_sec_payout()
	var/security_cash = 2000
	var/datum/bank_account/D = get_dep_account(ACCOUNT_SEC)
	if(D)
		D.adjust_money(security_cash)

/datum/controller/subsystem/economy/proc/boring_med_payout()
	var/medical_cash = 2000
	var/datum/bank_account/D = get_dep_account(ACCOUNT_MED)
	if(D)
		D.adjust_money(medical_cash)

/datum/controller/subsystem/economy/proc/boring_srv_payout()
	var/service_cash = 1000
	var/datum/bank_account/D = get_dep_account(ACCOUNT_SRV)
	if(D)
		D.adjust_money(service_cash)

/datum/controller/subsystem/economy/proc/boring_sci_payout()
	var/science_cash = 2500
	var/datum/bank_account/D = get_dep_account(ACCOUNT_SCI)
	if(D)
		D.adjust_money(science_cash)

/datum/controller/subsystem/economy/proc/boring_civ_payout()
	var/civilian_cash = 1000
	var/datum/bank_account/D = get_dep_account(ACCOUNT_CIV)
	if(D)
		D.adjust_money(civilian_cash)
