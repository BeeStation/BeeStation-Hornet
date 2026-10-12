// For APCs
/datum/component/bill_agent/generic/number_coef/power
	name = "APC Agent"
	setting_path = /datum/billing_setting/number/power

// For techfab designs
/datum/component/bill_agent/generic/number_coef/techfab_design
	name = "Design Agent"
	setting_path = /datum/billing_setting/number/techfab_design
	signal_type = COMSIG_BILLING_BILL_AGENT_DESIGN

// For techfab materials
/datum/component/bill_agent/generic/number_coef/techfab_material
	name = "Material Agent"
	setting_path = /datum/billing_setting/number/techfab_material
	signal_type = COMSIG_BILLING_BILL_AGENT_MATERIAL
