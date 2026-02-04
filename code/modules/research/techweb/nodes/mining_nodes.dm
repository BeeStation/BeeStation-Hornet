/datum/techweb_node/basic_mining
	id = TECHWEB_NODE_BASIC_MINING
	tech_tier = 1
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prereq_ids = list(TECHWEB_NODE_ENGINEERING)
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/adv_mining
	id = TECHWEB_NODE_ADV_MINING
	tech_tier = 3
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127"	//dumb mc references
	prereq_ids = list(TECHWEB_NODE_BASIC_MINING, TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_ADV_POWER, TECHWEB_NODE_ADV_PLASMA)
	design_ids = list(
		"borg_upgrade_cutter",
		"drill_diamond",
		"hypermodplus",
		"jackhammer",
		"repeatermod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)
