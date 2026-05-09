/datum/techweb_node/basic_plasma
	id = TECHWEB_NODE_BASIC_PLASMA
	tech_tier = 1
	display_name = "Basic Plasma Research"
	description = "Research into the mysterious and dangerous substance, plasma."
	prereq_ids = list(TECHWEB_NODE_ENGINEERING)
	design_ids = list("mech_generator")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/adv_plasma
	id = TECHWEB_NODE_ADV_PLASMA
	tech_tier = 2
	display_name = "Advanced Plasma Research"
	description = "Research on how to fully exploit the power of plasma."
	prereq_ids = list(TECHWEB_NODE_BASIC_PLASMA)
	design_ids = list("mech_plasma_cutter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/plasma_refiner
	id = TECHWEB_NODE_PLASMAREFINER
	tech_tier = 4
	display_name = "Plasma Refining"
	description = "Development of a machine capable of safely and efficently converting plasma from a solid state to a gaseous state."
	prereq_ids = list(TECHWEB_NODE_BASIC_SHUTTLE)
	design_ids = list("plasma_refiner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/atmos_packpack_efficiency_upgrade
	id = TECHWEB_NODE_ATMOS_PACKPACK_EFFICIENCY_UPGRADE
	tech_tier = 2
	display_name = "Backpack Firefighter Tank Efficiency Upgrade Design"
	description = "Unlocks a new design that improves the backpack firefighter tanks."
	design_ids = list("bft_upgrade_efficiency")
	prereq_ids = list(TECHWEB_NODE_ENGINEERING)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/atmos_packpack_smartfoam_upgrade
	id = TECHWEB_NODE_ATMOS_PACKPACK_SMARTFOAM_UPGRADE
	tech_tier = 4
	display_name = "Backpack Firefighter Tank Efficiency Upgrade Design"
	description = "Unlocks a new design that improves the backpack firefighter tanks."
	design_ids = list("bft_upgrade_smartfoam")
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_ATMOS_PACKPACK_EFFICIENCY_UPGRADE)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)
