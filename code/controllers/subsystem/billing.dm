SUBSYSTEM_DEF(billing)
	name = "Billing"
	ss_flags = SS_NO_INIT | SS_NO_FIRE

	/// Roundtsart billing console
	var/obj/machinery/billing_server/roundstart_server
	/// Accounts available for billing in the terminal
	var/list/billables = list(ACCOUNT_CIV_ID, ACCOUNT_SRV_ID, ACCOUNT_CAR_ID, ACCOUNT_SCI_ID, ACCOUNT_ENG_ID, ACCOUNT_MED_ID, ACCOUNT_SEC_ID, ACCOUNT_COM_ID)
	/// tags available
	var/list/bill_tags = list("Power" = BILL_TAG_POWER, "Custom" = BILL_TAG_CUSTOM, "Utility" = BILL_TAG_UPKEEP, "Fee" = BILL_TAG_FEE, "Paid" = BILL_TAG_PAID, "Unpaid" = BILL_TAG_UNPAID)
	/// keep track of how much money each department has made this round
	var/list/profit = list()

/datum/controller/subsystem/billing/proc/set_default_server(obj/machinery/billing_server/_server)
	if(roundstart_server)
		return
	roundstart_server = _server
	SEND_SIGNAL(src, COMSIG_BILLING_DEFAULT_SERVER_FOUND, roundstart_server)

/datum/controller/subsystem/billing/proc/get_most_profitable()
	if(!length(profit))
		return "none"
	var/most = 0
	var/id = ""
	for(var/department_ID in profit)
		if(profit[department_ID] > most) // Does not account for ties :/
			most = profit[department_ID]
			id = department_ID
	return id
