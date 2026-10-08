/*
	Component that sits on machines, items, or mobs that generate bills on behalf of the parent
*/
/datum/component/bill_agent
	/// Who profits from this agen
	var/department_ID
	/// What server this agent is linked to
	var/obj/machinery/billing_server/server
	/// List of bills this agent has generated
	var/list/local_bills = list()

/datum/component/bill_agent/Initialize(_department_ID, auto_link = TRUE) // TODO: Should non roundstart stuff auto link to the server - Racc
	. = ..()
	department_ID = _department_ID
	if(!auto_link)
		return
	// Grab billing server
	if(SSbilling?.roundstart_server)
		server = SSbilling?.roundstart_server
	else
		RegisterSignal(SSbilling, COMSIG_BILLING_DEFAULT_SERVER_FOUND, PROC_REF(catch_new_server))

/datum/component/bill_agent/proc/get_outstanding_bills()
	var/outstanding = 0
	for(var/datum/bill/bill as anything in local_bills)
		if(!bill.paid)
			outstanding += 1
	return outstanding

/datum/component/bill_agent/proc/catch_new_server(datum/source, obj/machinery/billing_server/_server)
	SIGNAL_HANDLER

	server = _server
	UnregisterSignal(SSbilling, COMSIG_BILLING_DEFAULT_SERVER_FOUND)

/// Stores your custom bill datums
/datum/component/bill_agent/proc/add_bill(datum/bill/new_bill)
	RegisterSignal(new_bill, COMSIG_QDELETING, PROC_REF(catch_bill))
	local_bills += new_bill

/datum/component/bill_agent/proc/catch_bill(datum/source)
	SIGNAL_HANDLER

	local_bills -= source
