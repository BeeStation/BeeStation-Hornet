/datum/techweb_node/datatheory
	id = TECHWEB_NODE_DATATHEORY
	tech_tier = 1
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list(TECHWEB_NODE_BASE)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/anomaly
	id = TECHWEB_NODE_ANOMALY_RESEARCH
	tech_tier = 4
	display_name = "Anomaly Research"
	description = "Unlock the potential of the mysterious anomalies that appear on station."
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_APPLIED_BLUESPACE)
	design_ids = list(
		"anomaly_neutralizer",
		"reactive_armour",
		"xenoa_gloves",
		"xenoa_list_console",
		"xenoa_scale",
		"xenoa_conductor",
		"xenoa_calibrator",
		"xenoa_tracker",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bluespace_theory
	id = TECHWEB_NODE_BLUESPACE_BASIC
	tech_tier = 4
	display_name = "Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list(TECHWEB_NODE_BASE)
	design_ids = list(
		"beacon",
		"bluespace_crystal",
		"dragnetbeacon",
		"telesci_gps",
		"xenobioconsole",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/applied_bluespace
	id = TECHWEB_NODE_APPLIED_BLUESPACE
	tech_tier = 4
	display_name = "Applied Bluespace Research"
	description = "With a heightened grasp of bluespace dynamics, sophisticated applications and technologies can be devised using data from bluespace crystal analyses."
	prereq_ids = list(TECHWEB_NODE_BLUESPACE_BASIC, TECHWEB_NODE_ENGINEERING)
	design_ids = list(
		"bluespacebeaker",
		"bluespacesyringe",
		"bluespace_capsule",
		"bs_rped",
		"minerbag_holding",
		"ore_silo",
		"phasic_scanning",
		"roastingstick",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/bluespace_travel
	id = TECHWEB_NODE_BLUESPACE_TRAVEL
	tech_tier = 5
	display_name = "Bluespace Travel"
	description = "Application of Bluespace for static teleportation technology."
	prereq_ids = list(TECHWEB_NODE_APPLIED_BLUESPACE)
	design_ids = list(
		"bluespace_pod",
		"launchpad_console",
		"launchpad",
		"quantumpad",
		"tele_hub",
		"tele_station",
		"teleconsole",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bluespace_stabilisation
	id = TECHWEB_NODE_BLUESPACE_ANCHOR
	tech_tier = 5
	display_name = "Bluespace Stabilisation"
	description = "Analyse and disrupt nearby bluespace instabilities, preventing anomalous translation."
	prereq_ids = list(TECHWEB_NODE_MICRO_BLUESPACE)
	design_ids = list("bsanchor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bag_of_holding
	id = TECHWEB_NODE_BAGOFHOLDING
	tech_tier = 5
	display_name = "Bag of Holding"
	description = "Portable bluespace technology allows the production of backpacks that can store a greater volume of items than the volume of the bag."
	prereq_ids = list(TECHWEB_NODE_MICRO_BLUESPACE)
	design_ids = list("bag_holding")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/wormhole_gun
	id = TECHWEB_NODE_WORMHOLEGUN
	tech_tier = 5
	display_name = "Bluespace Wormhole Projector"
	description = "Develop the research required to create a miniaturized bluespace wormhole projector, allowing you to jump between two places instantly."
	prereq_ids = list(TECHWEB_NODE_MICRO_BLUESPACE)
	design_ids = list("wormholeprojector")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/gravity_gun
	id = TECHWEB_NODE_GRAVITY_GUN
	tech_tier = 5
	display_name = "One-point Bluespace-gravitational Manipulator"
	description = "Fancy wording for gravity gun."
	prereq_ids = list(TECHWEB_NODE_ADV_WEAPONRY, TECHWEB_NODE_BLUESPACE_TRAVEL)
	design_ids = list(
		"gravitygun",
		"mech_gravcatapult",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/quantum_spin
	id = TECHWEB_NODE_QSWAPPER
	tech_tier = 5
	display_name = "Quantum Spin Inverter"
	description = "Research the ability to create an experimental device that is able to swap the locations of two entities by switching their particles' spin values. Must be linked to another device to function."
	prereq_ids = list(TECHWEB_NODE_MICRO_BLUESPACE)
	design_ids = list("swapper")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
