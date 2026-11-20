/datum/techweb_node/datatheory
	tech_tier = 1
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prerequisite_nodes = list(/datum/techweb_node/base)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/anomaly
	tech_tier = 4
	display_name = "Anomaly Research"
	description = "Unlock the potential of the mysterious anomalies that appear on station."
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/anomaly_neutralizer,
		/datum/design/reactive_armour,
		/datum/design/artifact_pinchers,
		/datum/design/board/xenoa_listing_console,
		/datum/design/board/xenoa_scale,
		/datum/design/board/xenoa_conductor,
		/datum/design/board/xenoa_calibrator,
		/datum/design/xenoartifact_tracker,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bluespace_theory
	tech_tier = 4
	display_name = "Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prerequisite_nodes = list(/datum/techweb_node/base)
	unlocked_designs = list(
		/datum/design/beacon,
		/datum/design/bluespace_crystal,
		/datum/design/dragnetbeacon,
		/datum/design/telesci_gps,
		/datum/design/board/xenobiocamera,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/applied_bluespace
	tech_tier = 4
	display_name = "Applied Bluespace Research"
	description = "With a heightened grasp of bluespace dynamics, sophisticated applications and technologies can be devised using data from bluespace crystal analyses."
	prerequisite_nodes = list(/datum/techweb_node/bluespace_theory, /datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/bluespacebeaker,
		/datum/design/bluespacesyringe,
		/datum/design/bluespace_capsule,
		/datum/design/bs_rped,
		/datum/design/miningsatchel_holding,
		/datum/design/board/ore_silo,
		/datum/design/phasic_scanning,
		/datum/design/roastingstick,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/bluespace_travel
	tech_tier = 5
	display_name = "Bluespace Travel"
	description = "Application of Bluespace for static teleportation technology."
	prerequisite_nodes = list(/datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/bluespace_pod,
		/datum/design/board/launchpad_console,
		/datum/design/board/launchpad,
		/datum/design/board/quantumpad,
		/datum/design/board/teleport_hub,
		/datum/design/board/teleport_station,
		/datum/design/board/teleconsole,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bluespace_stabilization
	tech_tier = 5
	display_name = "Bluespace Stabilization"
	description = "Analyse and disrupt nearby bluespace instabilities, preventing anomalous translation."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/micro_bluespace)
	unlocked_designs = list(/datum/design/bluespace_anchor)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bag_of_holding
	tech_tier = 5
	display_name = "Bag of Holding"
	description = "Portable bluespace technology allows the production of backpacks that can store a greater volume of items than the volume of the bag."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/micro_bluespace)
	unlocked_designs = list(/datum/design/bag_holding)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/wormhole_gun
	tech_tier = 5
	display_name = "Bluespace Wormhole Projector"
	description = "Develop the research required to create a miniaturized bluespace wormhole projector, allowing you to jump between two places instantly."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/micro_bluespace)
	unlocked_designs = list(/datum/design/wormhole_projector)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/gravity_gun
	tech_tier = 5
	display_name = "One-point Bluespace-gravitational Manipulator"
	description = "Fancy wording for gravity gun."
	prerequisite_nodes = list(/datum/techweb_node/adv_weaponry, /datum/techweb_node/bluespace_travel)
	unlocked_designs = list(
		/datum/design/gravitygun,
		/datum/design/mech_gravcatapult,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/quantum_spin
	tech_tier = 5
	display_name = "Quantum Spin Inverter"
	description = "Research the ability to create an experimental device that is able to swap the locations of two entities by switching their particles' spin values. Must be linked to another device to function."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/micro_bluespace)
	unlocked_designs = list(/datum/design/swapper)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
