/datum/techweb_node/mmi
	tech_tier = 1
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/mmi,
	)

/datum/techweb_node/cyborg
	tech_tier = 1
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/borg_chest,
		/datum/design/borg_head,
		/datum/design/borg_l_arm,
		/datum/design/borg_l_leg,
		/datum/design/borg_r_arm,
		/datum/design/borg_r_leg,
		/datum/design/borg_suit,
		/datum/design/borg_upgrade_rename,
		/datum/design/borg_upgrade_restart,
		/datum/design/board/borgupload,
		/datum/design/board/cyborgrecharger,
		/datum/design/board/robocontrol,
		/datum/design/synthetic_flash,
	)

/datum/techweb_node/cyborg_upg_util
	tech_tier = 3
	display_name = "Cyborg Upgrades: Utility"
	description = "Utility upgrades for cyborgs."
	prerequisite_nodes = list(/datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/borg_upgrade_circuit_app,
		/datum/design/borg_upgrade_expand,
		/datum/design/borg_upgrade_holding,
		/datum/design/borg_upgrade_lavaproof,
		/datum/design/borg_upgrade_rped,
		/datum/design/borg_upgrade_selfrepair,
		/datum/design/borg_upgrade_thrusters,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upg_med
	tech_tier = 3
	display_name = "Cyborg Upgrades: Medical"
	description = "Medical upgrades for cyborgs."
	prerequisite_nodes = list(/datum/techweb_node/adv_biotech)
	unlocked_designs = list(
		/datum/design/borg_upgrade_beaker_app,
		/datum/design/borg_upgrade_defibrillator,
		/datum/design/borg_upgrade_expandedsynthesiser,
		/datum/design/borg_upgrade_piercinghypospray,
		/datum/design/borg_upgrade_pinpointer,
		/datum/design/borg_upgrade_surgicalprocessor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upg_combat
	tech_tier = 3
	display_name = "Cyborg Upgrades: Combat"
	description = "Military grade upgrades for cyborgs."
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/adv_robotics, /datum/techweb_node/weaponry)
	unlocked_designs = list(/datum/design/borg_upgrade_vtec)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upg_service
	tech_tier = 3
	display_name = "Cyborg Upgrades: Service"
	description = "Allows service borgs to specialize with various modules."
	prerequisite_nodes = list(/datum/techweb_node/cyborg_upg_util)
	unlocked_designs = list(
		/datum/design/borg_upgrade_botany,
		/datum/design/borg_upgrade_casino,
		/datum/design/borg_upgrade_kitchen,
		/datum/design/borg_upgrade_party,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upg_bs
	tech_tier = 5
	display_name = "Cyborg Upgrades: Bluespace"
	description = "Utility upgrades for cyborgs: Now with 100% more bluespace!"
	prerequisite_nodes = list(/datum/techweb_node/cyborg_upg_util, /datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/borg_upgrade_bsrped,
		/datum/design/borg_upgrade_bslightreplacer
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/subdermal_implants
	tech_tier = 4
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prerequisite_nodes = list(/datum/techweb_node/biotech)
	unlocked_designs = list(
		/datum/design/c38_trac,
		/datum/design/implant_chem,
		/datum/design/implant_tracking,
		/datum/design/implantcase,
		/datum/design/implanter,
		/datum/design/locator,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SECURITY)

/datum/techweb_node/cyber_organs
	tech_tier = 4
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prerequisite_nodes = list(/datum/techweb_node/adv_biotech)
	unlocked_designs = list(
		/datum/design/cybernetic_heart,
		/datum/design/cybernetic_liver,
		/datum/design/cybernetic_lungs,
		/datum/design/cybernetic_stomach,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber_organs_upgraded
	tech_tier = 5
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prerequisite_nodes = list(/datum/techweb_node/cyber_organs)
	unlocked_designs = list(
		/datum/design/cybernetic_heart_u,
		/datum/design/cybernetic_liver_u,
		/datum/design/cybernetic_lungs_u,
		/datum/design/cybernetic_stomach_u,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/ipc_organs
	tech_tier = 3
	display_name = "IPC Parts"
	description = "We have the technology to replace him."
	prerequisite_nodes = list(/datum/techweb_node/cyber_organs, /datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/power_cord,
		/datum/design/robotic_ears,
		/datum/design/robotic_eyes,
		/datum/design/robotic_heart,
		/datum/design/robotic_liver,
		/datum/design/robotic_stomach,
		/datum/design/robotic_tongue,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyber_implants
	tech_tier = 4
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prerequisite_nodes = list(/datum/techweb_node/adv_biotech, /datum/techweb_node/datatheory)
	unlocked_designs = list(
		/datum/design/cyberimp_breather,
		/datum/design/cyberimp_diagnostic_hud,
		/datum/design/cyberimp_gloweyes,
		/datum/design/cyberimp_medical_hud,
		/datum/design/cyberimp_nutriment,
		/datum/design/cyberimp_security_hud,
		/datum/design/cyberimp_welding,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_cyber_implants
	tech_tier = 5
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prerequisite_nodes = list(
		/datum/techweb_node/cyber_implants,
		/datum/techweb_node/integrated_huds,
		/datum/techweb_node/neural_programming,
	)
	unlocked_designs = list(
		/datum/design/cyberimp_botany,
		/datum/design/cyberimp_janitor,
		/datum/design/cyberimp_nutriment_plus,
		/datum/design/cyberimp_reviver,
		/datum/design/cyberimp_surgical,
		/datum/design/cyberimp_toolset,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/combat_cyber_implants
	tech_tier = 5
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(
		/datum/techweb_node/adv_cyber_implants,
		/datum/techweb_node/high_efficiency,
		/datum/techweb_node/NVGtech,
		/datum/techweb_node/weaponry,
	)
	unlocked_designs = list(
		/datum/design/cyberimp_antidrop,
		/datum/design/cyberimp_antistun,
		/datum/design/cyberimp_thermals,
		/datum/design/cyberimp_thrusters,
		/datum/design/cyberimp_xray,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_combat_cyber_implants
	tech_tier = 5
	display_name = "Advanced Combat Cybernetic Implants"
	description = "Experimental military cybernetic weapons."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(
		/datum/techweb_node/adv_cyber_implants,
		/datum/techweb_node/syndicate_basic,
	)
	unlocked_designs = list(
		/datum/design/cyberimp_hydraulic_blade,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/linkedsurgery_implant
	tech_tier = 5
	display_name = "Surgical Serverlink Brain Implant"
	description = "A bluespace implant which a holder can read surgical programs from their server with."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(
		/datum/techweb_node/exp_surgery,
		/datum/techweb_node/micro_bluespace,
	)
	unlocked_designs = list(
		/datum/design/cyberimp_linkedsurgery,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)
