/datum/techweb_node/oldstation_surgery
	display_name = "Experimental Dissection"
	description = "Grants access to experimental dissections, which allows generation of research points."
	node_flags = TECHWEB_NODE_HIDDEN
	unlocked_designs = list(
		/datum/design/surgery/experimental_dissection,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/imp_wt_surgery
	tech_tier = 2
	display_name = "Improved Wound-Tending Surgery"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prerequisite_nodes = list(/datum/techweb_node/adv_biotech)
	unlocked_designs = list(
		/datum/design/surgery/healing/filter_upgrade,
		/datum/design/surgery/healing/brute_upgrade,
		/datum/design/surgery/healing/burn_upgrade,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_surgery
	tech_tier = 3
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prerequisite_nodes = list(/datum/techweb_node/imp_wt_surgery)
	unlocked_designs = list(
		/datum/design/surgery/experimental_dissection,
		/datum/design/surgery/healing/filter_upgrade_2,
		/datum/design/surgery/healing/brute_upgrade_2,
		/datum/design/surgery/healing/burn_upgrade_2,
		/datum/design/surgery/healing/combo,
		/datum/design/surgery/lobotomy,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/exp_surgery
	tech_tier = 4
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prerequisite_nodes = list(/datum/techweb_node/adv_surgery)
	unlocked_designs = list(
		/datum/design/surgery/cortex_folding,
		/datum/design/surgery/cortex_imprint,
		/datum/design/surgery/healing/combo_upgrade,
		/datum/design/surgery/ligament_hook,
		/datum/design/surgery/ligament_reinforcement,
		/datum/design/surgery/muscled_veins,
		/datum/design/surgery/nerve_grounding,
		/datum/design/surgery/nerve_splicing,
		/datum/design/surgery/pacify,
		/datum/design/surgery/vein_threading,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)
