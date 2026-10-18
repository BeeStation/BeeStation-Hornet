/datum/component/bill_agent/scheduled/vendor_rent
	name = "Vending Machine Rent Agent"
	tags = BILL_TAG_FEE
	bill_time = BILLING_PERIOD_VENDING_RENT
	setting_path = /datum/billing_setting/number/vending_rental
	upper_outstanding = BILLING_MAX_OUTSTANDING_VENDING_RENT

/datum/component/bill_agent/scheduled/vendor_rent/make_scheduled()
	var/obj/machinery/vending/vendor = parent
	// Flight checks
	if(!istype(vendor))
		return
	if(!check_forgiveness())
		return
	// WHO DO YOU WORK FOR?!!
	var/area/A = get_area(parent)
	var/victim = A?.power_bill_department_ID
	if(!victim || victim == department_ID)
		return
	// Build invoice
	var/datum/bill/timed_bill = server?.create_new_bill(victim, department_ID, amount, FALSE, FALSE, tags)
	timed_bill.title = "Vending Rental"
	timed_bill.body = "For the rented use of [parent]."
	add_bill(timed_bill)
	// Lock out
	if(!check_forgiveness())
		vendor.say("Outstanding invoices, disabling...")
		return
