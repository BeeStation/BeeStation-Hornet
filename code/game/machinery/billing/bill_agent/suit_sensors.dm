/datum/component/bill_agent/scheduled/suit_sensors
	name = "Suit Sensors Agent"
	tags = BILL_TAG_FEE
	bill_time = BILLING_PERIOD_SUIT_SENSORS
	setting_path = /datum/billing_setting/number/suit_sensor_upkeep
	upper_outstanding = BILLING_MAX_OUTSTANDING_SENSORS

/datum/component/bill_agent/scheduled/suit_sensors/New(list/raw_args)
	. = ..()
	toggle_disabled(TRUE) // We start disabled, we get enabled by being worn

/datum/component/bill_agent/scheduled/suit_sensors/toggle_disabled(state)
	. = ..()
	if(.)
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)

/datum/component/bill_agent/scheduled/suit_sensors/make_scheduled()
	var/obj/item/clothing/under/suit = parent
	// Flight checks
	if(!istype(suit))
		return
	var/mob/living/wearer = suit.loc
	if(!istype(wearer))
		return
	if(!check_forgiveness())
		return
	// Find out who the wearer works for
	var/obj/item/card/id/id_card = wearer.get_idcard(FALSE)
	var/datum/bank_account/account = id_card?.registered_account
	var/datum/job/job = account?.account_job
	// Build bills
	if(!length(job?.payment_per_department))
		return
	for(var/department in job.payment_per_department) // TODO: This is going to act weird with multiple departments - Racc
		if(department == department_ID)
			continue
		var/datum/bill/timed_bill = server?.create_new_bill(department, department_ID, amount, FALSE, FALSE, tags)
		timed_bill.title = "Suit Sensors"
		timed_bill.body = "For the continued use of [department_ID]'s suit sensor program on [parent]."
		add_bill(timed_bill)
		// Lock out
		if(!check_forgiveness())
			suit.say("Outstanding invoices, disabling sensors...")
			suit.set_sensor_mode(SENSOR_OFF)
			// If we can't be paid, watch the bill so we can turn back on later
			RegisterSignal(timed_bill, COMSIG_BILLING_BILL_PAID, PROC_REF(catch_paid_last))
			return

/datum/component/bill_agent/scheduled/suit_sensors/catch_bill(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_BILLING_BILL_PAID)

/datum/component/bill_agent/scheduled/suit_sensors/proc/catch_paid_last(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_BILLING_BILL_PAID)
	var/obj/item/clothing/under/suit = parent
	if(!istype(suit))
		return
	suit.say("Invoices paid, enabling sensors...")
	suit.set_sensor_mode(SENSOR_COORDS) // TODO: make this restore the settings, instead of setting to max - Racc
