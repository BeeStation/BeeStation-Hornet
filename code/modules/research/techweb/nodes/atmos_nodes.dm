/datum/techweb_node/basic_plasma
	id = "basic_plasma"
	tech_tier = 1
	display_name = "Basic Plasma Research"
	description = "Research into the mysterious and dangerous substance, plasma."
	prereq_ids = list("engineering")
	design_ids = list("mech_generator")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_plasma
	id = "adv_plasma"
	tech_tier = 2
	display_name = "Advanced Plasma Research"
	description = "Research on how to fully exploit the power of plasma."
	prereq_ids = list("basic_plasma")
	design_ids = list("mech_plasma_cutter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/plasma_refiner
	id = "plasmarefiner"
	tech_tier = 4
	display_name = "Plasma Refining"
	description = "Development of a machine capable of safely and efficently converting plasma from a solid state to a gaseous state."
	prereq_ids = list("basic_shuttle")
	design_ids = list("plasma_refiner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/atmos_packpack_efficiency_upgrade
	id = "atmos_packpack_efficiency_upgrade"
	tech_tier = 2
	display_name = "Backpack Firefighter Tank Efficiency Upgrade Design"
	description = "Unlocks a new design that improves the backpack firefighter tanks."
	design_ids = list("bft_upgrade_efficiency")
	prereq_ids = list("engineering")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/atmos_packpack_smartfoam_upgrade
	id = "atmos_packpack_smartfoam_upgrade"
	tech_tier = 4
	display_name = "Backpack Firefighter Tank Efficiency Upgrade Design"
	description = "Unlocks a new design that improves the backpack firefighter tanks."
	design_ids = list("bft_upgrade_smartfoam")
	prereq_ids = list("adv_engi", "atmos_packpack_efficiency_upgrade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
