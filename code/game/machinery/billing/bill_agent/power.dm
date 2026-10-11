/*
	Special snowflake agent
	Same as the generic agent, but it uses the power setting on the server to get the cost
*/
/datum/component/bill_agent/generic/power
	name = "APC Agent"

/datum/component/bill_agent/generic/power/catch_generic(datum/source)
	. = ..()
	if(!.)
		return
	var/datum/bill/generic_bill = .
	var/datum/billing_setting/number/power/power_setting = locate(/datum/billing_setting/number/power) in server.settings
	if(!power_setting || !generic_bill)
		return
	// Use the power setting on the server to calculate the actual bill
	generic_bill.amount = power_setting.number*generic_bill.amount
