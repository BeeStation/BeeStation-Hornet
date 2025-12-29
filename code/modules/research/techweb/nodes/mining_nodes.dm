/datum/techweb_node/basic_mining
	id = "basic_mining"
	tech_tier = 1
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prereq_ids = list("engineering")
	design_ids = list(
		"cargoexpress",
		"cooldownmod",
		"damagemod",
		"drill",
		"exploration_equipment_vendor",
		"hypermod",
		"mining_equipment_vendor",
		"ore_redemption",
		"rangemod",
		"superresonator",
		"triggermod",
		"mecha_kineticgun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_mining
	id = "adv_mining"
	tech_tier = 3
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127"	//dumb mc references
	prereq_ids = list(
		"basic_mining",
		"adv_engi",
		"adv_power",
		"adv_plasma",
	)
	design_ids = list(
		"borg_upgrade_cutter",
		"drill_diamond",
		"hypermodplus",
		"jackhammer",
		"repeatermod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
