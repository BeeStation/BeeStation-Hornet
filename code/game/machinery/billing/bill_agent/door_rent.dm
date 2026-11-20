/datum/component/bill_agent/scheduled/door_rent
	name = "Airlock Access Agent"
	tags = BILL_TAG_ACCESS
	bill_time = BILLING_PERIOD_DOOR_RENT
	setting_path = /datum/billing_setting/number/door_rental
	upper_outstanding = BILLING_MAX_OUTSTANDING_DOOR_RENT

/datum/component/bill_agent/scheduled/door_rent/make_scheduled()
	// Flight checks
	if(!check_forgiveness())
		return
	// WHO DO YOU WORK FOR?!!
	var/area/A = parent
	var/victim = A.power_bill_department_ID
	if(!victim || victim == department_ID)
		return
	// Build invoice
	var/datum/bill/timed_bill = server?.create_new_bill(victim, department_ID, amount, FALSE, FALSE, tags)
	timed_bill.title = "Airlock Access License"
	timed_bill.body = "For the licensed use of security's access system in [parent]."
	add_bill(timed_bill)
