// For APCs
/datum/component/bill_agent/generic/number_coef/power
	name = "APC Agent"
	setting_path = /datum/billing_setting/number/power
	upper_outstanding = BILLING_MAX_OUTSTANDING_APC

/datum/component/bill_agent/generic/number_coef/power/get_outstanding_bills()
	. = ..()
	var/area/A = get_area(parent)
	. -= A?.extra_overdraft

// For techfab designs
/datum/component/bill_agent/generic/number_coef/techfab_design
	name = "Design Agent"
	setting_path = /datum/billing_setting/number/techfab_design
	signal_type = COMSIG_BILLING_BILL_AGENT_DESIGN
	upper_outstanding = BILLING_MAX_OUTSTANDING_FAB

// For techfab materials
/datum/component/bill_agent/generic/number_coef/techfab_material
	name = "Material Agent"
	setting_path = /datum/billing_setting/number/techfab_material
	signal_type = COMSIG_BILLING_BILL_AGENT_MATERIAL
	upper_outstanding = BILLING_MAX_OUTSTANDING_FAB
