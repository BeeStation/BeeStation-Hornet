/datum/techweb_node/mmi
	tech_tier = 1
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(/datum/design/mmi)

/datum/techweb_node/robotics
	tech_tier = 2
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prerequisite_nodes = list(/datum/techweb_node/base)
	unlocked_designs = list(/datum/design/paicard)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_robotics
	tech_tier = 3
	display_name = "Advanced Robotics Research"
	description = "It can even do the dishes!"
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/borg_upgrade_advancedmop,
		/datum/design/borg_upgrade_diamonddrill,
		/datum/design/borg_upgrade_trashofholding,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/neural_programming
	tech_tier = 2
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prerequisite_nodes = list(/datum/techweb_node/biotech, /datum/techweb_node/datatheory)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/posibrain
	display_name = "Positronic Brain"
	description = "Applied usage of neural technology allowing for autonomous AI units based on special metallic cubes with conductive and processing circuits."
	prerequisite_nodes = list(/datum/techweb_node/neural_programming)
	unlocked_designs = list(/datum/design/posibrain)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai
	tech_tier = 3
	display_name = "Artificial Intelligence"
	description = "AI unit research."
	prerequisite_nodes = list(/datum/techweb_node/posibrain, /datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/board/aicore,
		/datum/design/board/aifixer,
		/datum/design/board/aiupload,
		/datum/design/board/asimov_module,
		/datum/design/boris_ai_controller,
		/datum/design/board/corporate_module,
		/datum/design/board/default_module,
		/datum/design/board/drone_module,
		/datum/design/board/freeform_module,
		/datum/design/intellicard,
		/datum/design/mecha_tracking_ai_control,
		/datum/design/board/nutimov_module,
		/datum/design/board/oxygen_module,
		/datum/design/board/paladin_module,
		/datum/design/board/protectstation_module,
		/datum/design/board/quarantine_module,
		/datum/design/board/remove_module,
		/datum/design/board/reset_module,
		/datum/design/board/robocop_module,
		/datum/design/board/safeguard_module,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_laws
	tech_tier = 4
	display_name = "Advanced AI Laws"
	description = "Delving into sophisticated AI directives, with hopes that they won't lead to humanity's extinction."
	prerequisite_nodes = list(/datum/techweb_node/ai)
	unlocked_designs = list(
		/datum/design/board/antimov_module,
		/datum/design/board/asimovpp_module,
		/datum/design/board/crewsimov_module,
		/datum/design/board/balance_module,
		/datum/design/board/damaged_module,
		/datum/design/board/dadbot_module,
		/datum/design/board/dungeon_master_module,
		/datum/design/board/freeformcore_module,
		/datum/design/board/hippocratic_module,
		/datum/design/board/hulkamania_module,
		/datum/design/board/liveandletlive_module,
		/datum/design/board/efficiency_module,
		/datum/design/board/onehuman_module,
		/datum/design/board/overlord_module,
		/datum/design/board/painter_module,
		/datum/design/board/paladin_devotion_module,
		/datum/design/board/peacekeeper_module,
		/datum/design/board/purge_module,
		/datum/design/board/reporter_module,
		/datum/design/board/ten_commandments_module,
		/datum/design/board/thermodynamic_module,
		/datum/design/board/thinkermov_module,
		/datum/design/board/tyrant_module,
		/datum/design/board/yesman_module,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/upgrades_basic
	tech_tier = 2
	display_name = "Basic Synth Upgrades"
	description = "Devices that interface with energy-based humaniods, namely IPCs."
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/ipc_upgrade/emp_shield,
		/datum/design/ipc_upgrade/supply_pack,
		/datum/design/ipc_upgrade/part_fab,
		/datum/design/ipc_upgrade/tool_speedifier,
		/datum/design/ipc_upgrade/fuel_generator,
		/datum/design/ipc_upgrade/cooling_system,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/upgrades_advanced
	tech_tier = 4
	display_name = "Advanced Synth Upgrades"
	description = "Advanced devices that interface with energy-based humaniods, namely IPCs."
	prerequisite_nodes = list(/datum/techweb_node/upgrades_basic)
	unlocked_designs = list(
		/datum/design/ipc_upgrade/repair_nexus,
		/datum/design/ipc_upgrade/medbeam,
		/datum/design/ipc_upgrade/overclocked_servos,
		/datum/design/ipc_upgrade/ipc_generator,
		/datum/design/ipc_upgrade/vacuum_shielding,
		/datum/design/ipc_upgrade/rad_shielding,
		/datum/design/ipc_upgrade/las_armor,
		/datum/design/ipc_upgrade/ken_armor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/upgrades_illegal
	tech_tier = 5
	display_name = "Illegal Synth Upgrades"
	description = "Illegal devices that interface with energy-based humaniods, namely IPCs."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_WAIT_FOR_PREREQS
	prerequisite_nodes = list(/datum/techweb_node/upgrades_advanced, /datum/techweb_node/syndicate_basic)
	unlocked_designs = list(
		/datum/design/ipc_upgrade/leap_legs,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
