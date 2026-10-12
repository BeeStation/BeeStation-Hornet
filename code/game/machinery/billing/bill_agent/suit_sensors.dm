/datum/component/bill_agent/scheduled/suit_sensors
	name = "Suit Sensors Agent"
	tags = BILL_TAG_FEE
	bill_time = 5 MINUTES
	setting_path = /datum/billing_setting/number/suit_sensor_upkeep

// TODO: This is a little expensive to have every suit processing, make it only tick when worn - Racc

/datum/component/bill_agent/scheduled/suit_sensors/make_scheduled()
	var/obj/item/clothing/under/suit = parent
	// Flight checks
	if(!istype(suit))
		return
	var/mob/living/wearer = suit.loc
	if(!istype(wearer))
		return
	if(length(local_bills) > BILLING_MAX_OUTSTANDING_SENSORS)
		return
	// Find out who the wearer works for
	var/obj/item/card/id/id_card = wearer.get_idcard(FALSE)
	var/datum/bank_account/account = id_card?.registered_account
	var/datum/job/job = account?.account_job
	// Build bills
	if(!length(job?.payment_per_department))
		return
	for(var/department in job.payment_per_department)
		if(department == department_ID)
			continue
		var/datum/bill/timed_bill = server?.create_new_bill(department, department_ID, amount, FALSE, FALSE, tags)
		timed_bill.title = "Suit Sensors"
		timed_bill.body = "For the continued use of [department_ID]'s suit sensor program on [parent]."
		add_bill(timed_bill)
	// Lock out
	if(length(local_bills) > BILLING_MAX_OUTSTANDING_SENSORS)
		suit.say("Outstanding invoices, disabling sensors...")
		suit.set_sensor_mode(SENSOR_OFF)
		return

