/datum/techweb_node/basic_mining
	tech_tier = 1
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prerequisite_nodes = list(/datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/cargo_express,
		/datum/design/cooldown_mod,
		/datum/design/damage_mod,
		/datum/design/drill,
		/datum/design/board/exploration_equipment_vendor,
		/datum/design/hyperaccelerator,
		/datum/design/board/mining_equipment_vendor,
		/datum/design/board/ore_redemption,
		/datum/design/range_mod,
		/datum/design/superresonator,
		/datum/design/trigger_guard_mod,
		/datum/design/mecha_kineticgun,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/adv_mining
	tech_tier = 3
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127"	//dumb mc references
	prerequisite_nodes = list(/datum/techweb_node/basic_mining, /datum/techweb_node/adv_engi, /datum/techweb_node/adv_power, /datum/techweb_node/adv_plasma)
	unlocked_designs = list(
		/datum/design/borg_upgrade_cutter,
		/datum/design/drill_diamond,
		/datum/design/hyperacceleratorplus,
		/datum/design/jackhammer,
		/datum/design/repeatermod,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)
