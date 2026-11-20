/*
	Scheduled agent
	Makes a bill on cooldown, for repeating scheduled bills
	Can take a number setting for the amount
*/
/datum/component/bill_agent/scheduled
	name = "Scheduled Agent"
	tags = BILL_TAG_UPKEEP
	/// What amount do we bill on cooldown
	var/amount = 1
	/// What server setting do we use for the billing amount - if we do - default only works with number setting
	var/setting_path
	/// Time between billings
	var/bill_time = 10 MINUTES
	COOLDOWN_DECLARE(bill_cooldown)

/datum/component/bill_agent/scheduled/New(list/raw_args)
	. = ..()
	START_PROCESSING(SSobj, src)
	desc = "Runs every [bill_time/60/10] minutes."

/datum/component/bill_agent/scheduled/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSobj, src) // TODO: only start / stop when there's a server linked - Racc

/datum/component/bill_agent/scheduled/process(delta_time)
	if(COOLDOWN_FINISHED(src, bill_cooldown) && server)
		COOLDOWN_START(src, bill_cooldown, bill_time)
		// Double check / update setting stuff
		if(setting_path)
			var/datum/billing_setting/number/setting = locate(setting_path) in server?.settings
			amount = setting?.number || amount
		make_scheduled()

/// Make our scheduled bills
/datum/component/bill_agent/scheduled/proc/make_scheduled()
	// Build bill
	var/datum/bill/timed_bill = server?.create_new_bill(ACCOUNT_COM_ID, department_ID, amount, FALSE, FALSE, tags)
	timed_bill.title = "[department_ID] Services Invoice"
	timed_bill.body = "For the continued services of [department_ID]."
	add_bill(timed_bill)

/*
	Scheduled agent for billing everyone but ourselves
*/

/datum/component/bill_agent/scheduled/bill_all
	name = "Department Upkeep"
	bill_time = BILLING_PERIOD_UPKEEP

/datum/component/bill_agent/scheduled/bill_all/make_scheduled()
	for(var/victim_ID in server?.billables)
		if(victim_ID == department_ID)
			continue
		var/datum/bill/timed_bill = server?.create_new_bill(victim_ID, department_ID, amount, FALSE, FALSE, tags)
		timed_bill.title = "[department_ID] Services Invoice"
		timed_bill.body = "For the continued services of [department_ID]."
		add_bill(timed_bill)
