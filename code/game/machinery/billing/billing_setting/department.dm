// Engineering power bill modifier
/datum/billing_setting/number/power
	name = "Power Billing Coefficient"
	number = BILLING_COST_ELECTRICITY
	upper = 0.001
	lower = 0.0001
	step = 0.000001
	department_ID = list(ACCOUNT_COM_ID, ACCOUNT_ENG_ID)
	var/demo_number = 100000

/datum/billing_setting/number/power/New()
	. = ..()
	update_desc()

/datum/billing_setting/number/power/set_number(_number)
	. = ..()
	update_desc()

//TODO: make this shared if you cleanup the code - Racc
/datum/billing_setting/number/power/proc/update_desc()
	desc = "[display_power(demo_number)] is worth [demo_number*number]cr."

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
	department_ID = list(ACCOUNT_COM_ID, ACCOUNT_MED_ID)

/datum/billing_setting/number/upkeep/security
	name = "Secuirty Upkeep"
	department_ID = list(ACCOUNT_COM_ID, ACCOUNT_SEC_ID)

/datum/billing_setting/number/upkeep/service
	name = "Service Upkeep"
	department_ID = list(ACCOUNT_COM_ID, ACCOUNT_SRV_ID)

/*
	Techfab coefs
*/
// Techfab designs, for science
/datum/billing_setting/number/techfab_design
	name = "Techfab Design Cost Coefficient"
	number = BILLING_COST_FAB_DESIGN
	upper = 100
	lower = 1
	step = 0.1
	department_ID = list(ACCOUNT_COM_ID, ACCOUNT_SCI_ID)

// Techfab materials, for cargo
/datum/billing_setting/number/techfab_material
	name = "Techfab Material Cost Coefficient"
	number = BILLING_COST_FAB_MATERIAL
	upper = 0.1
	lower = 0.005
	step = 0.0001
	department_ID = list(ACCOUNT_COM_ID, ACCOUNT_CAR_ID)
	var/demo_number = 100000

/datum/billing_setting/number/techfab_material/New()
	. = ..()
	update_desc()

/datum/billing_setting/number/techfab_material/set_number(_number)
	. = ..()
	update_desc()

/datum/billing_setting/number/techfab_material/proc/update_desc()
	desc = "[demo_number] materials is worth [demo_number*number]cr."

/*
	Suit sensors
*/
// Suit sensor upkeep
/datum/billing_setting/number/suit_sensor_upkeep
	name = "Suit Sensor Upkeep"
	number = 5
	upper = 50
	lower = 1
	step = 0.1
	department_ID = list(ACCOUNT_COM_ID, ACCOUNT_MED_ID)

/datum/billing_setting/number/suit_sensor_upkeep/New()
	. = ..()
	update_desc()

/datum/billing_setting/number/suit_sensor_upkeep/set_number(_number)
	. = ..()
	update_desc()

/datum/billing_setting/number/suit_sensor_upkeep/proc/update_desc()
	desc = "Suit sensors cost [number*3]cr every quarter hour." // TODO: This is dependant on knowing the suit sensor interval, bad coder - Racc
