// For generic charges
/datum/component/bill_agent/generic
	/// What signal we listen to
	var/signal_type = COMSIG_BILLING_BILL_AGENT_GENERIC

/datum/component/bill_agent/generic/Initialize(auto_link)
	. = ..()
	RegisterSignal(parent, signal_type, PROC_REF(catch_generic))

/datum/component/bill_agent/generic/proc/catch_generic(datum/source, to_whom, amount, title, body, from_override)
	SIGNAL_HANDLER

	if(!server || disabled || to_whom == department_ID)
		return
	var/datum/bill/generic_bill = server.create_new_bill(to_whom, from_override || department_ID, amount, TRUE, FALSE, tags)
	generic_bill.title = title
	generic_bill.body = body
	add_bill(generic_bill)

// variant for agents that use a setting as a coefficient
/datum/component/bill_agent/generic/number_coef
	/// Amount coef setting - only works with number settings by default
	var/setting_path

/datum/component/bill_agent/generic/number_coef/add_bill(datum/bill/new_bill)
	. = ..()
	if(!.)
		return
	var/datum/bill/generic_bill = .
	var/datum/billing_setting/number/coef_setting = locate(setting_path) in server.settings
	if(!coef_setting || !generic_bill)
		return
	// Use the setting on the server to calculate the actual bill
	generic_bill.body = "[generic_bill.body] (amount([generic_bill.amount]) x [coef_setting.name] coefficient([coef_setting.number]))"
	generic_bill.amount = coef_setting.number*generic_bill.amount
	if(generic_bill.draft)
		generic_bill.undraft()
