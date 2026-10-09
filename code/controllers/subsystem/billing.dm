SUBSYSTEM_DEF(billing)
	name = "Billing"
	ss_flags = SS_BACKGROUND | SS_NO_INIT

	/// Roundtsart billing console
	var/obj/machinery/billing_server/roundstart_server
	/// Accounts available for billing in the terminal
	var/list/billables = list(ACCOUNT_CIV_ID, ACCOUNT_SRV_ID, ACCOUNT_CAR_ID, ACCOUNT_SCI_ID, ACCOUNT_ENG_ID, ACCOUNT_MED_ID, ACCOUNT_SEC_ID, ACCOUNT_COM_ID)
	/// tags available
	var/list/bill_tags = list("Power" = BILL_TAG_POWER, "Custom" = BILL_TAG_CUSTOM, "Utility" = BILL_TAG_UPKEEP, "Fee" = BILL_TAG_FEE)

//TODO: This is a temporary / prototype solution to auto billing - Racc
	///What world time do we bill at?
	COOLDOWN_DECLARE(auto_pay)

/datum/controller/subsystem/billing/fire()
	// Temp ew
	if(COOLDOWN_FINISHED(src, auto_pay) && roundstart_server)
		COOLDOWN_START(src, auto_pay, BILLING_PERIOD_UPKEEP)
		for(var/department_ID in list(ACCOUNT_CIV_ID, ACCOUNT_SRV_ID, ACCOUNT_CAR_ID, ACCOUNT_SCI_ID, ACCOUNT_ENG_ID, ACCOUNT_MED_ID, ACCOUNT_SEC_ID))
			if(department_ID != ACCOUNT_SEC_ID)
				// Secuirty
				var/datum/bill/security_bill = roundstart_server?.create_new_bill(department_ID, ACCOUNT_SEC_ID, BILLING_UPKEEP_GENERIC, FALSE, FALSE, BILL_TAG_UPKEEP)
				security_bill.title = "Security Services Invoice"
				security_bill.body = "For the continued services of Security."
			if(department_ID != ACCOUNT_MED_ID)
				// Medical
				var/datum/bill/medical_bill = roundstart_server?.create_new_bill(department_ID, ACCOUNT_MED_ID, BILLING_UPKEEP_GENERIC, FALSE, FALSE, BILL_TAG_UPKEEP)
				medical_bill.title = "Medical Services Invoice"
				medical_bill.body = "For the continued services of Medical."
			if(department_ID != ACCOUNT_SRV_ID)
				// Service
				var/datum/bill/service_bill = roundstart_server?.create_new_bill(department_ID, ACCOUNT_SRV_ID, BILLING_UPKEEP_GENERIC, FALSE, FALSE, BILL_TAG_UPKEEP)
				service_bill.title = "Service Services Invoice"
				service_bill.body = "For the continued services of Service."

/datum/controller/subsystem/billing/proc/set_default_server(obj/machinery/billing_server/_server)
	if(roundstart_server)
		return
	roundstart_server = _server
	SEND_SIGNAL(src, COMSIG_BILLING_DEFAULT_SERVER_FOUND, roundstart_server)
