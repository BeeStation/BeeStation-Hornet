// Engineering power bill modifier
/datum/billing_setting/number/power
	name = "Power Billing Coefficient"
	number = BILLING_COST_ELECTRICITY
	upper = 0.0009
	lower = 0.0001
	step = 0.0001
	department_ID = list(ACCOUNT_COM_ID, ACCOUNT_ENG_ID)

/*
	Generic upkeep
*/
/datum/billing_setting/number/upkeep
	name = "Generic Upkeep"
	number = BILLING_UPKEEP_GENERIC
	upper = 1000
	lower = 100
	step = 1

/datum/billing_setting/number/upkeep/medical
	name = "Medical Upkeep"
	department_ID = list(ACCOUNT_MED_ID)

/datum/billing_setting/number/upkeep/security
	name = "Secuirty Upkeep"
	department_ID = list(ACCOUNT_SEC_ID)

/datum/billing_setting/number/upkeep/service
	name = "Service Upkeep"
	department_ID = list(ACCOUNT_SRV_ID)
