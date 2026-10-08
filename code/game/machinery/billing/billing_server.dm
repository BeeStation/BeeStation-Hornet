/obj/machinery/billing_server
	name = "billing server"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	/// List of server's connected to us
	var/list/linked_terminals = list()
	/// List of ongoing bills
	var/list/bills = list()

/obj/machinery/billing_server/Initialize(mapload)
	. = ..()
	SSbilling.set_default_server(src)

/obj/machinery/billing_server/proc/link_terminal(obj/console)
	linked_terminals += console

/// Return a list of our linked terminals that have inserted budget cards
/obj/machinery/billing_server/proc/get_valid_terminals()
	var/list/working_terminals = list()
	for(var/obj/machinery/computer/billing/terminal as anything in linked_terminals)
		if(terminal.budget_card)
			working_terminals += terminal
	return working_terminals

/// Create a new bill
/obj/machinery/billing_server/proc/create_new_bill(to_whom, from, amount, draft, can_delete = TRUE)
	var/datum/bill/new_bill = new /datum/bill("", "", from, to_whom, amount, draft, can_delete)
	bills += new_bill
	if(!new_bill.draft)
		SEND_SIGNAL(src, COMSIG_BILLING_NEW_BILL, new_bill)
	else
		RegisterSignal(new_bill, COMSIG_BILLING_BILL_UNDRAFT, PROC_REF(catch_undraft))

	return new_bill

/obj/machinery/billing_server/proc/catch_undraft(datum/source)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_BILLING_NEW_BILL, source)

/// Get a list of bills filtered by a specific department id
/obj/machinery/billing_server/proc/get_bills(to_department_id, from_department_id, drafts = FALSE, paid = FALSE)
	var/list/filtered_bills = list()
	for(var/datum/bill/bill as anything in bills)
		if(bill.draft != drafts)
			continue
		if(bill.paid != paid)
			continue
		if(bill.to_whom == to_department_id || bill.from == from_department_id)
			filtered_bills += bill
	return filtered_bills
