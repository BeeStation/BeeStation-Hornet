/datum/techweb_node/basic_plasma
	tech_tier = 1
	display_name = "Basic Plasma Research"
	description = "Research into the mysterious and dangerous substance, plasma."
	prerequisite_nodes = list(/datum/techweb_node/engineering)
	unlocked_designs = list(/datum/design/mech_generator)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/adv_plasma
	tech_tier = 2
	display_name = "Advanced Plasma Research"
	description = "Research on how to fully exploit the power of plasma."
	prerequisite_nodes = list(/datum/techweb_node/basic_plasma)
	unlocked_designs = list(/datum/design/mech_plasma_cutter)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/plasma_refiner
	tech_tier = 4
	display_name = "Plasma Refining"
	description = "Development of a machine capable of safely and efficently converting plasma from a solid state to a gaseous state."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/basic_shuttle_tech)
	unlocked_designs = list(/datum/design/board/plasma_refiner)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/atmos_packpack_efficiency_upgrade
	tech_tier = 2
	display_name = "Backpack Firefighter Tank Efficiency Upgrade Design"
	description = "Unlocks a new design that improves the backpack firefighter tanks."
	unlocked_designs = list(/datum/design/atmos_backpack_upgrade/efficiency)
	prerequisite_nodes = list(/datum/techweb_node/engineering)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/atmos_packpack_smartfoam_upgrade
	tech_tier = 4
	display_name = "Backpack Firefighter Tank Efficiency Upgrade Design"
	description = "Unlocks a new design that improves the backpack firefighter tanks."
	unlocked_designs = list(/datum/design/atmos_backpack_upgrade/smartfoam)
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/atmos_packpack_efficiency_upgrade)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)
