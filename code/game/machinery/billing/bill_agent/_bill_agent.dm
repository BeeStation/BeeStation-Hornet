/*
	Component that sits on machines, items, or mobs that generate bills on behalf of the parent
*/
/datum/component/bill_agent
	/// Should be moreso the type of the agent
	var/name = "Simple Agent"
	/// Desc if we have one - leave blank for most cases
	var/desc
	/// Who profits from this agen
	var/department_ID
	/// What server this agent is linked to
	var/obj/machinery/billing_server/server
	/// List of bills this agent has generated
	var/list/local_bills = list()
	/// What tags we add on
	var/tags
	/// Have we been manually disabled
	var/disabled = FALSE
	/// How much mula we've made
	var/income = 0
	/// Outstanding bracket for shutoff
	var/upper_outstanding

/datum/component/bill_agent/Initialize(_department_ID, auto_link = TRUE, _tags) // TODO: Should non roundstart stuff auto link to the server - Racc
	. = ..()
	department_ID = _department_ID
	tags |= _tags
	if(!auto_link)
		return
	// Grab billing server
	if(SSbilling?.roundstart_server)
		server = SSbilling?.roundstart_server
		server.add_agent(src)
	else
		RegisterSignal(SSbilling, COMSIG_BILLING_DEFAULT_SERVER_FOUND, PROC_REF(catch_new_server))

/datum/component/bill_agent/proc/get_outstanding_bills()
	var/outstanding = 0
	for(var/datum/bill/bill as anything in local_bills)
		if(!bill.paid)
			outstanding += 1
	return outstanding

/// True is forgiven, false is condemed
/datum/component/bill_agent/proc/check_forgiveness()
	return !(get_outstanding_bills() > upper_outstanding) // Add any extra forgiveness logic here

/datum/component/bill_agent/proc/catch_new_server(datum/source, obj/machinery/billing_server/_server)
	SIGNAL_HANDLER

	server = _server
	server.add_agent(src)
	UnregisterSignal(SSbilling, COMSIG_BILLING_DEFAULT_SERVER_FOUND)

/// Stores your custom bill datums
/datum/component/bill_agent/proc/add_bill(datum/bill/new_bill)
	if(disabled)
		qdel(new_bill) // TODO: Not a great way of doing this - Racc
		return
	RegisterSignal(new_bill, COMSIG_QDELETING, PROC_REF(catch_bill))
	if(!new_bill.paid)
		RegisterSignal(new_bill, COMSIG_BILLING_BILL_PAID, PROC_REF(catch_paid))
	else
		income += new_bill.amount
	local_bills += new_bill
	return new_bill

/datum/component/bill_agent/proc/catch_paid(datum/source, amount)
	SIGNAL_HANDLER

	income += amount

/datum/component/bill_agent/proc/catch_bill(datum/source)
	SIGNAL_HANDLER

	local_bills -= source

/datum/component/bill_agent/proc/toggle_disabled(state)
	disabled = state
