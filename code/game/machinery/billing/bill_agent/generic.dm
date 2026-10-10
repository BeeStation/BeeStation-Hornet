// For generic charges, parent handles cost / setup
/datum/component/bill_agent/generic

/datum/component/bill_agent/generic/Initialize(auto_link)
	. = ..()
	RegisterSignal(parent, COMSIG_BILLING_BILL_AGENT_GENERIC, PROC_REF(catch_generic))

/datum/component/bill_agent/generic/proc/catch_generic(datum/source, to_whom, amount, title, body, from_override)
	SIGNAL_HANDLER

	if(!server)
		return
	var/datum/bill/generic_bill = server.create_new_bill(to_whom, from_override || department_ID, amount, FALSE, FALSE, tags)
	generic_bill.title = title
	generic_bill.body = body
	add_bill(generic_bill)
