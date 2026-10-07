SUBSYSTEM_DEF(billing)
	name = "Billing"
	ss_flags = SS_BACKGROUND | SS_NO_INIT

	/// Roundtsart billing console
	var/obj/machinery/billing_server/roundstart_server

//TODO: This is a temporary / prototype solution to auto billing - Racc
	///What world time do we bill at?
	COOLDOWN_DECLARE(auto_pay)

/datum/controller/subsystem/billing/fire()
	// Temp ew
	if(COOLDOWN_FINISHED(src, auto_pay) && roundstart_server)
		COOLDOWN_START(src, auto_pay, 5 MINUTES)
		for(var/department_ID in list(ACCOUNT_CIV_ID, ACCOUNT_SRV_ID, ACCOUNT_CAR_ID, ACCOUNT_SCI_ID, ACCOUNT_ENG_ID, ACCOUNT_MED_ID, ACCOUNT_SEC_ID))
			if(department_ID != ACCOUNT_SEC_ID)
				// Secuirty
				var/datum/bill/security_bill = roundstart_server?.create_new_bill(department_ID, ACCOUNT_SEC_ID, BILLING_UPKEEP_GENERIC, FALSE, FALSE)
				security_bill.title = "Security Services Invoice"
				security_bill.body = "For the continued services of Security."
			if(department_ID != ACCOUNT_MED_ID)
				// Medical
				var/datum/bill/medical_bill = roundstart_server?.create_new_bill(department_ID, ACCOUNT_MED_ID, BILLING_UPKEEP_GENERIC, FALSE, FALSE)
				medical_bill.title = "Medical Services Invoice"
				medical_bill.body = "For the continued services of Medical."
			if(department_ID != ACCOUNT_SRV_ID)
				// Service
				var/datum/bill/service_bill = roundstart_server?.create_new_bill(department_ID, ACCOUNT_SRV_ID, BILLING_UPKEEP_GENERIC, FALSE, FALSE)
				service_bill.title = "Service Services Invoice"
				service_bill.body = "For the continued services of Service."
