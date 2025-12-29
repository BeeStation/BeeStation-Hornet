/datum/techweb_node/oldstation_surgery
	id = TECHWEB_NODE_OLDSTATION_SURGERY
	display_name = "Experimental Dissection"
	description = "Grants access to experimental dissections, which allows generation of research points."
	design_ids = list(
		"surgery_exp_dissection",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE
	show_on_wiki = FALSE

/datum/techweb_node/imp_wt_surgery
	id = TECHWEB_NODE_IMP_WT_SURGERY
	tech_tier = 2
	display_name = "Improved Wound-Tending Surgery"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prereq_ids = list(TECHWEB_NODE_ADV_BIOTECH)
	design_ids = list(
		"surgery_filter_upgrade",
		"surgery_heal_brute_upgrade",
		"surgery_heal_burn_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/adv_surgery
	id = TECHWEB_NODE_ADV_SURGERY
	tech_tier = 3
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prereq_ids = list(TECHWEB_NODE_IMP_WT_SURGERY)
	design_ids = list(
		"surgery_exp_dissection",
		"surgery_filter_upgrade_femto",
		"surgery_heal_brute_upgrade_femto",
		"surgery_heal_burn_upgrade_femto",
		"surgery_heal_combo",
		"surgery_lobotomy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/exp_surgery
	id = TECHWEB_NODE_EXP_SURGERY
	tech_tier = 4
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prereq_ids = list(TECHWEB_NODE_ADV_SURGERY)
	design_ids = list(
		"surgery_cortex_folding",
		"surgery_cortex_imprint",
		"surgery_heal_combo_upgrade",
		"surgery_ligament_hook",
		"surgery_ligament_reinforcement",
		"surgery_muscled_veins",
		"surgery_nerve_ground",
		"surgery_nerve_splice",
		"surgery_pacify",
		"surgery_revival",
		"surgery_vein_thread",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
